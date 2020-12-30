USE Library;
GO

Create Table Books (
  Id BigInt Identity(1,1) Primary Key Not Null,
  Name Varchar(200) Not Null,
  Author Varchar(100) Not Null,
  Quantity int,
  Price int Not Null,
  Available bit)
GO

CREATE APPLICATION ROLE library_management
    WITH PASSWORD = 'library', DEFAULT_SCHEMA = dbo

DROP APPLICATION ROLE library_management;

Create Login library_management
    WITH PASSWORD = 'library', DEFAULT_DATABASE = Library;
Create User library_management From Login library_management;
Alter Role db_datawriter Add Member library_management;
Grant Select On Object::Books To library_management;
Grant Insert On Object::Books To library_management;
GO

SELECT COUNT(*)
  FROM [Books] as [b];

SET NOCOUNT ON;
Insert Into [Books] ([Author], [Available], [Name], [Price], [Quantity])
    VALUES ('Tom Wiswell', 1, 'Learn Checkers Fast', 2, 1);
