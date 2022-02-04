
/********** SET DATABASE **********/
USE SQLTest;

/************* CREATE TABLES *************/

/*---------- Table Towns -----------*/
CREATE TABLE Towns (
TownID int not null IDENTITY,
TownName varchar(60),
PRIMARY KEY (TownID)
);

INSERT INTO Towns (TownName) VALUES
('Warszawa'),
('Katowice'),
('Bielsko-Bia³a');

/*---------- Table Users ----------*/
CREATE TABLE Users (
UserID int not null IDENTITY,
FirstName varchar(50),
LastName varchar(50),
TownID int,
PRIMARY KEY (UserID),
CONSTRAINT FK_UsersTowns FOREIGN KEY (TownID) 
REFERENCES Towns(TownID)
);

INSERT INTO Users (FirstName,LastName,TownID) VALUES
('Martyna','Nowak',1),
('Adam','Kowalski',3),
('Pawe³','Wiœniewski',2);

/*---------- Table Products ----------*/
CREATE TABLE Products (
ProductID int not null IDENTITY,
ProductName varchar(80),
ProductDescription varchar(200),
Price float(10),
Number int, 
PRIMARY KEY (ProductID)
);

INSERT INTO Products (ProductName,ProductDescription,Price, Number) VALUES 
('Window','Description Window', 21.44, 34),
('Lamp', 'Description Lamp', 55.23, 55),
('Doll', 'Description Doll', 11.22, 69);

/*---------- Table Orders ----------*/
CREATE TABLE Orders (
OrdersID int not null IDENTITY,
ProductID int not null,
UserID int not null,
DateOrder date,
ExecutionDateOrder date,
PRIMARY KEY (OrdersID),
CONSTRAINT FK_OrdersProduct FOREIGN KEY (ProductID) 
REFERENCES Products(ProductID),
CONSTRAINT FK_OrdersUsers FOREIGN KEY (UserID) 
REFERENCES Users(UserID)
);

INSERT INTO Orders (ProductID, UserID, DateOrder, ExecutionDateOrder) VALUES
(1,2,DATEADD(DAY,-1,GETDATE()),DATEADD(DAY,2,GETDATE())),
(2,3,DATEADD(DAY,-1, GETDATE()),DATEADD(DAY,4,GETDATE())),
(3,1,GETDATE(),DATEADD(DAY,5,GETDATE()));


/*********** ACTIONS ON TABLES **********/

/*---------- Insert data ----------*/
INSERT INTO Orders (ProductID, UserID, DateOrder, ExecutionDateOrder) VALUES (
(SELECT MAX(ProductID) FROM Products), 
(SELECT FLOOR(AVG(UserID)) FROM Users),
GETDATE(), 
DATEADD(DAY, CASE	
			 WHEN (SELECT MAX(ProductID) FROM Products)=1 THEN 3
			 WHEN (SELECT MAX(ProductID) FROM Products)=2 THEN 2
			 WHEN (SELECT MAX(ProductID) FROM Products)=3 THEN 1
			ELSE 10 END,
GETDATE())
);

/*---------- Update data ----------*/
UPDATE Products SET 
Price = CASE	
WHEN Price BETWEEN 0 AND 10 THEN ROUND(Price/1.1,2)
WHEN Price BETWEEN 10.01 AND 20 THEN Round(Price/1.2,2)
WHEN Price BETWEEN 20.01 AND 30 THEN Round(Price/1.3,2)			
ELSE Round(Price,2) END;

/*---------- Select data ----------*/
SELECT PR.ProductName, SUBSTRING(PR.ProductDescription,1,15)+'...', 
PR.Price, PR.Number, ROUND(cast(PR.Price*PR.Number as float),2) as 'Investment', US.FirstName, US.LastName, TW.TownName, 
ORD.DateOrder, ORD.ExecutionDateOrder 
FROM Orders AS ORD
INNER JOIN Products AS PR ON PR.ProductID = ORD.ProductID
INNER JOIN Users AS US ON US.UserID = ORD.UserID
INNER JOIN Towns AS TW ON TW.TownID = US.TownID
ORDER BY Price;




DROP TABLE Orders;
DROP TABLE Users;
DROP TABLE Towns;
DROP TABLE Products;


