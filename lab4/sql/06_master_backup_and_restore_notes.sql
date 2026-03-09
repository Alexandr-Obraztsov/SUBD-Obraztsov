 
USE master;
GO

BACKUP DATABASE [master]
TO DISK = N'/var/opt/mssql/backup/master_full_for_lab4.bak'
WITH
    FORMAT,
    INIT,
    COMPRESSION,
    STATS = 20;
GO
