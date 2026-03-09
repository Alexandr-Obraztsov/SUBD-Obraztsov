-- Лабораторная №3: сжатая резервная копия TDE-базы в общий каталог
-- Выполнять на sql1 после 13_tde_enable.sql

USE master;
GO

BACKUP DATABASE [ProjectDB_Lab2]
TO DISK = N'/var/opt/mssql/backup/ProjectDB_Lab2_TDE.bak'
WITH
    COMPRESSION,
    INIT,
    STATS = 10,
    DESCRIPTION = N'Lab3 TDE compressed backup';
GO
