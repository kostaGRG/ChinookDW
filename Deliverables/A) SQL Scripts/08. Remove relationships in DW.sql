use ChinookDW

ALTER TABLE FactSales drop  constraint [FactSalesDimDate] ;

ALTER TABLE FactSales drop  constraint [FactSalesDimCustomer]  ;

ALTER TABLE FactSales drop  constraint [FactSalesDimEmployee]  ;

ALTER TABLE FactSales drop constraint [FactSalesDimTrack] ;
