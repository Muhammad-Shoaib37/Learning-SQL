
use adventureworks2019;

-- SQL is a Declarative language
--Programming languages can be categorized as procedural or declarative. Procedural languages 
-- enable you to define a sequence of instructions that the computer follows to perform a task. 
--Declarative languages enable you to describe the output you want,
--and leave the details of the steps required to produce the output to the execution engine.

/*
 A relational database is one in which the data has been organized in multiple tables 
 (technically referred to as relations), each representing a particular type of entity 
 (such as a customer, product, or sales order). The attributes of these entities (for example, a customer's 
 name, a product's price, or a sales order's order date) are defined as the columns, or attributes, of the table
 , and each row in the table represents an instance of the entity type (for example, a specific customer, 
 product, or sales order).

The tables in the database are related to one another using key columns that uniquely identify the particular
entity represented. A primary key is defined for each table, and a reference to this key is defined as a
foreign key in any related table. This is easier to understand by looking at an example:
*/

-- Schema: 
-- tables are defined within schemas to create logical namespaces in the database. For example,
--a Customer table might be defined in a Sales schema, while a Product table is defined in a Production schema. 
--The database might track details of orders that customers have placed in an Order table in the Sales schema. 
--The fully qualified name of an object includes the name of a database server instance in which the database is stored, the name of the database, 
--the schema name, and the table name. For example: Server1.StoreDB.Sales.Order.


SELECT OrderDate, COUNT(OrderID) AS Orders
FROM SalesOrder
WHERE Status = 'Shipped'
GROUP BY OrderDate
HAVING COUNT(OrderID) > 1
ORDER BY OrderDate DESC;

-- order of exec: from where, group, having, select order and limit

-- Datatypes
--https://learn.microsoft.com/en-us/training/modules/introduction-to-transact-sql/5a-data-types

SELECT CAST(ProductID AS varchar(4)) + ': ' + Name AS ProductName
FROM Production.Product;

SELECT CAST(Size AS integer) As NumericSize
FROM Production.Product;

-- try to cast otherwise return null
SELECT TRY_CAST(Size AS integer) As NumericSize
FROM Production.Product;

SELECT CONVERT(varchar(4), ProductID) + ': ' + Name AS ProductName
FROM Production.Product;

-- PARSE and TRY_PARSE
--The PARSE function is designed to convert formatted strings that represent numeric or date/time values.

SELECT PARSE('01/01/2021' AS date) AS DateValue,
   PARSE('$199.99' AS money) AS MoneyValue;

-- num to char : str
SELECT ProductID,  '$' + STR(ListPrice) AS Price
FROM Production.Product;

--Handel nulls:
--https://learn.microsoft.com/en-us/training/modules/introduction-to-transact-sql/5b-handle-nulls

--A NULL value means no value or unknown. 
--It does not mean zero or blank, or even an empty string. Those values are not unknown.
--A NULL value can be used for values that haven’t been supplied yet, for example, 
--when a customer has not yet supplied an email address. 


SELECT FirstName,
      ISNULL(MiddleName, 'None') AS MiddleIfAny,
      LastName
FROM Sales.Customer;

--  COALESCE is a little more flexible is that it can take a variable number of arguments, 
--each of which is an expression. 
--It will return the first expression in the list that is not NULL.

SELECT EmployeeID,
      COALESCE(HourlyRate * 40,
                WeeklySalary,
                Commission * SalesQty) AS WeeklyEarnings
FROM HR.Wages;

--NULLIF
--The NULLIF function allows you to return NULL under certain conditions. 
--This function has useful applications in areas such as data cleansing, when you wish to replace blank or placeholder characters with NULL.
--NULLIF takes two arguments and returns NULL if they're equivalent. If they aren't equal, NULLIF returns the first argument.

SELECT SalesOrderID,
      ProductID,
      UnitPrice,
      NULLIF(UnitPriceDiscount, 0) AS Discount
FROM Sales.SalesOrderDetail;


