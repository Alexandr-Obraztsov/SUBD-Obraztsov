-- Просмотр записей SQL Server Audit (фильтрация по пользователям)
-- Путь к файлам аудита должен соответствовать FILEPATH в Server Audit

USE master;
GO

-- Все записи из каталога аудита
SELECT
    event_time,
    server_principal_name,
    database_principal_name,
    object_name,
    statement,
    action_id,
    succeeded
FROM sys.fn_get_audit_file(N'/var/opt/mssql/audit/*.sqlaudit', DEFAULT, DEFAULT)
ORDER BY event_time DESC;

-- Фильтрация по пользователю (замените 'sa' на нужное имя)
-- SELECT event_time, server_principal_name, statement, succeeded
-- FROM sys.fn_get_audit_file(N'/var/opt/mssql/audit/*.sqlaudit', DEFAULT, DEFAULT)
-- WHERE server_principal_name = N'sa'
-- ORDER BY event_time DESC;
