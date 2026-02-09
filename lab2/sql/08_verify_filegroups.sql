
USE [ProjectDB_Lab2];
GO

-- Файлы базы и их файлгруппы
SELECT
    f.name AS logical_name,
    fg.name AS filegroup_name,
    f.physical_name,
    f.size * 8 / 1024 AS size_mb,
    f.growth * 8 / 1024 AS growth_mb
FROM sys.database_files f
LEFT JOIN sys.filegroups fg ON f.data_space_id = fg.data_space_id
ORDER BY f.file_id;
GO

-- Размещение таблиц по файлгруппам
SELECT
    t.name AS table_name,
    fg.name AS filegroup_name
FROM sys.tables t
INNER JOIN sys.indexes i ON t.object_id = i.object_id AND i.index_id <= 1
INNER JOIN sys.data_spaces ds ON i.data_space_id = ds.data_space_id
LEFT JOIN sys.filegroups fg ON ds.data_space_id = fg.data_space_id
WHERE t.schema_id = SCHEMA_ID(N'dbo')
ORDER BY t.name;
GO
