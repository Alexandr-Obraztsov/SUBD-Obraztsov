
USE master;
GO

ALTER DATABASE [ProjectDB_Lab2]
ADD FILEGROUP FG_DATA2;
GO

ALTER DATABASE [ProjectDB_Lab2]
ADD FILE (
    NAME = N'ProjectDB_Lab2_fg2_1',
    FILENAME = N'/var/opt/mssql/additionaldata/ProjectDB_Lab2_fg2_1.ndf',
    SIZE = 50MB,
    FILEGROWTH = 10MB
) TO FILEGROUP FG_DATA2;
GO

ALTER DATABASE [ProjectDB_Lab2]
ADD FILE (
    NAME = N'ProjectDB_Lab2_fg2_2',
    FILENAME = N'/var/opt/mssql/additionaldata/ProjectDB_Lab2_fg2_2.ndf',
    SIZE = 50MB,
    FILEGROWTH = 10MB
) TO FILEGROUP FG_DATA2;
GO
