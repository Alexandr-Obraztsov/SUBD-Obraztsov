IF DB_ID(N'lab1') IS NULL
BEGIN
    CREATE DATABASE [lab1];
END
GO

USE [lab1];
GO

DROP TABLE IF EXISTS dbo.ChatTasks;
DROP TABLE IF EXISTS dbo.ChatRoles;
DROP TABLE IF EXISTS dbo.UserChatRoles;
DROP TABLE IF EXISTS dbo.Tasks;
DROP TABLE IF EXISTS dbo.Labels;
DROP TABLE IF EXISTS dbo.Roles;
DROP TABLE IF EXISTS dbo.Chats;
DROP TABLE IF EXISTS dbo.Users;
GO

CREATE TABLE dbo.Users (
    UserId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    TelegramId BIGINT NOT NULL,
    Username NVARCHAR(100) NOT NULL,
    PhotoUrl NVARCHAR(2048) NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE TABLE dbo.Chats (
    ChatId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Title NVARCHAR(200) NOT NULL,
    TelegramMessageId BIGINT NULL,
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
    Color NVARCHAR(50) NOT NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedAt DATETIME2 NULL,
    CONSTRAINT FK_Labels_Chat FOREIGN KEY (ChatId) REFERENCES dbo.Chats(ChatId)
);

CREATE TABLE dbo.Tasks (
    TaskId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Title NVARCHAR(200) NOT NULL,
    Description NVARCHAR(1000) NULL,
    ChatId INT NOT NULL,
    UserId INT NOT NULL,
    RoleId INT NOT NULL,
    LabelId INT NOT NULL,
    Deadline DATETIME2 NULL,
    Status NVARCHAR(50) NOT NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_Tasks_Chat FOREIGN KEY (ChatId) REFERENCES dbo.Chats(ChatId),
    CONSTRAINT FK_Tasks_User FOREIGN KEY (UserId) REFERENCES dbo.Users(UserId),
    CONSTRAINT FK_Tasks_Role FOREIGN KEY (RoleId) REFERENCES dbo.Roles(RoleId),
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

CREATE TABLE dbo.ChatRoles (
    ChatRoleId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ChatId INT NOT NULL,
    RoleId INT NOT NULL,
    CONSTRAINT FK_ChatRoles_Chat FOREIGN KEY (ChatId) REFERENCES dbo.Chats(ChatId),
    CONSTRAINT FK_ChatRoles_Role FOREIGN KEY (RoleId) REFERENCES dbo.Roles(RoleId)
);

CREATE TABLE dbo.ChatTasks (
    ChatTaskId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ChatId INT NOT NULL,
    TaskId INT NOT NULL,
    CONSTRAINT FK_ChatTasks_Chat FOREIGN KEY (ChatId) REFERENCES dbo.Chats(ChatId),
    CONSTRAINT FK_ChatTasks_Task FOREIGN KEY (TaskId) REFERENCES dbo.Tasks(TaskId)
);

INSERT INTO dbo.Users (TelegramId, Username, PhotoUrl, CreatedAt)
VALUES
    (10001, N'Алексей_Петров', N'https://example.com/aleksey.jpg', SYSUTCDATETIME()),
    (10002, N'Мария_Иванова', NULL, SYSUTCDATETIME()),
    (10003, N'Дмитрий_Сидоров', N'https://example.com/dmitry.jpg', SYSUTCDATETIME()),
    (10004, N'Елена_Козлова', NULL, SYSUTCDATETIME()),
    (10005, N'Сергей_Новиков', N'https://example.com/sergey.jpg', SYSUTCDATETIME());

INSERT INTO dbo.Chats (Title, TelegramMessageId, CreatedAt)
VALUES
    (N'Проект СУБД', 5550001, SYSUTCDATETIME()),
    (N'Учебная группа БГУИР', 5550002, SYSUTCDATETIME()),
    (N'Рабочие задачи', 5550003, SYSUTCDATETIME());

INSERT INTO dbo.Roles (Name)
VALUES
    (N'Администратор'),
    (N'Участник'),
    (N'Модератор');

INSERT INTO dbo.Labels (ChatId, Name, Color, CreatedAt, UpdatedAt)
VALUES
    (1, N'Важное', N'red', SYSUTCDATETIME(), SYSUTCDATETIME()),
    (1, N'Позже', N'blue', SYSUTCDATETIME(), SYSUTCDATETIME()),
    (1, N'Срочно', N'orange', SYSUTCDATETIME(), SYSUTCDATETIME()),
    (2, N'Общее', N'green', SYSUTCDATETIME(), SYSUTCDATETIME()),
    (2, N'Лабораторные', N'purple', SYSUTCDATETIME(), SYSUTCDATETIME()),
    (3, N'В работе', N'teal', SYSUTCDATETIME(), SYSUTCDATETIME());

INSERT INTO dbo.Tasks (Title, Description, ChatId, UserId, RoleId, LabelId, Deadline, Status, CreatedAt)
VALUES
    (N'Написать отчёт по лабораторной 1', N'Оформить отчёт по настройке SQL Server и созданию схемы БД', 1, 1, 1, 1, DATEADD(day, 3, SYSUTCDATETIME()), N'Открыто', SYSUTCDATETIME()),
    (N'Проверить задания в чате', N'Проверить выполненные задания участников учебной группы', 2, 2, 2, 4, DATEADD(day, 5, SYSUTCDATETIME()), N'В работе', SYSUTCDATETIME()),
    (N'Подготовить презентацию', N'Сделать слайды по теме нормализации баз данных', 1, 3, 2, 2, DATEADD(day, 7, SYSUTCDATETIME()), N'Открыто', SYSUTCDATETIME()),
    (N'Исправить баги в скриптах', N'Найти и исправить ошибки в SQL-скриптах инициализации', 1, 1, 1, 3, DATEADD(day, 1, SYSUTCDATETIME()), N'В работе', SYSUTCDATETIME()),
    (N'Сдать лабораторную работу 2', N'Выполнить вторую лабораторную по запросам и индексам', 2, 4, 2, 5, DATEADD(day, 10, SYSUTCDATETIME()), N'Открыто', SYSUTCDATETIME()),
    (N'Настроить репликацию', N'Настроить репликацию между sql1 и sql2 в Docker', 3, 5, 1, 6, DATEADD(day, 14, SYSUTCDATETIME()), N'Открыто', SYSUTCDATETIME());

INSERT INTO dbo.UserChatRoles (UserId, ChatId, RoleId)
VALUES
    (1, 1, 1),
    (1, 3, 1),
    (2, 1, 2),
    (2, 2, 2),
    (3, 1, 2),
    (4, 2, 2),
    (5, 2, 3),
    (5, 3, 1);

INSERT INTO dbo.ChatRoles (ChatId, RoleId)
VALUES
    (1, 1),
    (1, 2),
    (2, 2),
    (2, 3),
    (3, 1);

INSERT INTO dbo.ChatTasks (ChatId, TaskId)
VALUES
    (1, 1),
    (1, 3),
    (1, 4),
    (2, 2),
    (2, 5),
    (3, 6);
