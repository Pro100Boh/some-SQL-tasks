--Задача №1:

--1.	Використовуючи SELECT двічі, виведіть на екран своє ім’я, прізвище та по-батькові одним результуючим набором.

		SELECT 'Vereshchak Bohdan Serhiyovych' AS 'FullName'
		UNION ALL
		SELECT 'Vereshchak Bohdan Serhiyovych';
--
--2.	Порівнявши власний порядковий номер в групі з набором із всіх номерів в групі, вивести на екран ;-) якщо він менший за усі з них, або :-D в протилежному випадку.

		SELECT CASE 
			WHEN 5 < ALL (SELECT ID FROM IP63)
			  THEN ':-D'
			ELSE ';-)'
		END;

--3.	Не використовуючи таблиці, вивести на екран прізвище та ім’я усіх дівчат своєї групи за вийнятком тих, хто має спільне ім’я з студентками іншої групи.

		SELECT * FROM (
		SELECT 'Luda' AS 'FirstName', 'Koroleva' AS 'LastName'
		UNION
		SELECT 'Vika' AS 'FirstName', 'Bondar' AS 'LastName'
		UNION
		SELECT 'Vera' AS 'FirstName', 'Popova' AS 'LastName'
		) AS Girls
		WHERE Girls.FirstName NOT IN ('Vlada', 'Liliya', 'Veronika', 'Anna');

--4.	Вивести усі рядки з таблиці Numbers (Number INT). Замінити цифру від 0 до 9 на її назву літерами. Якщо цифра більше, або менша за названі, залишити її без змін.

SELECT 
	CASE 
		WHEN Number = 0 THEN 'zero'
		WHEN Number = 1 THEN 'one'
		WHEN Number = 2 THEN 'two' 
		WHEN Number = 3 THEN 'three' 
		WHEN Number = 4 THEN 'four' 
		WHEN Number = 5 THEN 'five' 
		WHEN Number = 6 THEN 'six' 
		WHEN Number = 7 THEN 'seven' 
		WHEN Number = 8 THEN 'eight' 
		WHEN Number = 9 THEN 'nine'
		ELSE Number
	END
	FROM Numbers;


--5.	Навести приклад синтаксису декартового об’єднання для вашої СУБД.

		SELECT * FROM Table1 CROSS JOIN Table2;

--Задача №2:
--Виконати наступні завдання в контексті бази Northwind:

--1.	Вивисти усі замовлення та їх службу доставки. В залежності від ідентифікатора служби доставки, переіменувати її на таку, що відповідає вашому імені, прізвищу, або по-батькові.

		SELECT OrderID, ShipVia,
			CASE
				WHEN ShipVia = 1 THEN 'Vereshchak'
				WHEN ShipVia = 2 THEN 'Bohdan'
				ELSE 'Serhiyovych'
			END
		FROM Orders;

--2.	Вивести в алфавітному порядку усі країни, що фігурують в адресах клієнтів, працівників, та місцях доставки замовлень.

		SELECT Customers.Country FROM Customers
		UNION
		SELECT Employees.Country FROM Employees
		UNION
		SELECT ShipCountry FROM Orders
		ORDER BY 1;

--3.	Вивести прізвище та ім’я працівника, а також кількість замовлень, що він обробив за перший квартал 1998 року.

		SELECT LastName, FirstName, COUNT(OrderID) AS 'OrdersCount' FROM Employees
		INNER JOIN Orders ON Orders.EmployeeID = Employees.EmployeeID
		WHERE YEAR(OrderDate) = 1998 AND MONTH(OrderDate) < 4
		GROUP BY LastName, FirstName;

--4.	Використовуючи СTE знайти усі замовлення, в які входять продукти, яких на складі більше 100 одиниць, проте по яким немає максимальних знижок.

		WITH Products
		AS 
		(
			SELECT * FROM [Order Details]
			WHERE Discount <> (SELECT MAX(Discount) FROM [Order Details])
		)
		SELECT * FROM Products
		WHERE Products.Quantity > 100

--5.	Знайти назви усіх продуктів, що не продаються в південному регіоні.

		SELECT ProductName FROM  Products
		EXCEPT
		SELECT ProductName FROM  Products
		INNER JOIN [Order Details] ON Products.ProductID = [Order Details].ProductID
		INNER JOIN Orders ON [Order Details].OrderID = Orders.OrderID
		INNER JOIN Employees ON Orders.EmployeeID = Employees.EmployeeID
		INNER JOIN EmployeeTerritories ON Employees.EmployeeID = EmployeeTerritories.EmployeeID
		INNER JOIN Territories ON EmployeeTerritories.TerritoryID = Territories.TerritoryID
		INNER JOIN Region ON Territories.RegionID = Region.RegionID
		WHERE Region.RegionID = 4