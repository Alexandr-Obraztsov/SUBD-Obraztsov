
USE [ProjectDB_Lab2];
GO

INSERT INTO dbo.Users (Username, CreatedAt) VALUES
    (N'User1', SYSUTCDATETIME()),
    (N'User2', SYSUTCDATETIME());

INSERT INTO dbo.Chats (Title, CreatedAt) VALUES
    (N'Chat A', SYSUTCDATETIME()),
    (N'Chat B', SYSUTCDATETIME());

INSERT INTO dbo.Roles (Name) VALUES (N'Admin'), (N'Member');

INSERT INTO dbo.Labels (ChatId, Name) VALUES
    (1, N'Important'),
    (1, N'Later'),
    (2, N'General');

INSERT INTO dbo.Tasks (Title, ChatId, UserId, LabelId, CreatedAt) VALUES
    (N'Task 1', 1, 1, 1, SYSUTCDATETIME()),
    (N'Task 2', 2, 2, 3, SYSUTCDATETIME());

INSERT INTO dbo.UserChatRoles (UserId, ChatId, RoleId) VALUES
    (1, 1, 1), (2, 1, 2), (2, 2, 2);

INSERT INTO dbo.ChatTasks (ChatId, TaskId) VALUES (1, 1), (2, 2);
GO
