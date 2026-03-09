USE master;
GO

IF DB_ID(N'ProjectDB_Lab5') IS NULL
BEGIN
    RAISERROR(N'База ProjectDB_Lab5 не найдена. Сначала выполните 01_prepare_projectdb_lab5.sql на sql1.', 16, 1);
    RETURN;
END;
GO

-- Убеждаемся, что база в режиме FULL
ALTER DATABASE [ProjectDB_Lab5] SET RECOVERY FULL WITH NO_WAIT;
GO

BACKUP LOG [ProjectDB_Lab5]
TO DISK = N'/var/opt/mssql/backup/ProjectDB_Lab5_log_1.trn'
WITH
    INIT,
    COMPRESSION,
    STATS = 10;
GO

