
use AdventureWorks2019;

/*
When a table is created, a default value can be supplied for a column, and that value will be used if DEFAULT 
is specified.
If a column has been defined to allow NULL values, and the column isn't an autogenerated column and 
doesn't have a default defined,
NULL will be inserted as a DEFAULT.

*/

INSERT INTO Sales.Promotion (PromotionName,StartDate,ProductModelID,Discount,Notes)
VALUES
('Clearance Sale', '01/01/2021', 23, 0.1, '10% discount');

-- for all col values

INSERT INTO Sales.Promotion
VALUES
('Clearance Sale', '01/01/2021', 23, 0.1, '10% discount');

-- null and default if allowed

INSERT INTO Sales.Promotion
VALUES
('Pull your socks up', DEFAULT, 24, 0.25, NULL);

-- Alternatively, you can omit values in the INSERT statement, in which case the default value will be used if defined, and if there is
--no default value but the column allows NULLs, then a NULL will be inserted.

INSERT INTO Sales.Promotion (PromotionName, ProductModelID, Discount)
VALUES
('Caps Locked', 2, 0.2);

--multiple values at same time

INSERT INTO Sales.Promotion
VALUES
('The gloves are off!', DEFAULT, 3, 0.25, NULL),
('The gloves are off!', DEFAULT, 4, 0.25, NULL);

--Insert from select

/*
To use the INSERT with a nested SELECT, build a SELECT statement to replace the VALUES clause. 
With this form, called INSERT SELECT, you can insert the set of rows returned by a SELECT query into 
a destination table. The use of INSERT SELECT presents the same considerations as INSERT VALUES:

You may optionally specify a column list following the table name.
You must provide column values or DEFAULT, or NULL, for each column.
*/

-- for existing table data insetion
INSERT INTO Sales.Promotion (PromotionName, ProductModelID, Discount, Notes)
SELECT DISTINCT 'Get Framed', m.ProductModelID, 0.1, '10% off ' + m.Name
FROM Production.ProductModel AS m
WHERE m.Name LIKE '%frame%';

-- create table and insert data from select

--SELECT INTO cannot be used to insert rows into an existing table, because it always creates a new table that
--is based on the result of the SELECT. Each column in the new table will have the same name, data type, 
--and nullability as the corresponding column (or expression) in the SELECT list.

SELECT SalesOrderID, CustomerID, OrderDate, PurchaseOrderNumber, TotalDue
INTO Sales.Invoice
FROM Sales.SalesOrderHeader;



--											Auto generated values
/*
You may need to automatically generate sequential values for one column in a specific table. 
Transact-SQL provides two ways to do this: use the IDENTITY property with a specific column 
in a table, or define a SEQUENCE object and use values generated by that object.
*/

CREATE TABLE Sales.Promotion
(
PromotionID int IDENTITY PRIMARY KEY, -- identity col
PromotionName varchar(20),
StartDate datetime NOT NULL DEFAULT GETDATE(),
ProductModelID int NOT NULL REFERENCES Production.ProductModel(ProductModelID),
Discount decimal(4,2) NOT NULL,
Notes nvarchar(max) NULL
);

-- get most recent identity value within same session for any table
SELECT SCOPE_IDENTITY();

--If you need the latest identity value in a specific table, you can use the IDENT_CURRENT function, like this:

SELECT IDENT_CURRENT('Sales.Promotion');

--override identity val
SET IDENTITY_INSERT SalesLT.Promotion ON;

INSERT INTO SalesLT.Promotion (PromotionID, PromotionName, ProductModelID, Discount)
VALUES
(20, 'Another short sale',37, 0.3);

SET IDENTITY_INSERT SalesLT.Promotion OFF;

-- As you've learned, the IDENTITY property is used to generate a sequence of values for a column within a table.
--However, the IDENTITY property isn't suitable for coordinating values across multiple tables within a database.

-- you'll need to reset or skip identity values for the column. To do this, you'll be "reseeding" the column using the DBCC CHECKIDENT function.

--				---------	Sequence -------------
/*
In Transact-SQL, you can use a sequence object to define new sequential values independently of a 
specific table. A sequence object is created using the CREATE SEQUENCE statement, optionally supplying 
the data type (must be an integer type or decimal or numeric with a scale of 0), the starting value,
an increment value, a maximum value, and other options related to performance.

*/

CREATE SEQUENCE Sales.InvoiceNumber AS INT
START WITH 1000 INCREMENT BY 1;

INSERT INTO Sales.ResellerInvoice
VALUES
(NEXT VALUE FOR Sales.InvoiceNumber, 2, GETDATE(), 'PO12345', 107.99);

-- IDENTITY or SEQUENCE

-- Use SEQUENCE if your application requires sharing a single series of numbers between multiple tables or multiple columns within a table.

--SEQUENCE: allows you to change the specification of the sequence, such as the increment value.

--IDENTITY: values are protected from updates. If you try to update a column with the IDENTITY property, you'll get an error.


SELECT NEXT VALUE FOR dbo.Sequence OVER (ORDER BY Name) AS NextID,
    ProductID,
    Name
FROM Production.Product;

--								------------ Update ----------

UPDATE Sales.Promotion
SET Discount = 0.2, Notes = REPLACE(Notes, '10%', '20%')
WHERE PromotionName = 'Get Framed';

--The UPDATE statement also supports a FROM clause, enabling you to modify data based on the results of a query.

UPDATE Sales.Promotion
SET Notes = FORMAT(Discount, 'P') + ' off ' + m.Name
FROM Product.ProductModel AS m
WHERE Notes IS NULL
    AND Sales.Promotion.ProductModelID = m.ProductModelID;


--							-------------- Delete ----------

--Just as the INSERT statement always adds whole rows to a table, the DELETE statement always removes entire rows.

DELETE FROM Production.Product
WHERE discontinued = 1;

--truncate: remove all rows from a table
TRUNCATE TABLE Sales.Sample;

--	********						--------- Merge ----------

/*

This DML option allows you to synchronize two tables by inserting, updating, or deleting rows in one table 
based on differences found in the other table. The table that is being modified is referred to as the target
table. The table that is used to determine which rows to change are called the source table.

MERGE modifies data, based on one or more conditions: ************

When the source data has a matching row in the target table, it can update data in the target table.
When the source data has no match in the target, it can insert data into the target table.
When the target data has no match in the source, it can delete the target data.


 We're matching the target and the source on a specified column, and if there's a match between 
 target and source, we specify an action to take on the target table. 
 If there's not a match, we specify an action. The action can be an INSERT, UPDATE, or DELETE operation.
*/

MERGE INTO Sales.Invoice as i
USING Sales.InvoiceStaging as s
ON i.SalesOrderID = s.SalesOrderID
WHEN MATCHED THEN -- when data already exist in target
    UPDATE SET i.CustomerID = s.CustomerID,
                i.OrderDate = GETDATE(),
                i.PurchaseOrderNumber = s.PurchaseOrderNumber,
                i.TotalDue = s.TotalDue
WHEN NOT MATCHED THEN -- when source data does not exist in target then add only
    INSERT (SalesOrderID, CustomerID, OrderDate, PurchaseOrderNumber, TotalDue)
    VALUES (s.SalesOrderID, s.CustomerID, s.OrderDate, s.PurchaseOrderNumber, s.TotalDue);















