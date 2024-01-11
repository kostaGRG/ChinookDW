--changes in OLTP
USE Chinook
GO

-- update
update Chinook.[dbo].[Customer] set 
	Address = 'Some new address',
	City = 'Thessaloniki',
	Country = 'Greece'
where [LastName] ='Srivastava';



-- insert 2 customers
INSERT INTO Chinook.[dbo].[Customer](
  CustomerID,
  FirstName,
  LastName,
  Company,
  Address,
  City,
  State,
  Country,
  PostalCode,
  Fax,
  Phone,
  Email,
  SupportRepId
)
  VALUES(
  60,
  'Kostas',
  'Gerogiannis',
  null,
  null,
  'Thessaloniki',
  null,
  'Greece',
  '54634',
  '+30 699999999',
  null,
  'something_random@example.com',
  3
  );
  
INSERT INTO Chinook.[dbo].[Customer](
  CustomerID,
  FirstName,
  LastName,
  Company,
  Address,
  City,
  State,
  Country,
  PostalCode,
  Fax,
  Phone,
  Email,
  SupportRepId
)
  VALUES(
  61,
  'Random',
  'Guy',
  null,
  null,
  'Athens',
  null,
  'Greece',
  '11111',
  '+30 699999999',
  null,
  'something_random2@example.com',
  5
  );

-- find a  customer with no orders to delete
select c.CustomerID 
from Chinook.[dbo].[Customer] c 
left join Chinook.[dbo].Invoice i
on c.CustomerId = i.CustomerId
where i.InvoiceId is null;

-- delete
delete from Chinook.dbo.Customer where FirstName = 'Random';

--- insert new facts
INSERT INTO Chinook.dbo.Invoice
           (InvoiceId,[CustomerID] ,InvoiceDate, Total)
     VALUES
           (413,'60','2013-12-23',1.98)


INSERT INTO Chinook.dbo.InvoiceLine
(InvoiceId, InvoiceLineId, TrackId,  UnitPrice, Quantity)
VALUES
(413,2241,1,0.99,1),
(413,2242,2,0.99,1);

select * from Chinook.[dbo].[Customer]