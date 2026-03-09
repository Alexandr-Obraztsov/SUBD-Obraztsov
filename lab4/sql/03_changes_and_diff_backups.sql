USE [ProjectDB_Lab4];
GO

-- Набор изменений 1: таблица Users
PRINT '=== Change set 1: Users ===';
SELECT 'Before_Users' AS Stage, * FROM dbo.Users ORDER BY UserId;
GO

INSERT INTO dbo.Users (Username)
VALUES (N'User_Lab4_1');
GO

SELECT 'After_Users' AS Stage, * FROM dbo.Users ORDER BY UserId;
GO

BACKUP DATABASE [ProjectDB_Lab4]
TO DISK = N'/var/opt/mssql/backup/ProjectDB_Lab4_diff_1.bak'
WITH
    DIFFERENTIAL,
    FORMAT,
    INIT,
    COMPRESSION,
    STATS = 10;
GO

-- Набор изменений 2: таблица Chats
PRINT '=== Change set 2: Chats ===';
SELECT 'Before_Chats' AS Stage, * FROM dbo.Chats ORDER BY ChatId;
GO

INSERT INTO dbo.Chats (Title)
VALUES (N'Chat_Lab4_2');
GO

SELECT 'After_Chats' AS Stage, * FROM dbo.Chats ORDER BY ChatId;
GO

BACKUP DATABASE [ProjectDB_Lab4]
TO DISK = N'/var/opt/mssql/backup/ProjectDB_Lab4_diff_2.bak'
WITH
    DIFFERENTIAL,
    FORMAT,
    INIT,
    COMPRESSION,
    STATS = 10;
GO

-- Набор изменений 3: таблица Tasks
PRINT '=== Change set 3: Tasks ===';
SELECT 'Before_Tasks' AS Stage, * FROM dbo.Tasks ORDER BY TaskId;
GO

INSERT INTO dbo.Tasks (Title, ChatId, UserId, LabelId)
VALUES (N'Task_Lab4_3', 1, 1, 1);
GO

SELECT 'After_Tasks' AS Stage, * FROM dbo.Tasks ORDER BY TaskId;
GO

BACKUP DATABASE [ProjectDB_Lab4]
TO DISK = N'/var/opt/mssql/backup/ProjectDB_Lab4_diff_3.bak'
WITH
    DIFFERENTIAL,
    FORMAT,
    INIT,
    COMPRESSION,
    STATS = 10;
GO

