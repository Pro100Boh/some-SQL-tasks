--    1. Створити збережену процедуру, що при виклику буде повертати ваше прізвище, ім’я та по-батькові.
		
		 CREATE PROCEDURE FullName
		 @lastName nvarchar(10) OUTPUT,
		 @firstName nvarchar(6) OUTPUT,
		 @patronymic nvarchar(11) OUTPUT
		 AS
		 SELECT @lastName = 'Vereshchak',
			    @firstName = 'Bohdan',
			    @patronymic = 'Serhiyovych'

--    2. В котексті бази Northwind створити збережену процедуру, що приймає текстовий параметр мінімальної довжини. 
--		 У разі виклику процедури з параметром ‘F’ на екран виводяться усі співробітники-жінки, у разі використання параметру 
--		 ‘M’ – чоловікі. У протилежному випадку вивести на екран повідомлення про те, що параметр не розпізнано.

		CREATE PROCEDURE GetEmployeesByGender
		@param varchar(1)
		AS
		IF @param = 'F'
		SELECT LastName, FirstName FROM Employees WHERE TitleOfCourtesy = 'Ms.' OR TitleOfCourtesy = 'Mrs.'
		ELSE IF @param = 'M'
		SELECT LastName, FirstName FROM Employees WHERE TitleOfCourtesy = 'Mr.' OR TitleOfCourtesy = 'Dr.'
		ELSE
		PRINT 'Incorrect parameter!'

--    3. В котексті бази Northwind створити збережену процедуру, що виводить усі замовлення за заданий період. 
--		 В тому разі, якщо період не задано – вивести замовлення за поточний день.

		CREATE PROCEDURE GetOrdersByDate
		@begin datetime = NULL,
		@end datetime = NULL
		AS
		IF @begin IS NULL OR @end IS NULL
		SELECT * FROM Orders WHERE OrderDate >= CONVERT(date, GETDATE()) AND OrderDate < DATEADD(day, 1, CONVERT (date, GETDATE()))
		ELSE
		SELECT * FROM Orders WHERE OrderDate  BETWEEN @begin AND @end

--    4. В котексті бази Northwind створити збережену процедуру, що в залежності від переданого параметру категорії виводить 
--		 категорію та перелік усіх продуктів за цією категорією. Дозволити можливість використати від однієї до п’яти категорій.

		CREATE PROCEDURE GetProductByCategory
		@category1 int, 
		@category2 int = NULL ,
		@category3 int = NULL,
		@category4 int = NULL,
		@category5 int = NULL
		AS
		IF @category1 IS NOT NULL AND @category2 IS NOT NULL AND @category3 IS NOT NULL AND @category4 IS NOT NULL AND @category5 IS NOT NULL
		SELECT * FROM Products WHERE CategoryID = @category1 OR CategoryID = @category2 OR CategoryID = @category3 OR CategoryID = @category4 OR CategoryID = @category5
		ELSE IF @category5 IS NULL
		SELECT * FROM Products WHERE CategoryID = @category1 OR CategoryID = @category2 OR CategoryID = @category3 OR CategoryID = @category4
		ELSE IF @category4 IS NULL
		SELECT * FROM Products WHERE CategoryID = @category1 OR CategoryID = @category2 OR CategoryID = @category3
		ELSE IF @category3 IS NULL
		SELECT * FROM Products WHERE CategoryID = @category1 OR CategoryID = @category2
		ELSE
		SELECT * FROM Products WHERE CategoryID = @category1

--    5. В котексті бази Northwind модифікувати збережену процедуру Ten Most Expensive Products для виводу всієї інформації з 
--		 таблиці продуктів, а також імен постачальників та назви категорій.

		ALTER PROCEDURE [dbo].[Ten Most Expensive Products] AS
		SELECT *, Suppliers.ContactName, Categories.CategoryName FROM Products         
		INNER JOIN Suppliers ON Products.SupplierID = Suppliers.SupplierID
        INNER JOIN Categories ON Products.CategoryID = Categories.CategoryID
		ORDER BY Products.UnitPrice DESC


--    6. В котексті бази Northwind створити функцію, що приймає три параметри (TitleOfCourtesy, FirstName, LastName) та виводить 
--		 їх єдиним текстом. Приклад: ‘Dr.’, ‘Yevhen’, ‘Nedashkivskyi’ –> ‘Dr. Yevhen Nedashkivskyi’

		CREATE FUNCTION CustomConcat (@titleOfCourtesy nvarchar(30), @firstName nvarchar(30), @lastName nvarchar(30))  
		RETURNS varchar(90)
		AS  
		BEGIN  
			 RETURN(CONCAT_WS (' ', @titleOfCourtesy, @firstName, @lastName)) 
		END

--    7. В котексті бази Northwind створити функцію, що приймає три параметри (UnitPrice, Quantity, Discount) та виводить кінцеву ціну.

		CREATE FUNCTION GetTotalPrice (@unitPrice float, @quantity int , @discount float) 
		RETURNS float
		AS 
		RETURN @unitPrice * (1 - @discount) * @quantity

--    8. Створити функцію, що приймає параметр текстового типу і приводить його до Pascal Case. 
--		 Приклад: Мій маленький поні –> МійМаленькийПоні 
		 
		CREATE FUNCTION PascalCase (@text text) 
		RETURNS text
		AS  
		RETURN REPLACE(@text, ' ', '');

--    9. В котексті бази Northwind створити функцію, що в залежності від вказаної країни, повертає усі дані про співробітника 
--		 у вигляді таблиці.

		CREATE FUNCTION GetEmployeesByCountry(@country nvarchar(15))
		RETURNS TABLE 
		AS
		RETURN (SELECT * FROM Employees WHERE Country = @country)

--    10. В котексті бази Northwind створити функцію, що в залежності від імені транспортної компанії повертає список клієнтів, 
--		  якою вони обслуговуються

		CREATE FUNCTION GetCustomersByShipper(@companyName nvarchar(40))
		RETURNS TABLE 
		AS
		RETURN 
		(
			SELECT * FROM Customers WHERE CustomerID IN 
			(
			SELECT CustomerID FROM Orders
			JOIN Shippers ON Orders.ShipVia = Shippers.ShipperID
			WHERE shippers.CompanyName = @companyName
			)
		)