-- OLTP -> Staging

USE ChinookStaging
GO

-- declare @etldate date = '2013-12-23';


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
declare @etldate date = '2013-12-23';

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

drop table if exists [ChinookStaging].[dbo].Staging_FactSales;


CREATE TABLE Staging_FactSales (
    InvoiceKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    CustomerKey INT NOT NULL,
	EmployeeKey INT NOT NULL,
    TrackKey INT NOT NULL,
    InvoiceDateKey INT NOT NULL,
    InvoiceTotalPrice NUMERIC(10,2) NOT NULL,
	InvoiceUnitPrice NUMERIC(10,2) NOT NULL,
	InvoiceQuantity INT NOT NULL
);

INSERT INTO ChinookStaging.dbo.Staging_FactSales(
    CustomerKey,
	EmployeeKey,
    TrackKey,
    InvoiceDateKey,
    InvoiceTotalPrice,
	InvoiceUnitPrice,
	InvoiceQuantity)
SELECT 
	c.CustomerId,
	e.EmployeeId,
	t.TrackId,
    CAST(FORMAT(InvoiceDate,'yyyyMMdd') AS INT),
    i.Total,
	il.UnitPrice,
	il.Quantity
FROM Chinook.dbo.Invoice i
INNER JOIN Chinook.dbo.InvoiceLine il
ON i.InvoiceId=il.InvoiceId
INNER JOIN Chinook.dbo.Customer c
ON i.CustomerId = c.CustomerId
INNER JOIN Chinook.dbo.Employee e
ON c.SupportRepId = e.EmployeeId
INNER JOIN Chinook.dbo.Track  t
ON t.TrackId = il.TrackId
WHERE InvoiceDate >= @etldate;
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
	CustomerId,
	EmployeeID,
	TrackID,
    InvoiceDateKey,
    InvoiceTotalPrice,
	InvoiceUnitPrice,
	InvoiceQuantity
FROM 
    ChinookStaging.dbo.Staging_FactSales AS s
INNER JOIN ChinookDW.dbo.DimCustomer AS c
    ON c.CustomerID=s.CustomerKey and c.RowIsCurrent = 1
INNER JOIN ChinookDW.dbo.DimEmployee as e
	ON e.EmployeeID=s.EmployeeKey and e.RowIsCurrent = 1
INNER JOIN ChinookDW.dbo.DimTrack AS t
    ON t.TrackID=s.TrackKey and t.RowIsCurrent = 1


