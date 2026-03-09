USE [ProjectDB_Lab5];
GO

INSERT INTO dbo.Tasks (Title, ChatId, UserId, LabelId, CreatedAt)
VALUES (N'Task_Lab5_Replication_Test', 1, 1, 1, SYSUTCDATETIME());
GO
