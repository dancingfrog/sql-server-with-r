-- Path to R libraries
EXECUTE sp_execute_external_script
    @language = N'R',
    @script = N'
OutputDataSet <- data.frame(.libPaths());
'
    WITH RESULT SETS (([DefaultLibraryName] VARCHAR(MAX) NOT NULL));
GO

-- Installed R libraries (by package)
EXECUTE sp_execute_external_script
    @language = N'R',
    @script = N'
x <- data.frame(installed.packages())
View(x)
OutputDataSet <-x[c(1,2,3,5,6,8,16)]
'
GO

-- You can create a table for libraries and populate all the necessary information
CREATE TABLE dbo.Rlibraries
       (
            Package NVARCHAR(50),
            LibPath NVARCHAR(200),
            [Version] NVARCHAR(20),
            Depends NVARCHAR(200),
            Imports NVARCHAR(200),
            Suggests NVARCHAR(200),
            Built NVARCHAR(20)
       )
INSERT INTO Rlibraries
EXECUTE sp_execute_external_script
    @language = N'R',
    @script = N'
x <- data.frame(installed.packages())
View(x)
OutputDataSet <-x[c(1,2,3,5,6,8,16)]
'
SELECT * FROM dbo.Rlibraries;
DROP TABLE dbo.Rlibraries;
GO

-- Check free disk space
USE [master]
GO
SELECT 
    DB_NAME() AS DbName, 
    name AS FileName, 
    size/128.0 AS CurrentSizeMB,  
    CAST(FILEPROPERTY(name, 'SpaceUsed') AS INT)/128.0 AS SpaceUsedMB,
    size/128.0 - CAST(FILEPROPERTY(name, 'SpaceUsed') AS INT)/128.0 AS FreeSpaceMB,
    (size/128.0 - CAST(FILEPROPERTY(name, 'SpaceUsed') AS INT)/128.0)/1024 AS FreeSpaceGB
FROM sys.database_files; 
