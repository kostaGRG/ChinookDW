use ChinookDW
go

ALTER TABLE FactSales ADD  constraint [FactSalesDimDate] FOREIGN KEY (InvoiceDateKey)
    REFERENCES DimDate(DateKey);

ALTER TABLE FactSales ADD  constraint [FactSalesDimCustomer]  FOREIGN KEY (CustomerKey)
    REFERENCES DimCustomer (CustomerKey);

ALTER TABLE FactSales ADD  constraint [FactSalesDimEmployee]  FOREIGN KEY (EmployeeKey)
    REFERENCES DimEmployee (EmployeeKey);

ALTER TABLE FactSales ADD constraint [FactSalesDimTrack] FOREIGN KEY (TrackKey)
    REFERENCES DimTrack (TrackKey);
