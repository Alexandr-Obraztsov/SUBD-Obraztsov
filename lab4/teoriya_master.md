# Резервное копирование и восстановление базы master

## Теория

База **master** — системная: в ней хранятся логины, настройки сервера, список баз данных и т.д. Экземпляр SQL Server при запуске читает master и от неё зависит. Резервную копию master можно создавать в обычном режиме работы. Восстановление master возможно только при одном активном подключении, поэтому экземпляр перед восстановлением переводится в режим **single-user** (параметр запуска `-m`). После успешного `RESTORE DATABASE master` экземпляр перезапускается: все соединения обрываются, процесс sqlservr заново читает восстановленную копию master.

---

## Как это сделано в лабораторной

Создание резервной копии master (в обычном режиме):

```sql
USE master;
GO

BACKUP DATABASE [master]
TO DISK = N'/var/opt/mssql/backup/master_full_for_lab4.bak'
WITH
    FORMAT,
    INIT,
    COMPRESSION,
    STATS = 20;
GO
```

Восстановление master в Docker выполняется в отдельном контейнере в single-user режиме. Концептуально последовательность такая:

1. Остановить основной контейнер sql1.
2. Запустить контейнер с параметром `-m` (single-user):
   ```bash
   docker run --rm -e ACCEPT_EULA=Y -e MSSQL_SA_PASSWORD=$SA_PASSWORD \
     -v $(pwd)/volumes/shared/backup:/var/opt/mssql/backup \
     --name lab4_sql1_single \
     mcr.microsoft.com/mssql/server:2022-latest \
     /opt/mssql/bin/sqlservr -m
   ```
3. В другом терминале выполнить восстановление:
   ```sql
   RESTORE DATABASE master
   FROM DISK = N'/var/opt/mssql/backup/master_full_for_lab4.bak'
   WITH REPLACE, STATS = 20;
   ```
   После успешного RESTORE процесс перезапустится, соединение оборвётся — это ожидаемо.
4. Остановить временный контейнер и снова запустить обычный sql1 через docker compose.

Эффект: состояние логинов и системных настроек возвращается к моменту бэкапа; из-за перезапуска все соединения разрываются.
