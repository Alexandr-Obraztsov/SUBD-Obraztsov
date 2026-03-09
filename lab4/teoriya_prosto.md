# Теория по бэкапам SQL Server — понятно и с примерами

Кратко: что такое бэкап, зачем он нужен, и как это устроено в нашей лабораторной (с примерами из жизни и фрагментами кода).

---

## 1. Что такое бэкап и зачем он нужен

**Бэкап (резервная копия)** — это «снимок» данных в какой-то момент времени, сохранённый отдельно. Если с оригиналом что-то случится, можно вернуться к этому снимку.

**Из жизни:**
- Сохранение в игре — загрузились с прошлой точки вместо начала игры.
- Копия паспорта — оригинал потерялся, есть копия.
- История в Google Документах — откат к вчерашней версии.

С базами то же самое: сервер может упасть, данные удалить или испортить. Резервная копия — файл, из которого можно заново «собрать» базу на этом или другом компьютере.

В SQL Server три основных типа копий: **полная** (вся база), **дифференциальная** (только изменения с последней полной), **копия журнала** (лента изменений). Ниже — каждый тип и как они сочетаются.

---

## 2. Модели восстановления: SIMPLE и FULL

**Из жизни:** Два способа вести дневник. **SIMPLE** — пишете только итог дня одной фразой, старые листы выбрасываете. **FULL** — записываете всё подряд, листы не выбрасываете. Можно восстановить любой момент: «что было в 14:35?»

В базе «листы» — это **журнал транзакций**. В **SIMPLE** длинную историю не хранят, копию журнала делать нельзя. В **FULL** журнал хранится полностью — можно делать лог-бэкапы и восстанавливаться к любому моменту времени.

**В коде (лабораторная):**
```sql
ALTER DATABASE [ProjectDB_Lab2] SET RECOVERY SIMPLE WITH NO_WAIT;
GO
-- ... полный бэкап, создание ProjectDB_Lab4 ...
ALTER DATABASE [ProjectDB_Lab4] SET RECOVERY FULL WITH NO_WAIT;
GO
```

---

## 3. Полная резервная копия (FULL backup)

**Из жизни:** Ксерокопия всей тетради. Полный бэкап — копия всей базы на момент времени. Он **база цепочки**: все диффы и логи опираются на последний полный.

**В коде:**
```sql
BACKUP DATABASE [ProjectDB_Lab2]
TO DISK = N'/var/opt/mssql/backup/ProjectDB_Lab2_full_for_lab4.bak'
WITH FORMAT, INIT, COMPRESSION, STATS = 10;
GO

RESTORE DATABASE [ProjectDB_Lab4]
FROM DISK = N'/var/opt/mssql/backup/ProjectDB_Lab2_full_for_lab4.bak'
WITH
    MOVE N'ProjectDB_Lab2' TO N'/var/opt/mssql/data/ProjectDB_Lab4.mdf',
    MOVE N'ProjectDB_Lab2_log' TO N'/var/opt/mssql/data/ProjectDB_Lab4_log.ldf',
    REPLACE, RECOVERY, STATS = 10;
GO
```

---

## 4. Копия журнала (LOG backup)

**Из жизни:** Журнал — «лента» всех действий. Полная копия + лента до пятницы = можно «проиграть» и получить базу на пятницу или остановиться на среде 14:00 (восстановление к моменту времени). Лог-бэкапы должны идти подряд, без пропусков.

**В коде:**
```sql
BACKUP LOG [ProjectDB_Lab4]
TO DISK = N'/var/opt/mssql/backup/ProjectDB_Lab4_log_1.trn'
WITH INIT, COMPRESSION, STATS = 10;
GO
```

---

## 5. Дифференциальная копия (DIFFERENTIAL)

**Из жизни:** Полная — вся тетрадь. Дифф — «только страницы, изменённые с последней полной». Второй дифф содержит все изменения с полной (вторник + среда). При восстановлении: полная + **последний** дифф = актуальное состояние.

**В коде (таблица Users, затем diff_1):**
```sql
SELECT 'Before_Users' AS Stage, * FROM dbo.Users ORDER BY UserId;
GO
INSERT INTO dbo.Users (Username) VALUES (N'User_Lab4_1');
GO
SELECT 'After_Users' AS Stage, * FROM dbo.Users ORDER BY UserId;
GO
BACKUP DATABASE [ProjectDB_Lab4]
TO DISK = N'/var/opt/mssql/backup/ProjectDB_Lab4_diff_1.bak'
WITH DIFFERENTIAL, FORMAT, INIT, COMPRESSION, STATS = 10;
GO
```
Аналогично для Chats (diff_2) и Tasks (diff_3).

