-- Лабораторная №3: включение TDE (Transparent Data Encryption)
-- master key → сертификат → database encryption key → ENCRYPTION ON
-- Выполнять на первом экземпляре (sql1)

USE master;
GO

-- 1. Database Master Key в master (если ещё нет — при повторном запуске ошибку игнорируем)
BEGIN TRY
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = N'Lab3_MasterKey_Pwd!Str0ng';
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() != 15578  -- "There is already a master key"
        THROW;
END CATCH
GO

-- 2. Сертификат для TDE
IF EXISTS (SELECT * FROM sys.certificates WHERE name = N'Lab3_TDE_Cert')
    DROP CERTIFICATE [Lab3_TDE_Cert];
GO

CREATE CERTIFICATE [Lab3_TDE_Cert]
WITH SUBJECT = N'TDE Certificate for ProjectDB_Lab2',
     EXPIRY_DATE = N'2030-12-31';
GO

-- 3. Database Encryption Key в ProjectDB_Lab2
USE [ProjectDB_Lab2];
GO

IF EXISTS (SELECT * FROM sys.dm_database_encryption_keys WHERE database_id = DB_ID(N'ProjectDB_Lab2'))
BEGIN
    ALTER DATABASE [ProjectDB_Lab2] SET ENCRYPTION OFF;
    DROP DATABASE ENCRYPTION KEY;
END
GO

CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_256
ENCRYPTION BY SERVER CERTIFICATE [Lab3_TDE_Cert];
GO

ALTER DATABASE [ProjectDB_Lab2] SET ENCRYPTION ON;
GO

-- 4. Экспорт сертификата и ключа в общий каталог backup (для переноса на sql2)
USE master;
GO

-- Пароль для защиты файла ключа (тот же нужен при импорте на sql2)
BACKUP CERTIFICATE [Lab3_TDE_Cert]
TO FILE = N'/var/opt/mssql/backup/Lab3_TDE_Cert.cer'
WITH PRIVATE KEY (
    FILE = N'/var/opt/mssql/backup/Lab3_TDE_Cert.pvk',
    ENCRYPTION BY PASSWORD = N'Lab3_Cert_Export_Pwd!'
);
GO

-- Проверка состояния шифрования
-- SELECT DB_NAME(database_id) AS db_name, encryption_state, key_algorithm
-- FROM sys.dm_database_encryption_keys;
