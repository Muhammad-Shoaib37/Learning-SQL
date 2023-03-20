
-- Transactions:
-- A transaction is one or more T-SQL statements that are treated as a unit. If a single transaction fails, 
-- then all of the statements fail. If a transaction is successful, you know that all the data modification 
-- statements in the transaction were successful and committed to the database.

-- https://learn.microsoft.com/en-us/training/modules/implement-transactions-transact-sql/2-describe-transactions

-- Explicit transactions
--The keywords BEGIN TRANSACTION and either COMMIT or ROLLBACK start and end each batch of statements. 
-- This allows you to specify which statements must be either committed or rolled back together.

-- Atomicity – each transaction is treated as a single unit, which succeeds completely or fails completely. 
-- Consistency – transactions can only take the data in the database from one valid state to another.
-- Isolation – concurrent transactions cannot interfere with one another, and must result in a consistent database state.
-- Durability – when a transaction has been committed, it will remain committed. 


USE AdventureWorks2019;


BEGIN TRY
	INSERT INTO Sales.Orders(custid, empid, orderdate) 
		VALUES (68, 9, '2021-07-12');
	INSERT INTO dbo.Orders(custid, empid, orderdate) 
		VALUES (88, 3, '2021-07-15');
	INSERT INTO dbo.OrderDetails(orderid,productid,unitprice,qty) 
		VALUES (1, 2, 15.20, 20);
	INSERT INTO dbo.OrderDetails(orderid,productid,unitprice,qty) 
		VALUES (999, 77, 26.20, 15);
END TRY
BEGIN CATCH
	SELECT ERROR_NUMBER() AS ErrNum, ERROR_MESSAGE() AS ErrMsg;
END CATCH;

-- the INSERT statements for the Orders and OrderDetails tables are
-- enclosed within BEGIN TRANSACTION/COMMIT TRANSACTION keywords. 
-- This ensures that all statements are treated as a single transaction, 
-- which either succeeds or fails. Either one row is written to both the Orders and
-- OrderDetails table, or neither row is inserted. 

BEGIN TRY
 BEGIN TRANSACTION;
	INSERT INTO dbo.Orders(custid, empid, orderdate) 
		VALUES (68,9,'2006-07-15');
	INSERT INTO dbo.OrderDetails(orderid,productid,unitprice,qty) 
		VALUES (99, 2,15.20,20);
	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
 SELECT ERROR_NUMBER() AS ErrNum, ERROR_MESSAGE() AS ErrMsg;
 ROLLBACK TRANSACTION;
END CATCH;

-- Active transaction 

BEGIN TRY
 BEGIN TRANSACTION;
 	INSERT INTO dbo.SimpleOrders(custid, empid, orderdate) 
	VALUES (68,9,'2006-07-12');
	INSERT INTO dbo.SimpleOrderDetails(orderid,productid,unitprice,qty) 
	VALUES (1, 2,15.20,20);
 COMMIT TRANSACTION;
END TRY
BEGIN CATCH
	SELECT ERROR_NUMBER() AS ErrNum, ERROR_MESSAGE() AS ErrMsg;
	IF (XACT_STATE()) <> 0 -- active transaction
    	BEGIN
        ROLLBACK TRANSACTION;
    	END;
	ELSE .... -- provide for other outcomes of XACT_STATE()
END CATCH;


-- Data Concurrency
-- Concurrency uses locking and blocking to enables data to remain consistent with 
-- many users updating and reading data at the same time.

ALTER DATABASE *db_name* SET READ_COMMITTED_SNAPSHOT ON;

ALTER DATABASE *db_name* SET READ_COMMITTED_SNAPSHOT OFF;

-- Optimistic concurrency
-- With optimistic locking there's an assumption that few conflicting updates will occur.
-- At the start of the transaction, the initial state of the data is recorded.
-- Before the transaction is committed, the current state is compared with the initial state.
-- If the states are the same, the transaction is completed. If the states are different, 
-- the transaction is rolled back.

-- Pessimistic concurrency
-- With pessimistic locking there is an assumption that many updates are happening to the 
-- data at the same time. By using locks only one update can happen at the same time, 
-- and reads of the data are prevented while updates are taking place.

--exercises

DELETE SalesLT.Customer
WHERE CustomerID = IDENT_CURRENT('SalesLT.Customer');

DELETE SalesLT.Address
WHERE AddressID = IDENT_CURRENT('SalesLT.Address');

