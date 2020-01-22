

-- Path to R libraries
EXECUTE sp_execute_external_script
    @language = N'R',
    @script = N'
OutputDataSet <- data.frame(.libPaths());
'
    WITH RESULT SETS (([DefaultLibraryName] VARCHAR(MAX) NOT NULL));
GO

EXECUTE sp_execute_external_script
    @language = N'R',
    @script = N'
x <- data.frame(installed.packages())
View(x)
OutputDataSet <-x[,c(1,2,3,5,6,8,16)]
'
GO

USE SQLR;
GO

-- You can create a table for libraries and populate all the necessary information
CREATE TABLE dbo.Rlibraries
       (
            ID INT IDENTITY NOT NULL CONSTRAINT PK_RLibraries PRIMARY KEY CLUSTERED,
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
OutputDataSet <-x[,c(1,2,3,5,6,8,16)]
'

SELECT * FROM dbo.Rlibraries;
DROP TABLE dbo.Rlibraries;
GO
