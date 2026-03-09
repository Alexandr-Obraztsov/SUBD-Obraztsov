-- Лабораторная №3: пользователи и права по ролевой модели
-- 5 DEV (read/write), 2 QA (read only на DEV, read/write на TEST),
-- application service (read/write/update), maintenance (db_owner без DROP DATABASE),
-- backup user (backup database без чтения данных)
-- Требуется: mixed mode (SQL auth). Пароли — для учебных целей.

USE master;
GO

-- Пароли для учебной среды (в проде — хранить в секретах). Литерал для совместимости с sqlcmd (GO разбивает батчи).
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = N'dev1') CREATE LOGIN [dev1] WITH PASSWORD = N'Lab3_Secure1!', CHECK_POLICY = OFF;
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = N'dev2') CREATE LOGIN [dev2] WITH PASSWORD = N'Lab3_Secure1!', CHECK_POLICY = OFF;
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = N'dev3') CREATE LOGIN [dev3] WITH PASSWORD = N'Lab3_Secure1!', CHECK_POLICY = OFF;
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = N'dev4') CREATE LOGIN [dev4] WITH PASSWORD = N'Lab3_Secure1!', CHECK_POLICY = OFF;
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = N'dev5') CREATE LOGIN [dev5] WITH PASSWORD = N'Lab3_Secure1!', CHECK_POLICY = OFF;
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = N'qa1') CREATE LOGIN [qa1] WITH PASSWORD = N'Lab3_Secure1!', CHECK_POLICY = OFF;
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = N'qa2') CREATE LOGIN [qa2] WITH PASSWORD = N'Lab3_Secure1!', CHECK_POLICY = OFF;
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = N'svc_app') CREATE LOGIN [svc_app] WITH PASSWORD = N'Lab3_Secure1!', CHECK_POLICY = OFF;
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = N'svc_maintenance') CREATE LOGIN [svc_maintenance] WITH PASSWORD = N'Lab3_Secure1!', CHECK_POLICY = OFF;
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = N'backup_user') CREATE LOGIN [backup_user] WITH PASSWORD = N'Lab3_Secure1!', CHECK_POLICY = OFF;

GO
-- -------- ProjectDB_Lab2 (DEV) --------
USE [ProjectDB_Lab2];
GO

-- Пользователи
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'dev1') CREATE USER [dev1] FOR LOGIN [dev1];
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'dev2') CREATE USER [dev2] FOR LOGIN [dev2];
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'dev3') CREATE USER [dev3] FOR LOGIN [dev3];
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'dev4') CREATE USER [dev4] FOR LOGIN [dev4];
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'dev5') CREATE USER [dev5] FOR LOGIN [dev5];
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'qa1') CREATE USER [qa1] FOR LOGIN [qa1];
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'qa2') CREATE USER [qa2] FOR LOGIN [qa2];
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'svc_app') CREATE USER [svc_app] FOR LOGIN [svc_app];
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'svc_maintenance') CREATE USER [svc_maintenance] FOR LOGIN [svc_maintenance];
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'backup_user') CREATE USER [backup_user] FOR LOGIN [backup_user];
GO

-- 5 DEV: read/write
ALTER ROLE db_datareader ADD MEMBER [dev1];
ALTER ROLE db_datawriter ADD MEMBER [dev1];
ALTER ROLE db_datareader ADD MEMBER [dev2];
ALTER ROLE db_datawriter ADD MEMBER [dev2];
ALTER ROLE db_datareader ADD MEMBER [dev3];
ALTER ROLE db_datawriter ADD MEMBER [dev3];
ALTER ROLE db_datareader ADD MEMBER [dev4];
ALTER ROLE db_datawriter ADD MEMBER [dev4];
ALTER ROLE db_datareader ADD MEMBER [dev5];
ALTER ROLE db_datawriter ADD MEMBER [dev5];

-- 2 QA: read only на DEV
ALTER ROLE db_datareader ADD MEMBER [qa1];
ALTER ROLE db_datareader ADD MEMBER [qa2];

-- Application service: read/write/update
ALTER ROLE db_datareader ADD MEMBER [svc_app];
ALTER ROLE db_datawriter ADD MEMBER [svc_app];

-- Maintenance: db_owner (без DROP DATABASE — ограничение на уровне сервера или политики)
ALTER ROLE db_owner ADD MEMBER [svc_maintenance];

-- Backup user: только резервное копирование, без чтения данных
ALTER ROLE db_backupoperator ADD MEMBER [backup_user];
GO

-- -------- ProjectDB_Test (TEST) — QA read/write/update --------
USE [ProjectDB_Test];
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'qa1') CREATE USER [qa1] FOR LOGIN [qa1];
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'qa2') CREATE USER [qa2] FOR LOGIN [qa2];
GO

ALTER ROLE db_datareader ADD MEMBER [qa1];
ALTER ROLE db_datawriter ADD MEMBER [qa1];
ALTER ROLE db_datareader ADD MEMBER [qa2];
ALTER ROLE db_datawriter ADD MEMBER [qa2];
GO

USE master;
GO

-- Проверка: список логинов и ролей в ProjectDB_Lab2
-- SELECT dp.name, STRING_AGG(r.name, ', ') AS roles
-- FROM sys.database_principals dp
-- LEFT JOIN sys.database_role_members drm ON drm.member_principal_id = dp.principal_id
-- LEFT JOIN sys.database_principals r ON r.principal_id = drm.role_principal_id
-- WHERE dp.type IN ('S','U') AND dp.name NOT IN ('dbo','guest','sys','INFORMATION_SCHEMA')
-- GROUP BY dp.name;
