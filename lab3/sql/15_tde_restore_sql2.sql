-- Лабораторная №3: восстановление TDE-базы на второй экземпляр (sql2)
-- Выполнять на sql2. Предварительно: скопировать .bak, .cer и .pvk в /var/opt/mssql/backup (уже в общем томе).

USE master;
GO

-- 1. Master Key в master на sql2 (если ещё нет)
IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = N'##MS_DatabaseMasterKey##')
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = N'Lab3_MasterKey_Pwd!Str0ng';
GO

-- 2. Импорт сертификата с приватным ключом (экспортирован на sql1)
IF EXISTS (SELECT * FROM sys.certificates WHERE name = N'Lab3_TDE_Cert')
    DROP CERTIFICATE [Lab3_TDE_Cert];
GO

CREATE CERTIFICATE [Lab3_TDE_Cert]
FROM FILE = N'/var/opt/mssql/backup/Lab3_TDE_Cert.cer'
WITH PRIVATE KEY (
    FILE = N'/var/opt/mssql/backup/Lab3_TDE_Cert.pvk',
    DECRYPTION BY PASSWORD = N'Lab3_Cert_Export_Pwd!'
);
GO

-- 3. Восстановление базы из сжатого бэкапа
IF DB_ID(N'ProjectDB_Lab2') IS NOT NULL
BEGIN
    ALTER DATABASE [ProjectDB_Lab2] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [ProjectDB_Lab2];
END
GO

-- Только primary и log (если в бэкапе есть FG_DATA2 — раскомментируйте MOVE для fg2_1 и fg2_2)
RESTORE DATABASE [ProjectDB_Lab2]
FROM DISK = N'/var/opt/mssql/backup/ProjectDB_Lab2_TDE.bak'
WITH
    MOVE N'ProjectDB_Lab2' TO N'/var/opt/mssql/data/ProjectDB_Lab2.mdf',
    MOVE N'ProjectDB_Lab2_log' TO N'/var/opt/mssql/data/ProjectDB_Lab2_log.ldf',
    REPLACE,
    STATS = 10;
GO

-- Проверка: шифрование и доступность
-- SELECT DB_NAME(database_id), encryption_state FROM sys.dm_database_encryption_keys WHERE database_id = DB_ID(N'ProjectDB_Lab2');
-- USE ProjectDB_Lab2; SELECT COUNT(*) FROM dbo.Users;
