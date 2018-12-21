--1. Створити базу даних з ім’ям, що відповідає вашому прізвищу англійською мовою.
	
	CREATE DATABASE Vereshchak;

--2. Створити в новій базі таблицю Student з атрибутами StudentId, SecondName, FirstName, Sex. Обрати для них оптимальний тип даних в вашій СУБД.
	
	CREATE TABLE Student (
		StudentID int NOT NULL,
		SecondName nvarchar(255) NOT NULL,
	    FirstName nvarchar(255) NOT NULL,
	    Sex char(1) NOT NULL
	);

--3. Модифікувати таблицю Student. Атрибут StudentId має стати первинним ключем.
	
	ALTER TABLE Student
	ADD PRIMARY KEY (StudentID);

--4. Модифікувати таблицю Student. Атрибут StudentId повинен заповнюватися автоматично починаючи з 1 і кроком в 1.
	
	ALTER TABLE Student
	DROP CONSTRAINT PK__Student__32C52B99DEB9D6C6;
	ALTER TABLE Student 
	DROP COLUMN StudentID;
	ALTER TABLE Student 
	ADD StudentID INT IDENTITY(1,1) PRIMARY KEY;

--5. Модифікувати таблицю Student. Додати необов’язковий атрибут BirthDate за відповідним типом даних.
	
	ALTER TABLE Student
	ADD BirthDate date;

--6. Модифікувати таблицю Student. Додати атрибут CurrentAge, що генерується автоматично на базі існуючих в таблиці даних.
	
	ALTER TABLE Student
	ADD CurrentAge AS (DATEDIFF(year, BirthDate, GETDATE() ) );

--7. Реалізувати перевірку вставлення даних. Значення атрибуту Sex може бути тільки ‘m’ та ‘f’.
	
	ALTER TABLE Student
	ADD CHECK (Sex = 'm' OR Sex = 'f');

--8. В таблицю Student додати себе та двох «сусідів» у списку групи.
	
	INSERT INTO  Student (FirstName, SecondName, Sex)
	VALUES('Vlad','Vasyuk','m')
	INSERT INTO  Student (FirstName,SecondName,Sex)
	VALUES('Bohdan','Vereshchak','m')
	INSERT INTO  Student (FirstName,SecondName,Sex)
	VALUES('Oleksandr','Vihliaev','m');

--9. Створити представлення vMaleStudent та vFemaleStudent, що надають відповідну інформацію.

	CREATE VIEW vMaleStudent AS
	SELECT * FROM Student
	WHERE Sex = 'm';

	CREATE VIEW vFemaleStudent AS
	SELECT * FROM Student
	WHERE Sex = 'f';


--10. Змінити тип даних первинного ключа на TinyInt (або SmallInt) не втрачаючи дані.
	
	ALTER TABLE Student
	ALTER COLUMN StudentID TINYINT;