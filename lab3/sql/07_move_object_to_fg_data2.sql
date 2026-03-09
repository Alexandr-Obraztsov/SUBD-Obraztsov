
USE [ProjectDB_Lab2];
GO

CREATE TABLE dbo.Tasks_Archive (
    TaskId INT NOT NULL PRIMARY KEY,
    Title NVARCHAR(200) NOT NULL,
    ChatId INT NOT NULL,
    UserId INT NOT NULL,
    LabelId INT NOT NULL,
    CreatedAt DATETIME2 NOT NULL
) ON FG_DATA2;
GO

INSERT INTO dbo.Tasks_Archive (TaskId, Title, ChatId, UserId, LabelId, CreatedAt)
SELECT TaskId, Title, ChatId, UserId, LabelId, CreatedAt
FROM dbo.Tasks;
GO
