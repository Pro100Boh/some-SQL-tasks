--    1. Вивести на екран імена усіх таблиць в базі даних та кількість рядків в них.

		SELECT T.name AS 'TableName', 
			   I.rows AS 'RowCount' 
		FROM   sys.tables AS T 
			   INNER JOIN sys.sysindexes AS I 
			   ON T.object_id = I.id AND I.indid < 2;

--    2. Видати дозвіл на читання бази даних Northwind усім користувачам вашої СУБД. Код повинен працювати в незалежності від 
--		 імен існуючих користувачів.
		
		DECLARE GrantSelectToAllUsers CURSOR FOR SELECT name FROM master.sys.server_principals;
        DECLARE @Username nvarchar(255)

        OPEN GrantSelectToAllUsers
        WHILE(@@FETCH_STATUS = 0)
        BEGIN
            FETCH NEXT FROM GrantSelectToAllUsers INTO @Username
            EXEC('GRANT SELECT ON SCHEMA ::[dbo] TO' + @Username)
        END
        CLOSE GrantSelectToAllUsers
        DEALLOCATE GrantSelectToAllUsers

--    3. За допомогою курсору заборонити користувачеві TestUser доступ до всіх таблиць поточної бази даних, імена котрих
--		 починаються на префікс ‘prod_’.
		
		DECLARE @TableName nvarchar(50)
		DECLARE @TableSchema nvarchar(50)

		DECLARE TestCursor CURSOR FOR
			SELECT TABLE_NAME, TABLE_SCHEMA FROM Northwind.INFORMATION_SCHEMA.TABLES
			WHERE  TABLE_NAME LIKE 'prod\_%'

		OPEN TestCursor
		WHILE(@@FETCH_STATUS = 0)
		BEGIN
			FETCH NEXT FROM TableCursor INTO @TableName, @TableSchema
			EXEC('DENY SELECT ON ' + @TableSchema + ' ' + @TableName + ' TO TestUser')
		END
		CLOSE TestCursor
		DEALLOCATE TestCursor

--    4. Створити тригер на таблиці Customers, що при вставці нового телефонного номеру буде видаляти усі символи крім цифер.

			CREATE TRIGGER PhoneNumCorrection ON Customers INSTEAD OF INSERT AS 
			BEGIN
			DECLARE @Phone nvarchar(20)
			SELECT @Phone = Phone FROM inserted
			WHILE @Phone LIKE '%[^0-9]%' SET @Phone=STUFF(@Phone,PATINDEX('%[^0-9]%',@Phone),1,'')
			INSERT INTO Customers 
			SELECT CustomerID, CompanyName, ContactName, ContactTitle, Address, City, Region, PostalCode, Country, @Phone, Fax 
			FROM inserted
			END

--    5. Створити таблицю Contacts (ContactId, LastName, FirstName, PersonalPhone, WorkPhone, Email, PreferableNumber). 
--		 Створити тригер, що при вставці даних в таблицю Contacts вставить в якості PreferableNumber WorkPhone якщо він присутній, 
--		 або PersonalPhone, якщо робочий номер телефона не вказано.

		CREATE TABLE Contacts 
		(
			ContactId int IDENTITY(1,1) PRIMARY KEY,
			LastName nvarchar(50),
			FirstName nvarchar(50),
			PersonalPhone nvarchar(15),
			WorkPhone nvarchar(15),
			Email nvarchar(50),
			PreferableNumber nvarchar(15)
		)

		CREATE TRIGGER PhoneTrigger ON Contacts FOR INSERT AS
		UPDATE Contacts
		SET PreferableNumber = WorkPhone WHERE WorkPhone IS NOT NULL
		UPDATE Contacts
		SET PreferableNumber = PersonalPhone WHERE WorkPhone IS NULL


--    6. Створити таблицю OrdersArchive що дублює таблицію Orders та має додаткові атрибути DeletionDateTime та DeletedBy. 
--		 Створити тригер, що при видаленні рядків з таблиці Orders буде додавати їх в таблицю OrdersArchive та заповнювати 
--		 відповідні колонки.

			SELECT * INTO OrdersArchive FROM Orders
			ALTER TABLE OrdersArchive
			ADD DeletionDateTime datetime, DeletedBy nvarchar(50)

			CREATE TRIGGER DeletionTrigger ON Orders AFTER DELETE AS
				DECLARE @DeleteTime DateTime
				DECLARE @DeletedBy nvarchar(50)
				SELECT @DeletedBy = CURRENT_USER
				SELECT @DeleteTime = GETDATE() 

				INSERT INTO OrdersArchive (OrderID, CustomerID, EmployeeID, OrderDate, RequiredDate, ShippedDate, ShipVia,
				Freight, ShipName, ShipAddress, ShipCity, ShipRegion, ShipPostalCode, ShipCountry, DeletionDateTime, DeletedBy)

				SELECT OrderID, CustomerID,EmployeeID,OrderDate, RequiredDate, ShippedDate, ShipVia, Freight, ShipName,
				ShipAddress, ShipCity, ShipRegion, ShipPostalCode, ShipCountry, @DeleteTime, @DeletedBy 
				FROM DELETED


--    7. Створити три таблиці: TriggerTable1, TriggerTable2 та TriggerTable3. Кожна з таблиць має наступну структуру: 
--		 TriggerId(int) – первинний ключ з автоінкрементом, TriggerDate(Date). Створити три тригера. Перший тригер повинен 
--		 при будь-якому записі в таблицю TriggerTable1 додати дату запису в таблицю TriggerTable2. Другий тригер повинен при
--		 будь-якому записі в таблицю TriggerTable2 додати дату запису в таблицю TriggerTable3. Третій тригер працює 
--		 аналогічно за таблицями TriggerTable3 та TriggerTable1. Вставте один рядок в таблицю TriggerTable1. Напишіть, що 
--		 відбулось в коментарі до коду. Чому це сталося?

		CREATE TABLE TriggerTable1
		(
			TgiggerId int IDENTITY(1,1) PRIMARY KEY,
			TriggerDate date
		);

		CREATE TABLE TriggerTable2
		(
			TgiggerId int IDENTITY(1,1) PRIMARY KEY,
			TriggerDate date
		);

		CREATE TABLE TriggerTable3
		(
			TgiggerId int IDENTITY(1,1) PRIMARY KEY,
			TriggerDate date
		);

		CREATE TRIGGER Trigger12 ON TriggerTable1 AFTER INSERT AS
		INSERT INTO TriggerTable2 (TriggerDate) SELECT TriggerDate FROM inserted

		CREATE TRIGGER Trigger23 ON TriggerTable2 AFTER INSERT AS
		INSERT INTO dbo.TriggerTable3 (TriggerDate) SELECT TriggerDate FROM inserted

		CREATE TRIGGER Trigger31 ON TriggerTable3 AFTER INSERT AS
		INSERT INTO TriggerTable1 (TriggerDate) SELECT TriggerDate FROM inserted


		INSERT INTO TriggerTable1 (TriggerDate) VALUES (GETDATE());

		--По факту ми зайшли у нескінченну рекурсію, так як триггери викликали одне одного, відповідно відбулось переповнення стеку.