-- order by: to control the order the rows will be returned to the client is with an ORDER BY clause. 

SELECT ProductCategoryID AS Category, ProductName
FROM Production.Product
ORDER BY Category ASC, Price DESC;

-- TOP will let you specify how many rows to return, either as a positive integer or as a percentage of
-- all qualifying rows. 

-- limit: SELECT TOP 10 Name, ListPrice
FROM Production.Product
ORDER BY ListPrice DESC;


-- with ties duplicate consideration
SELECT TOP 10 WITH TIES Name, ListPrice
FROM Production.Product
ORDER BY ListPrice DESC;

-- percentage: 
SELECT TOP 10 PERCENT Name, ListPrice
FROM Production.Product
ORDER BY ListPrice DESC;

-- offset: define range of rows:
-- An extension to the ORDER BY clause called OFFSET-FETCH enables you to return only a range of the rows 
--selected by your query. It adds the ability to supply a starting point (an offset) and a value to specify 
--how many rows you would like to return (a fetch value)

-- by default skip o rows

SELECT ProductID, Name, ListPrice
FROM Production.Product
ORDER BY ListPrice DESC 
OFFSET 0 ROWS --Skip zero rows
FETCH NEXT 10 ROWS ONLY; --Get the next 10

SELECT ProductID, Name, ListPrice
FROM Production.Product
ORDER BY ListPrice DESC 
OFFSET 10 ROWS --Skip 10 rows
FETCH NEXT 10 ROWS ONLY; --Get the next 10

-- If the FETCH clause is omitted, all rows following OFFSET will be returned. 
--You'll also find that the keywords ROW and 
--are interchangeable, as are FIRST and NEXT, which enables a more natural syntax.

--Remove duplicates:

--Although the rows in a table should always be unique, when you select only a subset of the columns,
--the result rows may not be unique even if the original rows are. 

-- by default ALL uyse by select

SELECT City, CountryRegion
FROM Production.Supplier
ORDER BY CountryRegion, City;

-- distinct by column values

SELECT DISTINCT City, CountryRegion
FROM Production.Supplier
ORDER BY CountryRegion, City;


-- Filter rows: where
--The WHERE clause is made up of one or more search conditions, each of which must evaluate to TRUE,
--FALSE, or 'unknown' 
--for each row of the table. Rows will only be returned when the WHERE clause evaluates as TRUE. 

SELECT ProductCategoryID AS Category, ProductName
FROM Production.Product
WHERE ProductCategoryID = 2;

SELECT ProductCategoryID AS Category, ProductName
FROM Production.Product
WHERE ProductName IS NOT NULL;

-- multiple conditions
--Multiple predicates can be combined with the AND and OR operators and with parentheses. 
--However SQL Server will only process two conditions at a time.


SELECT ProductCategoryID AS Category, ProductName
FROM Production.Product
WHERE (ProductCategoryID = 2 OR ProductCategoryID = 3)
    AND (ListPrice < 10.00);


-- in filter
SELECT ProductCategoryID AS Category, ProductName
FROM Production.Product
WHERE ProductCategoryID IN (2, 3, 4);

-- between filter: The BETWEEN operator uses inclusive boundary values.
--Products with a price of either 1.00 or 10.00 would be included in the results.
SELECT ProductCategoryID AS Category, ProductName
FROM Production.Product
WHERE ListPrice BETWEEN 1.00 AND 10.00;

SELECT Name, ModifiedDate
FROM Production.Product
WHERE ModifiedDate BETWEEN '2012-01-01' AND '2012-12-31';

-- like filter (char data similaritoes)
SELECT Name, ListPrice
FROM Production.Product
WHERE Name LIKE '%mountain%';

-- You can use the _ (underscore) wildcard to represent a single character, like this:

SELECT ProductName, ListPrice
FROM SalesLT.Product
WHERE ProductName LIKE 'Mountain-[0-9][0-9][0-9] %, [0-9][0-9]';

