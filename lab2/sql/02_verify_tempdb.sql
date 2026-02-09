SELECT name, physical_name, size * 8 / 1024 AS size_mb
FROM sys.master_files
WHERE database_id = 2
ORDER BY file_id;