BEGIN TRANSACTION;

    INSERT INTO SalesLT.Customer (NameStyle, FirstName, LastName, EmailAddress, PasswordHash, PasswordSalt,    rowguid, ModifiedDate) 
    VALUES (0,  'Norman','Newcustomer','norman0@adventure-works.com','U1/CrPqSzwLTtwgBehfpIl7f1LHSFpZw1qnG1sMzFjo=','QhHP+y8=', NEWID(), GETDATE());

    INSERT INTO SalesLT.Address (AddressLine1, City, StateProvince, CountryRegion, PostalCode, rowguid,    ModifiedDate) 
    VALUES ('6388 Lake City Way', 'Burnaby','British Columbia','Canada','V5A 3A6', NEWID(), GETDATE());

    INSERT INTO SalesLT.CustomerAddress (CustomerID, AddressID, AddressType, rowguid, ModifiedDate)
    VALUES (IDENT_CURRENT('SalesLT.Customer'), IDENT_CURRENT('SalesLT.Address'), 'Home', NEWID(), '12-1-20212');

COMMIT TRANSACTION;


BEGIN TRANSACTION;

    INSERT INTO SalesLT.Customer (NameStyle, FirstName, LastName, EmailAddress, PasswordHash, PasswordSalt,    rowguid, ModifiedDate) 
    VALUES (0,  'Norman','Newcustomer','norman0@adventure-works.com','U1/CrPqSzwLTtwgBehfpIl7f1LHSFpZw1qnG1sMzFjo=','QhHP+y8=', NEWID(), GETDATE());

    INSERT INTO SalesLT.Address (AddressLine1, City, StateProvince, CountryRegion, PostalCode, rowguid,    ModifiedDate) 
    VALUES ('6388 Lake City Way', 'Burnaby','British Columbia','Canada','V5A 3A6', NEWID(), GETDATE());

    INSERT INTO SalesLT.CustomerAddress (CustomerID, AddressID, AddressType, rowguid, ModifiedDate)
    VALUES (IDENT_CURRENT('SalesLT.Customer'), IDENT_CURRENT('SalesLT.Address'), 'Home', '16765338-dbe4-4421-b5e9-3836b9278e63', GETDATE());

COMMIT TRANSACTION;

--transaction with try catch blocks

BEGIN TRY
BEGIN TRANSACTION;

    INSERT INTO SalesLT.Customer (NameStyle, FirstName, LastName, EmailAddress, PasswordHash, PasswordSalt,    rowguid, ModifiedDate) 
    VALUES (0,  'Norman','Newcustomer','norman0@adventure-works.com','U1/CrPqSzwLTtwgBehfpIl7f1LHSFpZw1qnG1sMzFjo=','QhHP+y8=',NEWID(), GETDATE());

    INSERT INTO SalesLT.Address (AddressLine1, City, StateProvince, CountryRegion, PostalCode, rowguid,    ModifiedDate) 
    VALUES ('6388 Lake City Way', 'Burnaby','British Columbia','Canada','V5A 3A6',NEWID(), GETDATE());

    INSERT INTO SalesLT.CustomerAddress (CustomerID, AddressID, AddressType, rowguid, ModifiedDate)
    VALUES (IDENT_CURRENT('SalesLT.Customer'), IDENT_CURRENT('SalesLT.Address'), 'Home', '16765338-dbe4-4421-b5e9-3836b9278e63', GETDATE());

COMMIT TRANSACTION;
PRINT 'Transaction committed.';

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Transaction rolled back.';
END CATCH; 

-- check state

BEGIN TRY
BEGIN TRANSACTION;

    INSERT INTO SalesLT.Customer (NameStyle, FirstName, LastName, EmailAddress, PasswordHash, PasswordSalt, rowguid, ModifiedDate) 
    VALUES (0, 'Norman','Newcustomer','norman0@adventure-works.com','U1/CrPqSzwLTtwgBehfpIl7f1LHSFpZw1qnG1sMzFjo=','QhHP+y8=',NEWID(), GETDATE());

    INSERT INTO SalesLT.Address (AddressLine1, City, StateProvince, CountryRegion, PostalCode, rowguid,  ModifiedDate) 
    VALUES ('6388 Lake City Way', 'Burnaby','British Columbia','Canada','V5A 3A6',NEWID(), GETDATE());

    INSERT INTO SalesLT.CustomerAddress (CustomerID, AddressID, AddressType, rowguid, ModifiedDate)
    VALUES (IDENT_CURRENT('SalesLT.Customer'), IDENT_CURRENT('SalesLT.Address'), 'Home', '16765338-dbe4-4421-b5e9-3836b9278e63', GETDATE());

COMMIT TRANSACTION;
PRINT 'Transaction committed.';

END TRY
BEGIN CATCH
  PRINT 'An error occurred.'
  IF (XACT_STATE()) <> 0
  BEGIN
      PRINT 'Transaction in process.'
      ROLLBACK TRANSACTION;
      PRINT 'Transaction rolled back.';
  END;
END CATCH

-- 

