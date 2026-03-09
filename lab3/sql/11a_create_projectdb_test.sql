-- Создание тестовой БД для роли QA (read/write/update на TEST)
-- Схема совпадает с ProjectDB_Lab2 для единообразия

USE master;
GO

IF DB_ID(N'ProjectDB_Test') IS NOT NULL
BEGIN
    ALTER DATABASE [ProjectDB_Test] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [ProjectDB_Test];
END
GO

CREATE DATABASE [ProjectDB_Test]
ON PRIMARY (
    NAME = N'ProjectDB_Test',
    FILENAME = N'/var/opt/mssql/data/ProjectDB_Test.mdf',
    SIZE = 50MB,
    FILEGROWTH = 5MB
)
LOG ON (
    NAME = N'ProjectDB_Test_log',
    FILENAME = N'/var/opt/mssql/data/ProjectDB_Test_log.ldf',
    SIZE = 5MB,
    FILEGROWTH = 1MB
);
GO

USE [ProjectDB_Test];
GO

-- Та же схема, что в 05_schema.sql (минимально для QA)
CREATE TABLE dbo.Users (
    UserId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Username NVARCHAR(100) NOT NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);
CREATE TABLE dbo.Chats (
    ChatId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Title NVARCHAR(200) NOT NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);
CREATE TABLE dbo.Roles (
    RoleId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL
);
CREATE TABLE dbo.Labels (
    LabelId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ChatId INT NOT NULL,
    Name NVARCHAR(100) NOT NULL,
    CONSTRAINT FK_Labels_Chat FOREIGN KEY (ChatId) REFERENCES dbo.Chats(ChatId)
);
CREATE TABLE dbo.Tasks (
    TaskId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Title NVARCHAR(200) NOT NULL,
    ChatId INT NOT NULL,
    UserId INT NOT NULL,
    LabelId INT NOT NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_Tasks_Chat FOREIGN KEY (ChatId) REFERENCES dbo.Chats(ChatId),
    CONSTRAINT FK_Tasks_User FOREIGN KEY (UserId) REFERENCES dbo.Users(UserId),
    CONSTRAINT FK_Tasks_Label FOREIGN KEY (LabelId) REFERENCES dbo.Labels(LabelId)
);
CREATE TABLE dbo.UserChatRoles (
    UserChatRoleId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    UserId INT NOT NULL,
    ChatId INT NOT NULL,
    RoleId INT NOT NULL,
    CONSTRAINT FK_UserChatRoles_User FOREIGN KEY (UserId) REFERENCES dbo.Users(UserId),
    CONSTRAINT FK_UserChatRoles_Chat FOREIGN KEY (ChatId) REFERENCES dbo.Chats(ChatId),
    CONSTRAINT FK_UserChatRoles_Role FOREIGN KEY (RoleId) REFERENCES dbo.Roles(RoleId)
);
CREATE TABLE dbo.ChatTasks (
    ChatTaskId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ChatId INT NOT NULL,
    TaskId INT NOT NULL,
    CONSTRAINT FK_ChatTasks_Chat FOREIGN KEY (ChatId) REFERENCES dbo.Chats(ChatId),
    CONSTRAINT FK_ChatTasks_Task FOREIGN KEY (TaskId) REFERENCES dbo.Tasks(TaskId)
);
GO
