EXEC sp_configure 'show advanced options', 1;
GO
RECONFIGURE
GO
EXEC sp_configure 'external scripts enabled', 1;
GO
RECONFIGURE WITH OVERRIDE
GO

EXEC sp_execute_external_script
    @language =N'R',
    @script=N'OutputDataSet<-InputDataSet',
    @input_data_1 =N'SELECT 1 AS hello'
WITH RESULT SETS (([Hello World] INT));
GO

EXEC sp_execute_external_script
	@language=N'R',
	@script=N'OutputDataSet <- InputDataSet',
	@input_data_1=N'SELECT 1 As Numb UNION ALL SELECT 2;'
WITH RESULT SETS
((
	Res INT
));

EXEC sp_configure 'external scripts enabled';
GO

USE [master]
Go
CREATE DATABASE SQLR;
GO

CREATE LOGIN [R] WITH PASSWORD=N'p@$$W0RD', DEFAULT_DATABASE=[SQLR], CHECK_EXPIRATION=ON, CHECK_POLICY=ON
GO
ALTER SERVER ROLE [sysadmin] ADD MEMBER [R]
GO

USE [SQLR]
GO
CREATE USER [R] FOR LOGIN [R]
GO
ALTER ROLE [db_datareader] ADD MEMBER [R]
--ALTER AUTHORIZATION ON SCHEMA::[db_datareader] TO [R]
GO

GRANT EXECUTE ANY EXTERNAL SCRIPT TO [R];
GO
ALTER USER [R] WITH DEFAULT_SCHEMA=[dbo]
GO

USE [master]
GO
ALTER DATABASE master SET TRUSTWORTHY ON
GO
USE [SQLR]
GO
GRANT IMPERSONATE ON USER::[dbo] TO [R]
GO

USE [SQLR]
GO
-- Confirm user 'R' exists, by listing db users in SQLR
SELECT  
    [UserName] = CASE memberprinc.[type] 
                    WHEN 'S' THEN memberprinc.[name]
                 END,
    [UserType] = CASE memberprinc.[type]
                    WHEN 'S' THEN 'SQL User'
                    WHEN 'U' THEN 'Windows User'
                 END, 
    [DatabaseUserName] = memberprinc.[name],   
    [Role] = roleprinc.[name]
FROM    
    --Role/member associations
    sys.database_role_members members
JOIN
    --Roles
    sys.database_principals roleprinc ON roleprinc.[principal_id] = members.[role_principal_id]
JOIN
    --Role members (database users)
    sys.database_principals memberprinc ON memberprinc.[principal_id] = members.[member_principal_id];
EXECUTE AS USER='R';
GO

EXEC sp_execute_external_script
	@language=N'R',
	@script=N'OutputDataSet <- InputDataSet',
	@input_data_1=N'SELECT 1 As Numb UNION ALL SELECT 2;'
WITH RESULT SETS
((
	Res INT
));

-- REVERT;
-- GO
-- DROP USER R;
-- GO
-- USE [master];
-- GO
-- DROP LOGIN R;
-- GO
-- DROP TABLE IF EXISTS SQLR;
-- GO
-- DROP DATABASE IF EXISTS SQLR;
-- GO
