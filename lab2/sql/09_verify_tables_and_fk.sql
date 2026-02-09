
USE [ProjectDB_Lab2];
GO

-- Количество таблиц в dbo
SELECT COUNT(*) AS table_count FROM sys.tables WHERE schema_id = SCHEMA_ID(N'dbo');
GO

-- Список таблиц
SELECT name AS table_name FROM sys.tables WHERE schema_id = SCHEMA_ID(N'dbo') ORDER BY name;
GO

-- Внешние ключи (не менее 2)
SELECT
    fk.name AS fk_name,
    OBJECT_NAME(fk.parent_object_id) AS table_name,
    OBJECT_NAME(fk.referenced_object_id) AS referenced_table
FROM sys.foreign_keys fk
WHERE fk.schema_id = SCHEMA_ID(N'dbo')
ORDER BY fk.name;
GO
