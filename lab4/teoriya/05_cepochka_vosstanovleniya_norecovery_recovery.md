# Цепочка восстановления: NORECOVERY и RECOVERY

## Теория

При восстановлении по цепочке из нескольких бэкапов (full + diff или full + log) база после каждого шага, кроме последнего, должна оставаться в состоянии «восстановление», чтобы можно было применить следующий бэкап.

- **NORECOVERY** — база остаётся в режиме восстановления; допускается применение следующего RESTORE (следующего diff или log). Журнал транзакций не откатывается.
- **RECOVERY** — завершение восстановления: откат незавершённых транзакций, база переводится в обычное состояние. После RECOVERY применять к этой цепочке дополнительные бэкапы нельзя.

Правило: все RESTORE в цепочке выполняются с **NORECOVERY**, последний — с **RECOVERY**.

---

## Как это сделано в лабораторной

Восстановление на втором экземпляре до актуального состояния (full → diff1 → diff2 → diff3): первые три шага с NORECOVERY, последний с RECOVERY.

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
WITH NORECOVERY, STATS = 10;
GO

RESTORE DATABASE [ProjectDB_Lab4]
FROM DISK = N'/var/opt/mssql/backup/ProjectDB_Lab4_diff_3.bak'
WITH RECOVERY, STATS = 10;
GO
```

После последнего RESTORE с RECOVERY база доступна для запросов; выполняются проверочные SELECT по таблицам Users, Chats, Tasks.

---

## Восстановление на N−1 (предыдущая точка цепочки)

Состояние N−1 получается применением только full → diff1 → diff2 с RECOVERY после diff2 (diff3 не применяется). В таблице Tasks остаётся 2 строки, запись Task_Lab4_3 отсутствует — различие подтверждается SELECT.
