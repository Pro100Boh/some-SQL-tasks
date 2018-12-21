--Задача 1:

-- 1. Необхідно знайти кількість рядків в таблиці, що містить більше ніж 2147483647 записів. 
--	  Напишіть код для MS SQL Server та ще однієї СУБД (на власний вибір).

--		MS SQL
		SELECT COUNT_BIG(*) AS 'Number of rows' FROM SomeTable;

--		PostgreSQL
		SELECT count(*) AS "Number of rows" FROM SomeTable;

-- 2. Підрахувати довжину свого прізвища за допомогою SQL.

		SELECT LEN('Vereshchak') AS 'LastNameLenth';

-- 3. У рядку з своїм прізвищем, іменем, та по-батькові замінити пробіли на знак ‘_’ (нижнє підкреслення).

		SELECT REPLACE('Vereshchak Bohdan Serhiyovych', ' ', '_') AS 'FullName';

-- 4. Створити генератор імені електронної поштової скриньки, що шляхом конкатенації об’єднував би дві 
--    перші літери з колонки імені, та чотири перші літери з колонки прізвища користувача, що зберігаються в базі даних, 
--		а також домену з вашим прізвищем.

		SELECT CONCAT(
					   LOWER(LEFT(FirstName,2)),
					   LOWER(LEFT(LastName,4)),
					   '@vereshchak.com'
					 ) AS 'e-mail' 
					 FROM Employees;

-- 5. За допомогою SQL визначити, в який день тиждня ви народилися.
		
		SELECT DATENAME(weekday, '1999-04-29') AS 'DayOfBirth';

--Задача 2:

--1. Вивести усі данні по продуктам, їх категоріям, та постачальникам, навіть якщо останні зпевних причин відсутні.

		SELECT * FROM Products
		LEFT JOIN Categories
		ON Products.CategoryID = Categories.CategoryID
		LEFT JOIN Suppliers
		ON Products.SupplierID = Suppliers.SupplierID;


--2.	Показати усі замовлення, що були зроблені в квітні 1988 року та не були відправлені.

		SELECT * FROM Orders WHERE YEAR (OrderDate) = 1988 AND MONTH(OrderDate) = 4 AND ShippedDate IS NULL;

--3.	Відібрати усіх працівників, що відповідають за північний регіон.

		SELECT Employees.EmployeeID, FirstName, LastName FROM Employees
		INNER JOIN EmployeeTerritories ON Employees.EmployeeID = EmployeeTerritories.EmployeeID
		INNER JOIN Territories ON Territories.TerritoryID = EmployeeTerritories.TerritoryID
		INNER JOIN Region ON Region.RegionID = Territories.RegionID
		WHERE Region.RegionID = 3 
		Group BY Employees.EmployeeID, FirstName, LastName;

--4.	Вирахувати загальну вартість з урахуванням знижки усіх замовлень, що були здійснені на непарну дату. 

		SELECT SUM( UnitPrice * Quantity * (1-Discount) ) FROM [Order Details]
		INNER JOIN Orders
		ON Orders.OrderID = [Order Details].OrderID 
		WHERE DAY(Orders.OrderDate) % 2 = 1;

--5.	Знайти адресу відправлення замовлення з найбільшою ціною (враховуючи усі позиції замовлення, їх вартість, кількість, 
--		та наявність знижки).
		SELECT ShipAddress FROM Orders WHERE OrderID = (
		SELECT TOP 1 OrderID FROM [Order Details] 
		GROUP BY OrderID 
		ORDER BY SUM(UnitPrice * Quantity * (1-Discount)) DESC
		);
