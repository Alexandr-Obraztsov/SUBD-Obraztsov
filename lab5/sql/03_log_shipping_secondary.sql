USE master;
GO

IF DB_ID(N'ProjectDB_Lab5') IS NOT NULL
BEGIN
    IF DATABASEPROPERTYEX(N'ProjectDB_Lab5', 'Status') = 'RESTORING'
    BEGIN
        RESTORE DATABASE [ProjectDB_Lab5] WITH RECOVERY;
    END;

    ALTER DATABASE [ProjectDB_Lab5] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [ProjectDB_Lab5];
END;
GO

RESTORE DATABASE [ProjectDB_Lab5]
FROM DISK = N'/var/opt/mssql/backup/ProjectDB_Lab5_full_1.bak'
WITH
    MOVE N'ProjectDB_Lab2'     TO N'/var/opt/mssql/data/ProjectDB_Lab5_sql2.mdf',
    MOVE N'ProjectDB_Lab2_log' TO N'/var/opt/mssql/data/ProjectDB_Lab5_sql2_log.ldf',
    NORECOVERY,
    REPLACE,
    STATS = 10;
GO

