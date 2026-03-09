# Восстановление на другом экземпляре: MOVE и REPLACE

## Теория

На другом сервере (или в другом каталоге) пути к файлам данных и журнала обычно не совпадают с теми, что были при создании бэкапа. В бэкапе хранятся **логические** имена файлов и их пути на момент бэкапа. При восстановлении нужно указать новые физические пути с помощью **MOVE**: для каждого логического имени файла — целевой путь на новом сервере.

Узнать логические имена можно без восстановления базы:
```sql
RESTORE FILELISTONLY FROM DISK = N'/var/opt/mssql/backup/ProjectDB_Lab4_full_1.bak';
```

Если база с таким именем на целевом сервере уже существует и её нужно заменить, в первом RESTORE добавляют **REPLACE**. Перед этим базу при необходимости сбрасывают (SINGLE_USER, DROP).

---

## Как это сделано в лабораторной

На втором экземпляре (sql2) база ProjectDB_Lab4 восстанавливается из бэкапов, созданных на sql1. Логические имена файлов в бэкапе соответствуют исходной базе (ProjectDB_Lab2), физические пути на sql2 задаются свои:

```sql
IF DB_ID(N'ProjectDB_Lab4') IS NOT NULL
BEGIN
    ALTER DATABASE [ProjectDB_Lab4] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [ProjectDB_Lab4];
END;
GO

RESTORE DATABASE [ProjectDB_Lab4]
FROM DISK = N'/var/opt/mssql/backup/ProjectDB_Lab4_full_1.bak'
WITH
    MOVE N'ProjectDB_Lab2' TO N'/var/opt/mssql/data/ProjectDB_Lab4_sql2.mdf',
    MOVE N'ProjectDB_Lab2_log' TO N'/var/opt/mssql/data/ProjectDB_Lab4_sql2_log.ldf',
    NORECOVERY,
    REPLACE,
    STATS = 10;
GO
```

`REPLACE` позволяет перезаписать файлы, если они остались от предыдущего запуска. Дальнейшие RESTORE (diff1, diff2, diff3) не требуют MOVE — файлы уже созданы первым RESTORE.

Проверка данных после восстановления:

```sql
USE [ProjectDB_Lab4];
GO
SELECT * FROM dbo.Users ORDER BY UserId;
SELECT * FROM dbo.Chats ORDER BY ChatId;
SELECT * FROM dbo.Tasks ORDER BY TaskId;
GO
```
