USE Members
GO

-- ******* Procedure creating a table *******
CREATE OR ALTER PROCEDURE [dbo].[ProcBuildTable] 
    @TableName NVARCHAR(64), 
	@Col1Name NVARCHAR(64), @Col1DataType NVARCHAR(64), @Col1Nullable NVARCHAR(64), 
	@Col1Identity NVARCHAR(64), @Col1PrimKey NVARCHAR(64),
	@Col2Name NVARCHAR(64), @Col2DataType NVARCHAR(64),
    @Col3Name NVARCHAR(64), @Col3DataType NVARCHAR(64),
    @Col4Name NVARCHAR(64), @Col4DataType NVARCHAR(64),
    @Col5Name NVARCHAR(64), @Col5DataType NVARCHAR(64),
    @Col6Name NVARCHAR(64), @Col6DataType NVARCHAR(64)
AS
	DECLARE @SQLString NVARCHAR(MAX)
	SET @SQLString = 'CREATE TABLE '+ @TableName + 
	'( '
		+ @Col1Name +' '+ @Col1DataType +' '+@Col1Nullable +' '+@Col1Identity +' '+@Col1PrimKey +','
		+ @Col2Name +' '+ @Col2DataType +','
		+ @Col3Name +' '+ @Col3DataType +','
		+ @Col4Name +' '+ @Col4DataType +','
		+ @Col5Name +' '+ @Col5DataType +','
		+ @Col6Name +' '+ @Col6DataType +'
	)';
EXEC (@SQLString)
GO



-- ******* Procedure adding column *******
CREATE OR ALTER PROCEDURE [dbo].[ProcAddColumn]
	@TableName NVARCHAR(64), @NewColumnName NVARCHAR(32),
	@DataType NVARCHAR(32)
AS
	DECLARE @SQLString NVARCHAR(MAX);	
	SET @SQLString = 'ALTER TABLE '+@TableName + 
	' ADD ' +@NewColumnName +' '+@DataType;
EXEC (@SQLString);   
GO



-- ******* Procedure rename the table *******
CREATE OR ALTER PROCEDURE [dbo].[ProcRenameTable]
@OldTableName NVARCHAR(32), @NewTableName NVARCHAR(32)
AS	
	DECLARE @SQLString NVARCHAR(MAX);	
	SET @SQLString = 'sp_rename ' +@OldTableName +', ' +@NewTableName;
	EXEC (@SQLString);
GO


-- ******* Procedure rename the column *******
CREATE OR ALTER PROCEDURE [dbo].[ProcRenameColumn]
@TableAndColumn NVARCHAR(32), @NewColumnName NVARCHAR(32) 
AS	
	BEGIN		
		EXEC sp_rename  @TableAndColumn, @NewColumnName, 'COLUMN';		
	END
GO


-- ******* Procedure Insert data *******
CREATE OR ALTER PROCEDURE [dbo].[ProcInsertData]
(@NumbersOfData int)
AS
SET NOCOUNT ON
BEGIN	
	IF((SELECT COUNT(*) FROM AdWorks2014.HumanResources.Employee) < @NumbersOfData)
	SET @NumbersOfData = (SELECT COUNT(*) FROM AdWorks2014.HumanResources.Employee);
	INSERT INTO dbo.PersonalData (current_age, last_name, first_name, date_of_birth, city, status)
	SELECT	DATEDIFF(year, cast(AHE.BirthDate as DATE), cast(GETDATE() as DATE)), 
			APP.LastName,
			APP.FirstName,
			AHE.BirthDate,
			APA.AddressLine1,
	CASE
	WHEN AHE.MaritalStatus = 'S' THEN 'Single'
	WHEN AHE.MaritalStatus = 'M' THEN 'Married'
	END			
	FROM AdWorks2014.HumanResources.Employee as AHE
	INNER JOIN AdWorks2014.Person.Person as APP ON AHE.BusinessEntityId = APP.BusinessEntityId
	INNER JOIN AdWorks2014.Person.BusinessEntityAddress as APBEA ON  AHE.BusinessEntityId = APBEA.BusinessEntityId
	INNER JOIN AdWorks2014.Person.Address as APA ON APA.AddressID = APBEA.AddressID
	WHERE AHE.BusinessEntityId BETWEEN 1 AND @NumbersOfData;
END
GO


-- ******* Procedure - Data change *******
CREATE OR ALTER PROCEDURE [dbo].[ProcActionsOnData]
@Level1 int, @Level2 int
AS
SET NOCOUNT ON
BEGIN	
	DECLARE @counter int;
	SET @counter = 1;
	DECLARE @stopAction int;
	SELECT @stopAction = cast((SELECT COUNT(*) FROM PersonalData) as INTEGER);
	DECLARE @currentAge int;

	WHILE(@counter <= @stopAction)
	BEGIN
	SET @currentAge = cast((SELECT current_age FROM PersonalData WHERE id = @counter) as INT);

	IF(@currentAge <= @level1)
	UPDATE PersonalData SET descript = 'Level1' WHERE id = @counter;
	ELSE IF(@currentAge <= @level2)
	UPDATE PersonalData SET descript = 'Level2' WHERE id = @counter;
	ELSE BEGIN
	UPDATE PersonalData SET descript = 'Level3' WHERE id = @counter;	
	END
	SET @counter = @counter + 1
	END
END


-- ******* Function - Selected data *******
CREATE OR ALTER FUNCTION DisplayLevel2
(@Level2 as varchar(255)) 
returns varchar(255)
AS
BEGIN
	DECLARE @PerData as varchar(255) = ''
	SELECT @PerData = @PerData + first_name + ' ' + last_name + ', ' 
	FROM PersonalData
	WHERE descript like @Level2
	RETURN @PerData
END