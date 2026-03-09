USE master;
GO

-- Проверяем наличие исходной базы курсового проекта
IF DB_ID(N'ProjectDB_Lab2') IS NULL
BEGIN
    RAISERROR('Исходная база ProjectDB_Lab2 не найдена. Выполните скрипты lab2 (03_create_projectdb_lab2.sql, 05_schema.sql, 06_seed.sql) на sql1.', 16, 1);
    RETURN;
END;
GO

-- Переводим исходную базу в SIMPLE (по условию задания)
ALTER DATABASE [ProjectDB_Lab2] SET RECOVERY SIMPLE WITH NO_WAIT;
GO

-- Полная резервная копия исходной базы ProjectDB_Lab2
BACKUP DATABASE [ProjectDB_Lab2]
TO DISK = N'/var/opt/mssql/backup/ProjectDB_Lab2_full_for_lab4.bak'
WITH
    FORMAT,
    INIT,
    COMPRESSION,
    STATS = 10;
GO

-- Подготовка целевой базы ProjectDB_Lab4
IF DB_ID(N'ProjectDB_Lab4') IS NOT NULL
BEGIN
    ALTER DATABASE [ProjectDB_Lab4] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [ProjectDB_Lab4];
END;
GO

-- Восстановление ProjectDB_Lab4 из full backup исходной базы
RESTORE DATABASE [ProjectDB_Lab4]
FROM DISK = N'/var/opt/mssql/backup/ProjectDB_Lab2_full_for_lab4.bak'
WITH
    MOVE N'ProjectDB_Lab2' TO N'/var/opt/mssql/data/ProjectDB_Lab4.mdf',
    MOVE N'ProjectDB_Lab2_log' TO N'/var/opt/mssql/data/ProjectDB_Lab4_log.ldf',
    REPLACE,
    RECOVERY,
    STATS = 10;
GO

