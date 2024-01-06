USE master
GO
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'ChinookStaging')
BEGIN
    ALTER DATABASE ChinookStaging SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE ChinookStaging;
END;
GO

CREATE DATABASE ChinookStaging
GO

USE ChinookStaging
GO

DROP TABLE IF EXISTS ChinookStaging.dbo.Customer;
DROP TABLE IF EXISTS ChinookStaging.dbo.Employee;
DROP TABLE IF EXISTS ChinookStaging.dbo.Track;
DROP TABLE IF EXISTS ChinookStaging.dbo.PlaylistTrack;
DROP TABLE IF EXISTS ChinookStaging.dbo.Playlist;
DROP TABLE IF EXISTS ChinookStaging.dbo.DimDate;
DROP TABLE IF EXISTS ChinookStaging.dbo.Sales;

--1. get data FROM Customer:
--  CustomerId,   CustomerFirstName,  CustomerLastName, CustomerCompany, CustomerCity, CustomerState, CustomerCountry
SELECT c.CustomerId,
c.FirstName as CustomerFirstName,
c.LastName as CustomerLastName,
c.Company as CustomerCompany,
c.City as CustomerCity,
c.State as CustomerState,
c.Country as CustomerCountry
INTO ChinookStaging.dbo.Customer
FROM Chinook.dbo.Customer AS c

--2. get data FROM Employee:
-- EmployeeFirstName, EmployeeLastName, EmployeeTitle, EmployeeCity, EmployeeCountry, EmployeeState
SELECT 
e.EmployeeId,
e.FirstName as EmployeeFirstName,
e.LastName as EmployeeLastName,
e.Title as EmployeeTitle,
e.City as EmployeeCity,
e.State as EmployeeState,
e.Country as EmployeeCountry
INTO ChinookStaging.dbo.Employee
FROM Chinook.dbo.Employee AS e


--3.  get data FROM Tracks
 -- TrackId, TrackName, Composer, bytes, milliseconds, TrackUnitPrice,
 -- MediaTypeName, GenreName, AlbumTitle, ArtistName
SELECT t.TrackId,
t.Name as TrackName,
t.Composer,
t.Bytes,
t.Milliseconds,
t.UnitPrice as TrackUnitPrice,
mt.Name as MediaTypeName,
g.Name as GenreName,
al.Title as AlbumTitle,
ar.Name as ArtistName
INTO ChinookStaging.dbo.Track
FROM Chinook.dbo.Track t
INNER JOIN Chinook.dbo.MediaType mt
ON t.MediaTypeId=mt.MediaTypeId
INNER JOIN Chinook.dbo.Genre g
ON t.GenreId=g.GenreId
INNER JOIN Chinook.dbo.Album al
ON t.AlbumId=al.AlbumId
INNER JOIN Chinook.dbo.Artist ar
ON al.ArtistId=ar.ArtistId

--4. get data FROM PlaylistTrack
 -- TrackId, PlaylistId
SELECT pt.TrackId, pt.PlaylistId
INTO ChinookStaging.dbo.PlaylistTrack
FROM Chinook.dbo.PlaylistTrack pt

--5. get data FROM Playlist
 -- PlaylistId, PlaylistName
SELECT p.PlaylistId, p.Name as PlaylistName
INTO ChinookStaging.dbo.Playlist
FROM Chinook.dbo.Playlist p

--6.  get FROM Sales (Invoice)
-- InvoiceId, CustomerId, TrackId, InvoiceDate,
-- Total, InvoiceUnitPrice, InvoiceQuantity
SELECT i.InvoiceId,
i.CustomerId,
c.SupportRepId as EmployeeId,
il.TrackId,
i.InvoiceDate,
i.Total as InvoiceTotalPrice,
il.UnitPrice as InvoiceUnitPrice,
il.Quantity as InvoiceQuantity
INTO ChinookStaging.dbo.Sales
FROM Chinook.dbo.Invoice i
INNER JOIN Chinook.dbo.InvoiceLine il
ON i.InvoiceId=il.InvoiceId
INNER JOIN Chinook.dbo.Customer c
ON i.CustomerId = c.CustomerId


--7. date dimension
SELECT MIN(InvoiceDate) minDate, MAX(InvoiceDate) maxDate FROM ChinookStaging.dbo.Sales