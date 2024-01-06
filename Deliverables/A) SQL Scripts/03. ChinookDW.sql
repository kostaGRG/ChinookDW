USE master
GO
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'ChinookDW')
BEGIN
    ALTER DATABASE ChinookDW SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE ChinookDW;
END;
GO


CREATE DATABASE ChinookDW
GO

USE ChinookDW
GO

DROP TABLE IF EXISTS DimTrack;
DROP TABLE IF EXISTS PlaylistTrack;
DROP TABLE IF EXISTS DimPlaylist;
DROP TABLE IF EXISTS DimCustomer;
DROP TABLE IF EXISTS DimEmployee;
DROP TABLE IF EXISTS FactSales;

CREATE TABLE DimCustomer (
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

CREATE TABLE DimEmployee (
    EmployeeKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    EmployeeID INT NOT NULL,
    EmployeeFirstName NVARCHAR(20) NOT NULL,
    EmployeeLastName NVARCHAR(20) NOT NULL,
    EmployeeTitle NVARCHAR(30) NOT NULL,
	EmployeeCity NVARCHAR(40) NULL,
	EmployeeState NVARCHAR(40) NULL,
	EmployeeCountry NVARCHAR(40) NULL,
    RowIsCurrent INT DEFAULT 1 NOT NULL,
    RowStartDate DATE DEFAULT '1899-12-31' NOT NULL,
    RowEndDate DATE DEFAULT '9999-12-31' NOT NULL,
    RowChangeReason VARCHAR(200) NULL
);

CREATE TABLE DimTrack(
    TrackKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    TrackID INT NOT NULL,
    TrackName NVARCHAR(200) NOT NULL,
	Composer NVARCHAR(220) NULL,
	Bytes INT NULL,
	Milliseconds INT NOT NULL,
	TrackUnitPrice NUMERIC(10,2) NOT NULL,
	MediaTypeName NVARCHAR(120) NOT NULL,
	GenreName NVARCHAR(120) NULL,
	AlbumTitle NVARCHAR(160) NOT NULL,
	ArtistName NVARCHAR(120) NULL,
    RowIsCurrent INT DEFAULT 1 NOT NULL,
    RowStartDate DATE DEFAULT '1899-12-31' NOT NULL,
    RowEndDate DATE DEFAULT '9999-12-31' NOT NULL,
    RowChangeReason VARCHAR(200) NULL
);

CREATE TABLE DimPlaylist(
    PlaylistKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    PlaylistID INT NOT NULL,
	PlaylistName NVARCHAR(120) NOT NULL,
    RowIsCurrent INT DEFAULT 1 NOT NULL,
    RowStartDate DATE DEFAULT '1899-12-31' NOT NULL,
    RowEndDate DATE DEFAULT '9999-12-31' NOT NULL,
    RowChangeReason VARCHAR(200) NULL
);

CREATE TABLE PlaylistTrack(
	PlaylistKey INT NOT NULL,
	TrackKey INT NOT NULL ,
	PRIMARY KEY (PlaylistKey,TrackKey),
	FOREIGN KEY (TrackKey) REFERENCES DimTrack(TrackKey),
	FOREIGN KEY (PlaylistKey) REFERENCES DimPlaylist(PlaylistKey),	
);

CREATE TABLE FactSales(
    InvoiceKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    CustomerKey INT NOT NULL,
	EmployeeKey INT NOT NULL,
    TrackKey INT NOT NULL,
    InvoiceDateKey INT NOT NULL,
    InvoiceTotalPrice NUMERIC(10,2) NOT NULL,
	InvoiceUnitPrice NUMERIC(10,2) NOT NULL,
	InvoiceQuantity INT NOT NULL
);
