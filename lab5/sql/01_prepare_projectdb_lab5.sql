USE master;
GO

IF DB_ID(N'ProjectDB_Lab2') IS NULL
BEGIN
    RAISERROR(N'Исходная база ProjectDB_Lab2 не найдена. Выполните скрипты лабораторной №2 (03_create_projectdb_lab2.sql, 04_add_filegroup.sql, 05_schema.sql, 06_seed.sql) на sql1.', 16, 1);
    RETURN;
END;
GO

-- Если ProjectDB_Lab5 уже существует — удаляем для повторного прогонки сценария
IF DB_ID(N'ProjectDB_Lab5') IS NOT NULL
BEGIN
    ALTER DATABASE [ProjectDB_Lab5] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [ProjectDB_Lab5];
END;
GO

-- Полный бэкап исходной базы ProjectDB_Lab2 в общий каталог бэкапов
BACKUP DATABASE [ProjectDB_Lab2]
TO DISK = N'/var/opt/mssql/backup/ProjectDB_Lab2_full_for_lab5.bak'
WITH
    FORMAT,
    INIT,
    COMPRESSION,
    STATS = 10;
GO

-- Восстановление ProjectDB_Lab5 из полного бэкапа ProjectDB_Lab2
RESTORE DATABASE [ProjectDB_Lab5]
FROM DISK = N'/var/opt/mssql/backup/ProjectDB_Lab2_full_for_lab5.bak'
WITH
    MOVE N'ProjectDB_Lab2'         TO N'/var/opt/mssql/data/ProjectDB_Lab5.mdf',
    MOVE N'ProjectDB_Lab2_log'     TO N'/var/opt/mssql/data/ProjectDB_Lab5_log.ldf',
    MOVE N'ProjectDB_Lab2_fg2_1'   TO N'/var/opt/mssql/additionaldata/ProjectDB_Lab5_fg2_1.ndf',
    MOVE N'ProjectDB_Lab2_fg2_2'   TO N'/var/opt/mssql/additionaldata/ProjectDB_Lab5_fg2_2.ndf',
    REPLACE,
    RECOVERY,
    STATS = 10;
GO

ALTER DATABASE [ProjectDB_Lab5] SET RECOVERY FULL WITH NO_WAIT;
GO

-- Начальный полный бэкап ProjectDB_Lab5 для log shipping
BACKUP DATABASE [ProjectDB_Lab5]
TO DISK = N'/var/opt/mssql/backup/ProjectDB_Lab5_full_1.bak'
WITH
    INIT,
    COMPRESSION,
    STATS = 10;
GO