BEGIN TRY
BEGIN TRANSACTION;

    INSERT INTO SalesLT.Customer (NameStyle, FirstName, LastName, EmailAddress, PasswordHash, PasswordSalt, rowguid, ModifiedDate) 
    VALUES (0, 'Norman','Newcustomer','norman0@adventure-works.com','U1/CrPqSzwLTtwgBehfpIl7f1LHSFpZw1qnG1sMzFjo=','QhHP+y8=',NEWID(), GETDATE());

    INSERT INTO SalesLT.Address (AddressLine1, City, StateProvince, CountryRegion, PostalCode, rowguid,  ModifiedDate) 
    VALUES ('6388 Lake City Way', 'Burnaby','British Columbia','Canada','V5A 3A6',NEWID(), GETDATE());

    INSERT INTO SalesLT.CustomerAddress (CustomerID, AddressID, AddressType, ModifiedDate)
    VALUES (IDENT_CURRENT('SalesLT.Customer'), IDENT_CURRENT('SalesLT.Address'), 'Home', GETDATE());

COMMIT TRANSACTION;
PRINT 'Transaction committed.';
END TRY
BEGIN CATCH
  PRINT 'An error occurred.'
  IF (XACT_STATE()) <> 0
  BEGIN
      PRINT 'Transaction in process.'
      ROLLBACK TRANSACTION;
      PRINT 'Transaction rolled back.';
  END;
END CATCH

-- Throw an error

BEGIN TRY
BEGIN TRANSACTION;

    INSERT INTO SalesLT.Customer (NameStyle, FirstName, LastName, EmailAddress, PasswordHash, PasswordSalt, rowguid, ModifiedDate)     VALUES (0, 'Ann','Othercustomr','ann0@adventure-works.com','U1/CrPqSzwLTtwgBehfpIl7f1LHSFpZw1qnG1sMzFjo=','QhHP+y8=',NEWID(), GETDATE());;

    INSERT INTO SalesLT.Address (AddressLine1, City, StateProvince, CountryRegion, PostalCode, rowguid,  ModifiedDate) 
    VALUES ('6388 Lake City Way', 'Burnaby','British Columbia','Canada','V5A 3A6',NEWID(), GETDATE());

    INSERT INTO SalesLT.CustomerAddress (CustomerID, AddressID, AddressType, ModifiedDate)
    VALUES (IDENT_CURRENT('SalesLT.Customer'), IDENT_CURRENT('SalesLT.Address'), 'Home', GETDATE());

COMMIT TRANSACTION;
PRINT 'Transaction committed.';

THROW 51000, 'Some kind of error', 1;

END TRY
BEGIN CATCH
  PRINT 'An error occurred.'
  IF (XACT_STATE()) <> 0
  BEGIN
      PRINT 'Transaction in process.'
      ROLLBACK TRANSACTION;
      PRINT 'Transaction rolled back.';
  END;
END CATCH


-- exercise:

BEGIN TRY
BEGIN TRANSACTION;
    -- Get the highest order ID and add 1
  DECLARE @OrderID INT;
  SELECT @OrderID = MAX(SalesOrderID) + 1 FROM SalesLT.SalesOrderHeader;

  -- Insert the order header
  INSERT INTO SalesLT.SalesOrderHeader (SalesOrderID, OrderDate, DueDate, CustomerID, ShipMethod)
  VALUES (@OrderID, GETDATE(), DATEADD(month, 1, GETDATE()), 1, 'CARGO TRANSPORT');

  -- Insert one or more order details
  INSERT INTO SalesLT.SalesOrderDetail (SalesOrderID, OrderQty, ProductID, UnitPrice)
  VALUES (@OrderID, 1, 712, 8.99);

COMMIT TRANSACTION;
PRINT 'Transaction committed.';

END TRY
BEGIN CATCH
  PRINT 'An error occurred.'
  IF (XACT_STATE()) <> 0
  BEGIN
      PRINT 'Transaction in process.'
    ROLLBACK TRANSACTION;
    PRINT 'Transaction rolled back.'; 
  END;
END CATCH

-- in case of error

BEGIN TRY
BEGIN TRANSACTION;
    -- Get the highest order ID and add 1
  DECLARE @OrderID INT;
  SELECT @OrderID = MAX(SalesOrderID) + 1 FROM SalesLT.SalesOrderHeader;

  -- Insert the order header
  INSERT INTO SalesLT.SalesOrderHeader (SalesOrderID, OrderDate, DueDate, CustomerID, ShipMethod)
  VALUES (@OrderID, GETDATE(), DATEADD(month, 1, GETDATE()), 1, 'CARGO TRANSPORT');

  -- Insert one or more order details
  INSERT INTO SalesLT.SalesOrderDetail (SalesOrderID, OrderQty, ProductID, UnitPrice)
  VALUES (@OrderID, 1, 'Invalid product', 8.99);

COMMIT TRANSACTION;
PRINT 'Transaction committed.';

END TRY
BEGIN CATCH
  PRINT 'An error occurred.'
  IF (XACT_STATE()) <> 0
  BEGIN
      PRINT 'Transaction in process.'
    ROLLBACK TRANSACTION;
    PRINT 'Transaction rolled back.'; 
  END;
END CATCH