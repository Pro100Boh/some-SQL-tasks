
--1. Додати себе як співробітника компанії на позицію Intern.

		INSERT INTO Employees (LastName, FirstName, Title) Values ('Vereshchak', ' Bohdan', 'Intern');

--2. Змінити свою посаду на Director.

		UPDATE Employees
		SET Title = 'Director'
		WHERE EmployeeID = 10;  -- ID доданого співробітника з п.1

--3. Скопіювати таблицю Orders в таблицю OrdersArchive.

		SELECT * INTO OrdersArchive	FROM Orders;

--4. Очистити таблицю OrdersArchive.

		TRUNCATE TABLE OrdersArchive;

--5. Не видаляючи таблицю OrdersArchive, наповнити її інформацією повторно.

		SET IDENTITY_INSERT OrdersArchive ON 
        INSERT INTO OrdersArchive 
        ([OrderID],
        [CustomerID],
        [EmployeeID],
        [OrderDate],
        [RequiredDate],
        [ShippedDate],
        [ShipVia],
        [Freight],
        [ShipName],
        [ShipAddress],
        [ShipCity],
        [ShipRegion],
        [ShipPostalCode],
        [ShipCountry])
        SELECT * FROM Orders;

--6. З таблиці OrdersArchive видалити усі замовлення, що були зроблені замовниками із Берліну.

        DELETE FROM OrdersArchive WHERE CustomerID IN (
    	SELECT CustomerID
    	FROM Customers
    	WHERE City = 'Berlin' );

--7. Внести в базу два продукти з власним іменем та іменем групи.

		INSERT INTO Products (ProductName) VALUES ('Bohdan') , ('IP-63');

--8. Помітити продукти, що не фігурують в замовленнях, як такі, що більше не виробляються.

		UPDATE Products SET Discontinued = 1
		WHERE ProductID NOT IN (SELECT ProductID FROM [Order Details])

--9. Видалити таблицю OrdersArchive.

		DROP TABLE IF EXISTS OrdersArchive;

--10. Видатили базу Northwind.

		DROP DATABASE IF EXISTS Northwind;