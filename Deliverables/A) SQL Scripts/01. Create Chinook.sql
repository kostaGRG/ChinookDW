USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = N'Chinook')
BEGIN
    ALTER DATABASE [Chinook] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [Chinook];
END

-- Restoring the database from the .bak file
-- User has to change the folder path to the folder that he has stored the .bak file
RESTORE DATABASE [Chinook]
FROM DISK = N'C:\Users\kostasGRG\Desktop\data_warehousingV2\Chinook.bak'
WITH FILE = 1,
MOVE N'Chinook' TO N'C:\Users\kostasGRG\Desktop\data_warehousingV2\Chinook.mdf', 
MOVE N'Chinook_log' TO N'C:\Users\kostasGRG\Desktop\data_warehousingV2\Chinook_log.ldf',
NOUNLOAD, REPLACE, STATS = 10;