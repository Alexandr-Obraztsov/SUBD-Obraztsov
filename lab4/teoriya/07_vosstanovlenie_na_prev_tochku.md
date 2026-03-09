# Восстановление на предыдущую точку цепочки (N−1)

## Теория

Восстановление на N−1 означает привести базу к состоянию **до** последнего применённого бэкапа. Например, если полная цепочка — full → diff1 → diff2 → diff3, то состояние N−1 получается применением только full → diff1 → diff2 и завершением восстановления (RECOVERY) после diff2; diff3 не применяется. В результате в базе будут изменения из diff1 и diff2, но не из diff3 — что наглядно видно по данным (например, в таблице Tasks не будет последней добавленной записи).

Такой сценарий демонстрирует возможность отката к предыдущей точке и важен для понимания цепочки дифференциальных бэкапов. При использовании лог-бэкапов аналогичная идея реализуется через point-in-time restore (STOPAT).

---

## Как это сделано в лабораторной

На втором экземпляре выполняется восстановление только до diff2; после diff2 указывается RECOVERY, diff3 не применяется:

```sql
RESTORE DATABASE [ProjectDB_Lab4]
FROM DISK = N'/var/opt/mssql/backup/ProjectDB_Lab4_full_1.bak'
WITH
    MOVE N'ProjectDB_Lab2' TO N'/var/opt/mssql/data/ProjectDB_Lab4_sql2.mdf',
    MOVE N'ProjectDB_Lab2_log' TO N'/var/opt/mssql/data/ProjectDB_Lab4_sql2_log.ldf',
    NORECOVERY,
    REPLACE,
    STATS = 10;
GO

RESTORE DATABASE [ProjectDB_Lab4]
FROM DISK = N'/var/opt/mssql/backup/ProjectDB_Lab4_diff_1.bak'
WITH NORECOVERY, STATS = 10;
GO

RESTORE DATABASE [ProjectDB_Lab4]
FROM DISK = N'/var/opt/mssql/backup/ProjectDB_Lab4_diff_2.bak'
WITH RECOVERY, STATS = 10;
GO
```

Проверка: в таблице Tasks две строки (как после diff2), третья запись (Task_Lab4_3) отсутствует:

```sql
USE [ProjectDB_Lab4];
GO
SELECT * FROM dbo.Tasks ORDER BY TaskId;
-- Ожидаемо: 2 строки (Task 1, Task 2), без Task_Lab4_3
GO
```

Сравнение с результатом полного восстановления (full + diff1 + diff2 + diff3) подтверждает различие состояний N и N−1.
