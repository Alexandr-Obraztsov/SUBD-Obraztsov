# Полная резервная копия (FULL backup)

## Теория

Полная резервная копия содержит всю базу данных на момент выполнения команды: все данные, объекты схемы и ту часть журнала транзакций, которая нужна для согласованного состояния. Она является базой цепочки восстановления — все последующие дифференциальные и лог-бэкапы опираются на последний полный бэкап.

Основные параметры:
- **TO DISK** — путь к файлу бэкапа.
- **WITH FORMAT, INIT** — создание нового набора носителей и перезапись файла при наличии.
- **COMPRESSION** — сжатие для уменьшения размера и времени копирования.
- **STATS = 10** — вывод прогресса каждые 10%.

---

## Как это сделано в лабораторной

Первый полный бэкап — исходная база в режиме SIMPLE (для создания копии и восстановления в новую базу ProjectDB_Lab4):

```sql
BACKUP DATABASE [ProjectDB_Lab2]
TO DISK = N'/var/opt/mssql/backup/ProjectDB_Lab2_full_for_lab4.bak'
WITH
    FORMAT,
    INIT,
    COMPRESSION,
    STATS = 10;
GO
```

Второй полный бэкап — уже база ProjectDB_Lab4 в режиме FULL (начало цепочки для diff и log):

```sql
ALTER DATABASE [ProjectDB_Lab4] SET RECOVERY FULL WITH NO_WAIT;
GO

BACKUP DATABASE [ProjectDB_Lab4]
TO DISK = N'/var/opt/mssql/backup/ProjectDB_Lab4_full_1.bak'
WITH
    FORMAT,
    INIT,
    COMPRESSION,
    STATS = 10;
GO
```

Восстановление из полного бэкапа в новую базу с переносом файлов (логические имена из бэкапа могут отличаться от имени новой базы):

```sql
RESTORE DATABASE [ProjectDB_Lab4]
FROM DISK = N'/var/opt/mssql/backup/ProjectDB_Lab2_full_for_lab4.bak'
WITH
    MOVE N'ProjectDB_Lab2' TO N'/var/opt/mssql/data/ProjectDB_Lab4.mdf',
    MOVE N'ProjectDB_Lab2_log' TO N'/var/opt/mssql/data/ProjectDB_Lab4_log.ldf',
    REPLACE,
    RECOVERY,
    STATS = 10;
GO
```

`RECOVERY` переводит базу в рабочее состояние; при построении цепочки восстановления следующих бэкапов используется `NORECOVERY`.
