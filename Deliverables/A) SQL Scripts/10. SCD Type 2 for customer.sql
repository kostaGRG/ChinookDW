-- OLTP -> Staging

USE ChinookStaging
GO

declare @etldate date = '2013-12-23';

-----------------------------------------------------------

truncate table [ChinookStaging].[dbo].[Customer];
INSERT INTO Customer
(CustomerID,
CustomerFirstName,
CustomerLastName,
CustomerCompany,
CustomerCity, 
CustomerState,
CustomerCountry
)
SELECT 
c.CustomerId,
c.FirstName,
c.LastName,
c.Company,
c.City,
c.State,
c.Country
FROM Chinook.dbo.Customer AS c

-----------------------------------------------------------

truncate table [ChinookStaging].[dbo].Sales;
INSERT INTO Sales
(InvoiceId,
CustomerId,
TrackId,
InvoiceDate,
InvoiceTotalPrice, 
InvoiceUnitPrice,
InvoiceQuantity
)
SELECT 
i.InvoiceId,
i.CustomerId,
il.TrackId,
i.InvoiceDate,
i.Total,
il.UnitPrice,
il.Quantity
FROM Chinook.dbo.Invoice i
INNER JOIN Chinook.dbo.InvoiceLine il
ON i.InvoiceId=il.InvoiceId
where i.InvoiceDate>= @etldate;

--------------------------------------------------------

--- staging ->DW

drop table if exists [ChinookStaging].[dbo].Staging_DimCustomer;

CREATE TABLE Staging_DimCustomer (
    CustomerKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    CustomerID INT NOT NULL,
    CustomerFirstName NVARCHAR(40) NOT NULL,
    CustomerLastName NVARCHAR(40) NOT NULL,
	CustomerCompany NVARCHAR(80) NULL,
	CustomerCity NVARCHAR(40) NULL,
	CustomerState NVARCHAR(40) NULL,
	CustomerCountry NVARCHAR(40) NULL,
    RowIsCurrent INT DEFAULT 1 NOT NULL,
    RowStartDate DATE DEFAULT '1899-12-31' NOT NULL,
    RowEndDate DATE DEFAULT '9999-12-31' NOT NULL,
    RowChangeReason VARCHAR(200) NULL
);

--------------------------------------------------------

Insert into ChinookStaging.[dbo].Staging_DimCustomer(
	CustomerID,
    CustomerFirstName,
    CustomerLastName,
	CustomerCompany,
	CustomerCity,
	CustomerState,
	CustomerCountry
	)
	(  
Select 
CustomerID,
CustomerFirstName,
CustomerLastName,
ISNULL(CustomerCompany,'Unknown'),
ISNULL(CustomerCity,'Unknown'),
ISNULL(CustomerState,'Unknown'),
ISNULL(CustomerCountry,'Unknown')
from ChinookStaging.[dbo].[customer]  );

--------------------------------------------------------

INSERT INTO ChinookDW.[dbo].DimCustomer (
	CustomerID,
    CustomerFirstName,
    CustomerLastName,
	CustomerCompany,
	CustomerCity,
	CustomerState,
	CustomerCountry,
	RowStartDate,
	RowChangeReason )
SELECT 
	CustomerID,
    CustomerFirstName,
    CustomerLastName,
	CustomerCompany,
	CustomerCity,
	CustomerState,
	CustomerCountry,
	@etldate,
	ActionName
FROM
(
	MERGE ChinookDW.[dbo].DimCustomer AS target
		USING ChinookStaging.[dbo].Staging_DimCustomer as source
		ON target.[CustomerID] = source.[CustomerID]
	 WHEN MATCHED 	 AND 
	 source.CustomerCity <> target.CustomerCity  
	 AND target.[RowIsCurrent] = 1 
	 THEN UPDATE SET
		 target.RowIsCurrent = 0,
		 target.RowEndDate = dateadd(day, -1, @etldate ) ,
		 target.RowChangeReason = 'UPDATED NOT CURRENT'
	 WHEN NOT MATCHED THEN
	   INSERT  (
			CustomerID,
			CustomerFirstName,
			CustomerLastName,
			CustomerCompany,
			CustomerCity,
			CustomerState,
			CustomerCountry,
		    RowStartDate,
			RowChangeReason
	   )
	   VALUES( 
			source.CustomerID,
			source.CustomerFirstName,
			source.CustomerLastName,
			source.CustomerCompany,
			source.CustomerCity,
			source.CustomerState,
			source.CustomerCountry,
		    CAST(@etldate AS Date),
		    'NEW RECORD'
	   )
	WHEN NOT MATCHED BY Source THEN
		UPDATE SET 
			Target.RowEndDate= dateadd(day, -1, @etldate )
			,target.RowIsCurrent = 0
			,Target.RowChangeReason  = 'SOFT DELETE'
	OUTPUT 
			source.CustomerID,
			source.CustomerFirstName,
			source.CustomerLastName,
			source.CustomerCompany,
			source.CustomerCity,
			source.CustomerState,
			source.CustomerCountry,
			$Action as ActionName   
) AS Mrg
WHERE Mrg.ActionName='UPDATE'
AND [CustomerID] IS NOT NULL;

------------------------------------------------
-- insert new facts ...

INSERT INTO ChinookDW.[dbo].FactSales(
    CustomerKey,
	EmployeeKey,
    TrackKey,
    InvoiceDateKey,
    InvoiceTotalPrice,
	InvoiceUnitPrice,
	InvoiceQuantity)
SELECT 	
	CustomerKey,
	EmployeeKey,
	TrackKey,
    CAST(FORMAT(InvoiceDate,'yyyyMMdd') AS INT),
    InvoiceTotalPrice,
	InvoiceUnitPrice,
	InvoiceQuantity
FROM 
    ChinookStaging.dbo.Sales AS s
INNER JOIN ChinookDW.dbo.DimCustomer AS c
    ON c.CustomerID=s.CustomerId and c.RowIsCurrent = 1
INNER JOIN ChinookDW.dbo.DimEmployee as e
	ON e.EmployeeID=s.EmployeeId and e.RowIsCurrent = 1
INNER JOIN ChinookDW.dbo.DimTrack AS t
    ON t.TrackID=s.TrackId and t.RowIsCurrent = 1

