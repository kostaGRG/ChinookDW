USE ChinookDW

-- Only for the first load
DELETE FROM FactSales;
DELETE FROM DimTrack;
DELETE FROM DimCustomer;
DELETE FROM DimEmployee;
DELETE FROM PlaylistTrack;
DELETE FROM DimPlaylist;

-- 1
INSERT INTO DimCustomer (    
	CustomerID,
    CustomerFirstName,
    CustomerLastName,
	CustomerCompany,
	CustomerCity,
	CustomerState,
	CustomerCountry
	)
SELECT
  CustomerId,
  CustomerFirstName,
  CustomerLastName,
  ISNULL(CustomerCompany,'Unknown'),
  ISNULL(CustomerCity,'Unknown'),
  ISNULL(CustomerState,'Unknown'),
  ISNULL(CustomerCountry,'Unknown')
FROM ChinookStaging.dbo.Customer

--2 
INSERT INTO DimEmployee (    
	EmployeeID,
    EmployeeFirstName,
    EmployeeLastName,
    EmployeeTitle,
	EmployeeCity,
	EmployeeState,
	EmployeeCountry)
SELECT
  EmployeeID,
  EmployeeFirstName,
  EmployeeLastName,
  EmployeeTitle,
  ISNULL(EmployeeCity,'Unknown'),
  ISNULL(EmployeeState,'Unknown'),
  ISNULL(EmployeeCountry,'Unknown')
FROM ChinookStaging.dbo.Employee

--3
INSERT INTO DimTrack(
    TrackID,
	TrackName,
	Composer,
	Bytes,
	Milliseconds,
	TrackUnitPrice,
	MediaTypeName,
	GenreName,
	AlbumTitle,
	ArtistName)
SELECT
	TrackID,
	TrackName,
	ISNULL(Composer,'Unknown'),
	Bytes,
	Milliseconds,
	TrackUnitPrice,
	MediaTypeName,
	ISNULL(GenreName,'Unknown'),
	AlbumTitle,
	ISNULL(ArtistName,'Unknown')
FROM ChinookStaging.dbo.Track

--4
INSERT INTO DimPlaylist(
    PlaylistID,
	PlaylistName
	)
SELECT
	PlaylistId,
	PlaylistName
FROM ChinookStaging.dbo.Playlist

--5
INSERT INTO PlaylistTrack(
    PlaylistKey,
	TrackKey
	)
SELECT
	PlaylistId,
	TrackId
FROM ChinookStaging.dbo.PlaylistTrack


--6
INSERT INTO FactSales(
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
    ON c.CustomerID=s.CustomerId
INNER JOIN ChinookDW.dbo.DimEmployee as e
	ON e.EmployeeID = s.EmployeeId
INNER JOIN ChinookDW.dbo.DimTrack AS t
    ON t.TrackID=s.TrackId

select * from FactSales

