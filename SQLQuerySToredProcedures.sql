
-- Stored Procedures
/*
Stored procedures are named groups of Transact-SQL (T-SQL) statements that can be used and 
reused whenever they're needed. Stored procedures can return results, manipulate data, 
and perform administrative actions on the server. You may need to execute 
stored procedures that someone else has created or create your own.

https://learn.microsoft.com/en-us/training/modules/create-stored-procedures-table-valued-functions/1-introduction

*/

use AdventureWorksDW2020;

go
CREATE PROCEDURE TopProducts AS
SELECT TOP(10) p.Class, sum(p.listprice) as total_price
    FROM DimProduct as p
    GROUP BY p.Class
    ORDER BY sum(p.listprice) DESC;

go

exec TopProducts
go

-- Dynamic sql exec
/*
Dynamic SQL allows you to build a character string that can be executed as T-SQL as an alternative 
to stored procedures. 
Dynamic SQL is useful when you don't know certain values until execution time.
*/

DECLARE @sqlstring AS VARCHAR(1000);
    SET @sqlstring='SELECT customerid, companyname, firstname, lastname 
    FROM DimCustomer;'
EXEC(@sqlstring);
GO

DECLARE @sqlstring1 AS VARCHAR(1000);
    SET @sqlstring1='SELECT c.customerkey, firstname, lastname 
    FROM DimCustomer as c;'
EXEC(@sqlstring1);
GO

--Sp_executesql allows you to execute a T-SQL statement with parameters. Sp_executesql can be used instead of 
--stored procedures when you want to pass a different value to the statement.

DECLARE @sqlstring2 NVARCHAR(1000);
SET @SqlString2 =
    N'SELECT TOP(10) p.Class, sum(p.listprice) as total_price
    FROM DimProduct as p
    GROUP BY p.Class;'
EXECUTE sp_executesql @SqlString2;

go
-- with parameter

EXECUTE sp_executesql   
          N'SELECT * FROM DimCustomer   
          WHERE customerkey = @cid',  
          N'@cid nvarchar(128)',  
          @cid = 11000;

go

					-- user defiend functions

--User-defined functions (UDF) are similar to stored procedures in that they re stored separately 
--from tables in the database. These functions accept parameters, perform an action, and then 
--return the action result as a single (scalar) value or a result set (table-valued).

CREATE FUNCTION ProductsInfo(@rec int)  
RETURNS TABLE  
AS  
RETURN  
    SELECT top(@rec) ProductKey, EnglishProductName, ProductLine  
    FROM DimProduct  
go

-- calling function
select * from ProductsInfo(20)
go
--multistatment TVF

CREATE FUNCTION OrderStatus 
     ( @CustomerID int )
RETURNS 
@Results TABLE 
     ( CustomerID int, OrderDate datetime )
AS
BEGIN
-- 1st statement which capture results from 2nd statement
     INSERT INTO @Results
-- 2nd statement which extract data from db
     SELECT top(10) SC.Customerkey, soh.OrderDate
     FROM DimCustomer AS SC 
     INNER JOIN FactInternetSales AS SOH 
        ON SC.CustomerKey = SOH.CustomerKey
     
 RETURN;
END;
GO;

select * from OrderStatus(11000);

go

SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'FactInternetSales'

go

select ProductKey, UnitPrice, OrderDate from FactInternetSales where ProductKey=310 and OrderDate='2018-01-11';
go
--scalar valued functions

CREATE FUNCTION Productpricevar
(@ProductID int, @OrderDate date)
RETURNS decimal 
AS 
BEGIN
    DECLARE @ListPrice decimal;
        SELECT @ListPrice = f.UnitPrice from dimProduct as p
        --select f.UnitPrice FROM dimProduct as p 
        INNER JOIN FactInternetSales as f 
        ON p.ProductKey = f.ProductKey 
		--where p.ProductKey = 310 and f.OrderDate = '2018-01-11'
           and p.ProductKey = @ProductID 
            AND f.OrderDate = @OrderDate
    RETURN @ListPrice;
END;
GO

select [dbo].Productpricevar(310, '2018-01-11');

