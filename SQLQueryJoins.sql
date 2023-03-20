
use AdventureWorks2019;

-- Joins: extract the data from two or more tables based on common values
--An INNER JOIN is the default type of JOIN, and the optional INNER keyword is implicit in the JOIN clause. 

SELECT ProductName, ListPrice
FROM SalesLT.Product
WHERE ProductName LIKE 'Mountain-[0-9][0-9][0-9] %, [0-9][0-9]';

1) SELECT emp.FirstName, ord.Amount
2) FROM HR.Employee AS emp 
3) JOIN Sales.SalesOrder AS ord
4)      ON emp.EmployeeID = ord.EmployeeID;

SELECT p.ProductID, m.Name AS Model, p.Name AS Product
FROM Production.Product AS p
INNER JOIN Production.ProductModel AS m
    ON p.ProductModelID = m.ProductModelID
ORDER BY p.ProductID;

SELECT od.SalesOrderID, m.Name AS Model, p.Name AS ProductName, od.OrderQty
FROM Production.Product AS p
INNER JOIN Production.ProductModel AS m
    ON p.ProductModelID = m.ProductModelID
INNER JOIN Sales.SalesOrderDetail AS od
    ON p.ProductID = od.ProductID
ORDER BY od.SalesOrderID;

-- Outer Join: 

/* 
With an OUTER JOIN, you can choose to display all the rows that have matching rows between the tables,
plus all the rows that don’t 
have a match in the other table. Let's look at an example, then explore the process.
*/

-- left outer join: return all rows of 1st table plus matching rows of second table with nulls

SELECT emp.Gender, ord.JobTitle
FROM [HumanResources].[Employee] AS emp
LEFT OUTER JOIN Sales.vSalesPerson AS ord
    ON emp.BusinessEntityID = ord.BusinessEntityID;

-- A FULL OUTER JOIN is used rarely. It returns all the matching rows between the two tables, 
--plus all the rows from the first table 
--with no match in the second, plus all the rows in the second without a match in the first.


--cross join: A crossjoin is simply a Cartesian product of the two tables. every rows of 1st with every rows of second
SELECT emp.FirstName, prd.Name
FROM HR.Employee AS emp
CROSS JOIN Production.Product AS prd;

--self join: There may be scenarios in which you need to retrieve and compare rows from a table with
--other rows from the same table.

SELECT emp.FirstName AS Employee, 
       mgr.FirstName AS Manager
FROM HR.Employee AS emp
LEFT OUTER JOIN HR.Employee AS mgr
  ON emp.ManagerID = mgr.EmployeeID;

select * from HumanResources.Employee;

