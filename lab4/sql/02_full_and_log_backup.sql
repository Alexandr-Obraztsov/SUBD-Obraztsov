USE master;
GO

IF DB_ID(N'ProjectDB_Lab4') IS NULL
BEGIN
    RAISERROR('База ProjectDB_Lab4 не найдена. Сначала выполните 01_prepare_projectdb_lab4.sql на sql1.', 16, 1);
    RETURN;
END;
GO

-- Переводим ProjectDB_Lab4 в FULL recovery model
ALTER DATABASE [ProjectDB_Lab4] SET RECOVERY FULL WITH NO_WAIT;
GO

-- Полный бэкап базы ProjectDB_Lab4 (уже в FULL recovery model)
BACKUP DATABASE [ProjectDB_Lab4]
TO DISK = N'/var/opt/mssql/backup/ProjectDB_Lab4_full_1.bak'
WITH
    FORMAT,
    INIT,
    COMPRESSION,
    STATS = 10;
GO

-- Первый лог-бэкап после полного бэкапа
BACKUP LOG [ProjectDB_Lab4]
TO DISK = N'/var/opt/mssql/backup/ProjectDB_Lab4_log_1.trn'
WITH
    INIT,
    COMPRESSION,
    STATS = 10;
GO

