# Дифференциальная резервная копия (DIFFERENTIAL backup)

## Теория

Дифференциальный бэкап копирует только те данные (экстенты), которые изменились с момента **последнего полного** бэкапа. Каждый следующий дифференциальный бэкап включает все изменения с того же полного бэкапа: diff2 содержит изменения из diff1 плюс новые. При восстановлении достаточно применить один полный и **последний** дифференциальный бэкап; для наглядности цепочки в лабораторной применяются diff1 → diff2 → diff3 по порядку.

Ключевой параметр: **WITH DIFFERENTIAL**. Остальные (FORMAT, INIT, COMPRESSION, STATS) — как у полного бэкапа.

---

## Как это сделано в лабораторной

После каждого набора изменений в одной из таблиц выполняется дифференциальный бэкап. Три набора: Users, Chats, Tasks.

Изменения в таблице Users и первый дифференциальный бэкап:

```sql
USE [ProjectDB_Lab4];
GO

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
```

Аналогично для Chats (diff_2) и Tasks (diff_3):

```sql
INSERT INTO dbo.Chats (Title)
VALUES (N'Chat_Lab4_2');
GO
-- ... SELECT до/после ...
BACKUP DATABASE [ProjectDB_Lab4]
TO DISK = N'/var/opt/mssql/backup/ProjectDB_Lab4_diff_2.bak'
WITH DIFFERENTIAL, FORMAT, INIT, COMPRESSION, STATS = 10;
GO

INSERT INTO dbo.Tasks (Title, ChatId, UserId, LabelId)
VALUES (N'Task_Lab4_3', 1, 1, 1);
GO
-- ... SELECT до/после ...
BACKUP DATABASE [ProjectDB_Lab4]
TO DISK = N'/var/opt/mssql/backup/ProjectDB_Lab4_diff_3.bak'
WITH DIFFERENTIAL, FORMAT, INIT, COMPRESSION, STATS = 10;
GO
```

В результате получается цепочка: full_1 → log_1 → diff_1 → diff_2 → diff_3.
