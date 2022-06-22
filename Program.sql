USE Members
GO

-- ****** CREATING A TABLE ******
DECLARE @TableName as NVARCHAR(32) = 'OldPersonalData';
DECLARE @Col1Name as NVARCHAR(4) = 'id';
DECLARE @Col1Nullable as NVARCHAR(16) = 'NOT NULL'; 
DECLARE @Col1Identity as NVARCHAR(16) = 'IDENTITY(1,1)'; 
DECLARE @Col1PrimKey as NVARCHAR(32) = 'CONSTRAINT pdKey PRIMARY KEY';
DECLARE @Col2Name as NVARCHAR(32) = 'first_name';
DECLARE @Col3Name as NVARCHAR(32) = 'last_name';
DECLARE @Col4Name as NVARCHAR(32) = 'age';
DECLARE @Col5Name as NVARCHAR(32) = 'date_of_birth';
DECLARE @Col6Name as NVARCHAR(32) = 'status'; 
DECLARE @NVC32DataType as NVARCHAR(16) = 'nvarchar(32)';
DECLARE @IntDataType as NVARCHAR(4) = 'int';
DECLARE @DateDataType as NVARCHAR(4) = 'date';
EXEC ProcBuildTable 
@TableName, 
@Col1Name, @IntDataType,@Col1Nullable,@Col1Identity,@Col1PrimKey, 
@Col2Name, @NVC32DataType, 
@Col3Name,  @NVC32DataType, 
@Col4Name, @IntDataType, 
@Col5Name, @DateDataType, 
@Col6Name,  @NVC32DataType;


-- ****** ADD A COLUMN ******
DECLARE @TableName1 as NVARCHAR(32) = 'OldPersonalData';
DECLARE @NewColumnName1 as NVARCHAR(32) = 'city';
DECLARE @NewColumnName2 as NVARCHAR(32) = 'descript';
DECLARE @DataType as NVARCHAR(16) = 'nvarchar(32)'; 
EXEC ProcAddColumn @TableName1, @NewColumnName1, @DataType;
EXEC ProcAddColumn @TableName1, @NewColumnName2, @DataType;

-- ******* Procedure rename the table *******
DECLARE @OldTableName as NVARCHAR(32) = 'OldPersonalData';
DECLARE @NewTableName as NVARCHAR(32) = 'PersonalData';
EXEC ProcRenameTable @OldTableName, @NewTableName;

-- ******* Procedure rename the column *******
DECLARE @TableAndColumn as NVARCHAR(32) = 'PersonalData.age';
DECLARE @NewNameColumnAg as NVARCHAR(32) = 'current_age';
EXEC ProcRenameColumn @TableAndColumn, @NewNameColumnAg;


-- ******* Procedure Insert data *******
DECLARE @NumberOfRecords as INT = 291;
EXEC ProcInsertData @NumberOfRecords;


-- ******* Procedure - Data change *******
DECLARE @Level1 as INT = 33;
DECLARE @Level2 as INT = 44;
EXEC ProcActionsOnData @Level1, @Level2; 


-- ****** Ranking functions *******
SELECT id, last_name, current_age,
ROW_NUMBER() over (ORDER BY current_age) as "RankAge"
FROM dbo.PersonalData;

SELECT id, last_name, current_age,
NTILE(5) over (ORDER BY current_age) as "RankAge"
FROM dbo.PersonalData;


-- ****** BEGIN TRANSACTION ******
BEGIN TRAN
	SAVE TRANSACTION SPoint1
	INSERT INTO dbo.PersonalData (current_age, last_name, first_name, date_of_birth, status) 
	VALUES (44, 'Williams', 'Harry', '19780505', 'Married');
	
	SAVE TRANSACTION SPoint2
	UPDATE dbo.PersonalData SET last_name = 'Evans' WHERE id = 3;

	SAVE TRANSACTION SPoint3
	DELETE FROM dbo.PersonalData WHERE id = 4;

ROLLBACK TRANSACTION SPoint1 
-- COMMIT


-- ****** Aggregate functions ****** 
Select PD.status, PD.descript,
MIN(current_age) as min,
MAX(current_age) as max,
AVG(current_age) as avg
From dbo.PersonalData as PD
GROUP BY PD.status, PD.descript 
HAVING AVG(current_age) >=22 AND MIN(current_age) > 33
ORDER BY AVG(current_age) DESC


-- ******* TRIGGER ******
CREATE OR ALTER TRIGGER actionsPersonalData
ON dbo.PersonalData
AFTER INSERT, UPDATE, DELETE
AS
PRINT 'Number of records changed ' + CAST(@@ROWCOUNT as VARCHAR(5));
GO


-- ******* Function - Selected data - Level2 *******
SELECT DISTINCT dbo.DisplayLevel2 ('Level2')
AS "Level2"
FROM dbo.PersonalData;





SELECT * FROM PersonalData;

TRUNCATE TABLE PersonalData;

IF OBJECT_ID('PersonalData','TABLE') IS NOT NULL
DROP TABLE PersonalData;