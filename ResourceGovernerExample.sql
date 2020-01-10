USE [master]
GO
RESTORE DATABASE [RevoTestDB] FROM DISK=N'D:\R\RevoTestDB.bak'; -- Restores to C:\Program Files\Microsoft SQL Server\MSSQL13.SQLSERVER2016RC3\MSSQL\Data
GO                                                              -- (might need symlink to real data store)

USE [RevoTestDB]
GO

-- TEST Query => 1
EXECUTE sp_execute_external_script
        @language=N'R',
        @script=N'
library(RevoScaleR)
f <- formula(as.numeric(ArrDelay) ~ as.numeric(DayOfWeek) + CRSDepTime)
s <- system.time(mod <- rxLinMod(formula = f, data = AirLine))
OutputDataSet <-  data.frame(system_time = s[3]);
		',
        @input_data_1 = N'SELECT * FROM AirlineDemoSmall',
        @input_data_1_name = N'AirLine'
-- WITH RESULT SETS UNDEFINED
WITH RESULT SETS 
((
    Elapsed_time FLOAT
));

-- Running Time: 00:00:02
-- Elapsed time: 0.94

-- Default value
ALTER EXTERNAL RESOURCE POOL [default] 
WITH (AFFINITY CPU = AUTO)
GO

CREATE EXTERNAL RESOURCE POOL RService_Resource_Pool  
WITH (  
     MAX_CPU_PERCENT = 10  
    ,MAX_MEMORY_PERCENT = 5
);  

ALTER RESOURCE POOL [default] WITH (max_memory_percent = 60, max_cpu_percent=90);  
ALTER EXTERNAL RESOURCE POOL [default] WITH (max_memory_percent = 40, max_cpu_percent=10);  
ALTER RESOURCE GOVERNOR reconfigure;

ALTER RESOURCE GOVERNOR RECONFIGURE;  
GO


-- CREATING CLASSIFICATION FUNCTION
CREATE WORKLOAD GROUP R_workgroup WITH (importance = medium) USING "default", 
EXTERNAL "RService_Resource_Pool";  

ALTER RESOURCE GOVERNOR WITH (classifier_function = NULL);  
ALTER RESOURCE GOVERNOR reconfigure;  

USE [master]  
GO  
CREATE FUNCTION RG_Class_function()  
RETURNS sysname  
WITH schemabinding  
AS  
BEGIN  
    IF program_name() in ('Microsoft R Host', 'RStudio') RETURN 'R_workgroup';  
    RETURN 'default'  
    END;  
GO  
ALTER RESOURCE GOVERNOR WITH  (classifier_function = dbo.RG_Class_function);  
ALTER RESOURCE GOVERNOR reconfigure;  
GO


USE [RevoTestDB]
GO

-- TEST Query => 2: performance with governor
EXECUTE sp_execute_external_script
        @language=N'R',
        @script=N'
library(RevoScaleR)
f <- formula(as.numeric(ArrDelay) ~ as.numeric(DayOfWeek) + CRSDepTime)
s <- system.time(mod <- rxLinMod(formula = f, data = AirLine))
OutputDataSet <-  data.frame(system_time = s[3]);
		',
        @input_data_1 = N'SELECT * FROM AirlineDemoSmall',
        @input_data_1_name = N'AirLine'
-- WITH RESULT SETS UNDEFINED
WITH RESULT SETS 
((
    Elapsed_time FLOAT
));

-- Running Time: 00:00:20
-- Elapsed time: 5.92

USE [RevoTestDB]
GO
DROP WORKLOAD GROUP R_workgroup
GO
DROP EXTERNAL RESOURCE POOL RService_Resource_Pool
GO

USE [master]
GO
ALTER RESOURCE GOVERNOR DISABLE
ALTER RESOURCE GOVERNOR WITH  (classifier_function = NULL);
GO
DROP FUNCTION RG_Class_function
GO

USE [RevoTestDB]
GO

-- TEST Query => 3: with resource governor disabled
EXECUTE sp_execute_external_script
        @language=N'R',
        @script=N'
library(RevoScaleR)
f <- formula(as.numeric(ArrDelay) ~ as.numeric(DayOfWeek) + CRSDepTime)
s <- system.time(mod <- rxLinMod(formula = f, data = AirLine))
OutputDataSet <-  data.frame(system_time = s[3]);
		',
        @input_data_1 = N'SELECT * FROM AirlineDemoSmall',
        @input_data_1_name = N'AirLine'
-- WITH RESULT SETS UNDEFINED
WITH RESULT SETS 
((
    Elapsed_time FLOAT
));

-- Running Time: 00:00:02
-- Elapsed time: 0.83
