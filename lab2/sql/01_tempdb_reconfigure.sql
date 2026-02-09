USE master;
GO

ALTER DATABASE tempdb MODIFY FILE (
    NAME = tempdev,
    FILENAME = '/var/opt/mssql/tempdb/tempdb.mdf',
    SIZE = 10MB,
    FILEGROWTH = 5MB
);
GO

ALTER DATABASE tempdb MODIFY FILE (
    NAME = templog,
    FILENAME = '/var/opt/mssql/tempdb/templog.ldf',
    SIZE = 10MB,
    FILEGROWTH = 1MB
);
GO
