# Скриншоты для отчёта ЛР5

Файлы скриншотов сохраняй в каталог `lab5/.doc/images/` с именами ниже — они уже прописаны в `image_path` в `.doc/render.json`, так что после подстановки файлов и пересборки отчёта картинки автоматически попадут в документ.

| Имя файла | Что снять на скриншот | Подпись в отчёте (смысл) |
|----------|------------------------|--------------------------|
| **fig_01_lab5_docker.png** | Терминал с деревом каталогов `lab5` (например, `tree lab5` или `ls -R lab5`) и выводом `docker ps` / `docker compose ps` с контейнерами `lab5_sql1`, `lab5_sql2`, `lab5_sql3` (порты, статус). | Структура Docker-проекта lab5 и список запущенных контейнеров SQL Server. |
| **fig_02_lab5_projectdb_lab2.png** | Вывод скрипта `08_verify_filegroups.sql` на `ProjectDB_Lab2`: список файлов (mdf, ldf, два ndf) с именами файлгрупп и таблиц с указанием размещения (в том числе `Tasks_Archive` на `FG_DATA2`). | Результаты проверки файлов и файлгрупп ProjectDB_Lab2 и размещения таблиц по файлгруппам. |
| **fig_03_lab5_prepare_lab5.png** | Выполнение `01_prepare_projectdb_lab5.sql` на `lab5_sql1` (BACKUP/RESTORE ProjectDB_Lab2 → ProjectDB_Lab5, стартовый FULL-бэкап) и список файлов `ProjectDB_Lab2_full_for_lab5.bak` и `ProjectDB_Lab5_full_1.bak` в `/var/opt/mssql/backup`. | Подготовка базы ProjectDB_Lab5 и начальные резервные копии для сценария log shipping. |
| **fig_04_lab5_logshipping_restore.png** | Вывод скрипта `03_log_shipping_secondary.sql` на `lab5_sql2` и запрос `SELECT name, state_desc FROM sys.databases WHERE name = 'ProjectDB_Lab5';` с состоянием `RESTORING`. | Восстановление ProjectDB_Lab5 на вторичном экземпляре (sql2) в режиме RESTORING для приёма лог-бэкапов. |
| **fig_05_lab5_logshipping_select.png** | Два SELECT: `SELECT TOP (10) * FROM dbo.Tasks ORDER BY TaskId DESC;` на `lab5_sql1` (ProjectDB_Lab5) и такой же запрос на `lab5_sql2` после `RESTORE ... WITH RECOVERY`, демонстрирующие совпадающие данные. | Сравнение содержимого таблицы Tasks на primary и secondary после применения цепочки лог-бэкапов (log shipping). |
| **fig_06_lab5_replication_attempt.png** | Терминал с запуском `04_replication_publisher_distributor.sql` на `lab5_sql1` и характерными сообщениями об ошибках при попытке настроить дистрибьютора/публикацию в Docker/Linux-среде. | Фрагменты вывода при попытке настройки transactional replication и демонстрация ограничений Docker-варианта. |

Для защиты достаточно этих шести рисунков; при желании можно добавить дополнительные (например, состояние SQL Server Agent или свойства базы ProjectDB_Lab5), но они в отчёт не подставляются автоматически.

