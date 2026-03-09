-- Лабораторная №3: Server Audit (target: FILE) и Database Audit Specification
-- Фиксация подключений и обращений к базе; результаты в файл в /var/opt/mssql/audit

USE master;
GO

-- Удалить существующие объекты при повторном запуске (сначала отключить DB spec в контексте БД)
USE [ProjectDB_Lab2];
GO
IF EXISTS (SELECT * FROM sys.database_audit_specifications WHERE name = N'Lab3_DB_Audit_Spec')
BEGIN
    ALTER DATABASE AUDIT SPECIFICATION [Lab3_DB_Audit_Spec] WITH (STATE = OFF);
    DROP DATABASE AUDIT SPECIFICATION [Lab3_DB_Audit_Spec];
END
GO
USE master;
GO

IF EXISTS (SELECT * FROM sys.server_audit_specifications WHERE name = N'Lab3_Server_Audit_Spec')
BEGIN
    ALTER SERVER AUDIT SPECIFICATION [Lab3_Server_Audit_Spec] WITH (STATE = OFF);
    DROP SERVER AUDIT SPECIFICATION [Lab3_Server_Audit_Spec];
END
GO

IF EXISTS (SELECT * FROM sys.server_audits WHERE name = N'Lab3_Security_Audit')
BEGIN
    ALTER SERVER AUDIT [Lab3_Security_Audit] WITH (STATE = OFF);
    DROP SERVER AUDIT [Lab3_Security_Audit];
END
GO

-- 1. Server Audit — запись в файл (каталог смонтирован с хоста)
CREATE SERVER AUDIT [Lab3_Security_Audit]
TO FILE
(
    FILEPATH = N'/var/opt/mssql/audit',
    MAXSIZE = 50 MB,
    MAX_ROLLOVER_FILES = 5,
    RESERVE_DISK_SPACE = OFF
)
WITH
(
    QUEUE_DELAY = 1000,
    ON_FAILURE = CONTINUE
);
GO

-- 2. Server Audit Specification — успешные и неуспешные входы
CREATE SERVER AUDIT SPECIFICATION [Lab3_Server_Audit_Spec]
FOR SERVER AUDIT [Lab3_Security_Audit]
ADD (SUCCESSFUL_LOGIN_GROUP),
ADD (FAILED_LOGIN_GROUP),
ADD (LOGOUT_GROUP)
WITH (STATE = ON);
GO

ALTER SERVER AUDIT [Lab3_Security_Audit] WITH (STATE = ON);
GO

-- 3. Database Audit Specification — доступ к данным (SELECT, INSERT, UPDATE, DELETE) в ProjectDB_Lab2
USE [ProjectDB_Lab2];
GO

CREATE DATABASE AUDIT SPECIFICATION [Lab3_DB_Audit_Spec]
FOR SERVER AUDIT [Lab3_Security_Audit]
ADD (SELECT ON Schema::dbo BY public),
ADD (INSERT ON Schema::dbo BY public),
ADD (UPDATE ON Schema::dbo BY public),
ADD (DELETE ON Schema::dbo BY public)
WITH (STATE = ON);
GO

-- Проверка: список аудитов
-- SELECT name, type_desc, is_state_enabled FROM sys.server_audits;
-- Просмотр журнала: sys.fn_get_audit_file('/var/opt/mssql/audit/*.sqlaudit', default, default);
