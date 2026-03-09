USE master;
GO

-- Восстановление ProjectDB_Lab4 на втором экземпляре (sql2)
-- в состояние N-1 (до последнего набора изменений / дифференциального бэкапа)

IF DB_ID(N'ProjectDB_Lab4') IS NOT NULL
BEGIN
    ALTER DATABASE [ProjectDB_Lab4] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [ProjectDB_Lab4];
END;
GO

RESTORE DATABASE [ProjectDB_Lab4]
FROM DISK = N'/var/opt/mssql/backup/ProjectDB_Lab4_full_1.bak'
WITH
    -- Логические имена файлов берутся от исходной базы ProjectDB_Lab2
    -- На втором экземпляре используем отдельные файлы данных/журнала
    MOVE N'ProjectDB_Lab2' TO N'/var/opt/mssql/data/ProjectDB_Lab4_sql2.mdf',
    MOVE N'ProjectDB_Lab2_log' TO N'/var/opt/mssql/data/ProjectDB_Lab4_sql2_log.ldf',
    NORECOVERY,
    REPLACE,
    STATS = 10;
GO

RESTORE DATABASE [ProjectDB_Lab4]
FROM DISK = N'/var/opt/mssql/backup/ProjectDB_Lab4_diff_1.bak'
WITH NORECOVERY, STATS = 10;
GO

RESTORE DATABASE [ProjectDB_Lab4]
FROM DISK = N'/var/opt/mssql/backup/ProjectDB_Lab4_diff_2.bak'
WITH RECOVERY, STATS = 10;
GO

-- Проверка различий: состояние N-1 (без третьего набора изменений)
USE [ProjectDB_Lab4];
GO

SELECT 'sql2_N_minus_1_Users' AS Info, * FROM dbo.Users ORDER BY UserId;
SELECT 'sql2_N_minus_1_Chats' AS Info, * FROM dbo.Chats ORDER BY ChatId;
SELECT 'sql2_N_minus_1_Tasks' AS Info, * FROM dbo.Tasks ORDER BY TaskId;
GO

