USE [ProjectDB_Lab5];
GO

SELECT
    db_name() AS DatabaseName,
    recovery_model_desc,
    state_desc
FROM sys.databases
WHERE name = N'ProjectDB_Lab5';
GO

SELECT TOP (10) *
FROM dbo.Tasks
ORDER BY TaskId DESC;
GO
