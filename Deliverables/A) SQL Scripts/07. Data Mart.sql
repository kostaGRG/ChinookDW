--------------
-- Data Mart
--------------
USE ChinookDW
GO

if exists(select 1 from sys.views where name='SalesMart')
drop view SalesMart;
go

CREATE VIEW SalesMart AS
SELECT 
	fs.InvoiceQuantity,
	fs.InvoiceUnitPrice,
	fs.InvoiceTotalPrice,
	dc.CustomerFirstName,
	dc.CustomerLastName,
	dc.CustomerCompany,
	dc.CustomerCity,
	dc.CustomerCountry,
	dc.CustomerState,
	de.EmployeeFirstName,
	de.EmployeeLastName,
	de.EmployeeTitle,
	de.EmployeeCity,
	de.EmployeeCountry,
	de.EmployeeState,
	dt.TrackName,
	dt.TrackUnitPrice,
	dt.Bytes,
	dt.Milliseconds,
	dt.AlbumTitle,
	dt.ArtistName,
	dt.Composer,
	dt.GenreName,
	dt.MediaTypeName,
	dd.DateKey
FROM FactSales fs
LEFT JOIN DimCustomer dc ON fs.CustomerKey = dc.CustomerKey
LEFT JOIN DimEmployee de ON fs.EmployeeKey = de.EmployeeKey
LEFT JOIN DimTrack dt ON fs.TrackKey = dt.TrackKey
LEFT JOIN DimDate dd ON fs.InvoiceDateKey = dd.DateKey;



