
USE master;
GO

IF DB_ID(N'ProjectDB_Lab2') IS NOT NULL
BEGIN
    ALTER DATABASE [ProjectDB_Lab2] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [ProjectDB_Lab2];
END
GO

CREATE DATABASE [ProjectDB_Lab2]
ON PRIMARY (
    NAME = N'ProjectDB_Lab2',
    FILENAME = N'/var/opt/mssql/data/ProjectDB_Lab2.mdf',
    SIZE = 50MB,
    FILEGROWTH = 5MB
)
LOG ON (
    NAME = N'ProjectDB_Lab2_log',
    FILENAME = N'/var/opt/mssql/data/ProjectDB_Lab2_log.ldf',
    SIZE = 5MB,
    FILEGROWTH = 1MB
);
GO
