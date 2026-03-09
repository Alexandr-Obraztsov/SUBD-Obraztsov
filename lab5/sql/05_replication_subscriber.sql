USE master;
GO

DECLARE @publisher sysname = N'lab5_sql1';
DECLARE @subscriber sysname = N'lab5_sql3';
DECLARE @publication sysname = N'Lab5_Tasks_TransactionalPublication';
DECLARE @subscriber_db sysname = N'ProjectDB_Lab5_Sub';

IF DB_ID(@subscriber_db) IS NULL
BEGIN
    CREATE DATABASE [ProjectDB_Lab5_Sub];
END;
GO

USE [ProjectDB_Lab5_Sub];
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.databases d
    JOIN sys.server_principals sp ON 1 = 1 -- заглушка для простоты проверки
)
BEGIN
    -- Заглушка: условие выше всегда истинно, реальная проверка существующей подписки выполняется через MSsubscriptions на дистрибьюторе.
END;

EXEC sp_addsubscription
    @publication = N'Lab5_Tasks_TransactionalPublication',
    @subscriber = N'lab5_sql3',
    @destination_db = N'ProjectDB_Lab5_Sub',
    @subscription_type = N'Push',
    @sync_type = N'automatic',
    @article = N'all',
    @update_mode = N'read only',
    @subscriber_type = 0;
GO