---

## 6. NORECOVERY и RECOVERY

**Из жизни:** Собираем книгу из глав. Пока не «закрыли» — **NORECOVERY** (применяем следующий кусок). На последнем шаге «закрыли» — **RECOVERY** (база готова). Все шаги кроме последнего — NORECOVERY, последний — RECOVERY.

**В коде (восстановление full → diff1 → diff2 → diff3 на втором сервере):**
```sql
RESTORE DATABASE [ProjectDB_Lab4]
FROM DISK = N'/var/opt/mssql/backup/ProjectDB_Lab4_full_1.bak'
WITH MOVE N'ProjectDB_Lab2' TO N'/var/opt/mssql/data/ProjectDB_Lab4_sql2.mdf',
     MOVE N'ProjectDB_Lab2_log' TO N'/var/opt/mssql/data/ProjectDB_Lab4_sql2_log.ldf',
     NORECOVERY, REPLACE, STATS = 10;
GO
RESTORE DATABASE [ProjectDB_Lab4] FROM DISK = N'/var/opt/mssql/backup/ProjectDB_Lab4_diff_1.bak' WITH NORECOVERY, STATS = 10;
GO
RESTORE DATABASE [ProjectDB_Lab4] FROM DISK = N'/var/opt/mssql/backup/ProjectDB_Lab4_diff_2.bak' WITH NORECOVERY, STATS = 10;
GO
RESTORE DATABASE [ProjectDB_Lab4] FROM DISK = N'/var/opt/mssql/backup/ProjectDB_Lab4_diff_3.bak' WITH RECOVERY, STATS = 10;
GO
```

---

## 7. MOVE и REPLACE (другой сервер)

**Из жизни:** Переезд — шкафы «А» и «Б» в новом офисе стали «1» и «2». **MOVE** — «содержимое А положи в 1, Б в 2». **REPLACE** — «если база уже есть, перезаписать». Логические имена в бэкапе: `RESTORE FILELISTONLY FROM DISK = N'...bak';` В нашем бэкапе — ProjectDB_Lab2 и ProjectDB_Lab2_log; на втором сервере кладём в ProjectDB_Lab4_sql2.mdf и .ldf (код выше).

---

## 8. Восстановление на N−1

**Из жизни:** Сохранялись пн, вт, ср, чт. В четверг сломалось — загружаете среду. В базе: «среда» = full + diff1 + diff2 без diff3. В Tasks после diff3 — 3 строки, после только diff2 — 2 (нет Task_Lab4_3).

**В коде (только до diff2, затем RECOVERY):**
```sql
RESTORE DATABASE [ProjectDB_Lab4] FROM DISK = N'/var/opt/mssql/backup/ProjectDB_Lab4_full_1.bak'
WITH MOVE N'ProjectDB_Lab2' TO N'/var/opt/mssql/data/ProjectDB_Lab4_sql2.mdf',
     MOVE N'ProjectDB_Lab2_log' TO N'/var/opt/mssql/data/ProjectDB_Lab4_sql2_log.ldf',
     NORECOVERY, REPLACE, STATS = 10;
GO
RESTORE DATABASE [ProjectDB_Lab4] FROM DISK = N'/var/opt/mssql/backup/ProjectDB_Lab4_diff_1.bak' WITH NORECOVERY, STATS = 10;
GO
RESTORE DATABASE [ProjectDB_Lab4] FROM DISK = N'/var/opt/mssql/backup/ProjectDB_Lab4_diff_2.bak' WITH RECOVERY, STATS = 10;
GO
SELECT * FROM dbo.Tasks ORDER BY TaskId;  -- две строки
```

---

## 9. База master

**Из жизни:** master — «мозг» сервера (логины, настройки). Бэкап — в обычном режиме. Восстановление — только при одном подключении (single-user, параметр `-m`). После RESTORE master сервер перезапускается.

**В коде:**
```sql
BACKUP DATABASE [master]
TO DISK = N'/var/opt/mssql/backup/master_full_for_lab4.bak'
WITH FORMAT, INIT, COMPRESSION, STATS = 20;
GO
```
Восстановление: контейнер с `sqlservr -m`, в другом терминале `RESTORE DATABASE master FROM DISK = '...' WITH REPLACE`, затем перезапуск контейнера.
