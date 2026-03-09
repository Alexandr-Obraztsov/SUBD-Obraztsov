## Лабораторная работа №5 — Высокая доступность и DR (HA/DR) в Docker (macOS, Apple Silicon)

Вариант для macOS в Docker: три контейнера с SQL Server 2019 (Linux):

- `lab5_sql1` — основной сервер (primary), на нём располагается база `ProjectDB_Lab5`, настраиваются log shipping и публикация репликации.
- `lab5_sql2` — вторичный сервер (secondary) для log shipping (аварийное восстановление).
- `lab5_sql3` — подписчик (subscriber) для transactional replication.

Образ и базовая конфигурация контейнеров такие же, как в лабах 1–4 (см. `lab1/Dockerfile`). SQL Server Agent включён через переменную `MSSQL_AGENT_ENABLED=true`.

### 1. Подготовка окружения

1. Скопируйте `.env.example` в `.env` и задайте реальный пароль:
   ```bash
   cd lab5
   cp .env.example .env
   # отредактируйте .env и измените MSSQL_SA_PASSWORD / SA_PASSWORD
   ```
2. Запустите контейнеры:
   ```bash
   docker compose up -d
   ```
3. Убедитесь, что ранее выполнены лабораторные №2 и №4 и на `sql1` существует база `ProjectDB_Lab2` (из неё будет создана копия `ProjectDB_Lab5`).

Порты:

- `lab5_sql1`: `localhost,1451`
- `lab5_sql2`: `localhost,1452`
- `lab5_sql3`: `localhost,1453`

Общие каталоги на хосте (bind mount):

- `volumes/shared/backup` → `/var/opt/mssql/backup` (бэкапы для log shipping и DR).
- `volumes/shared/replication` → `/var/opt/mssql/replication` (снимки для transactional replication).

### 2. Порядок выполнения скриптов

Все скрипты находятся в каталоге `sql/` и выполняются через `sqlcmd` внутри контейнеров по аналогии с предыдущими лабораторными.

1. **Подготовка базы `ProjectDB_Lab5` на sql1**  
   - `sql/01_prepare_projectdb_lab5.sql` (в контейнере `lab5_sql1`).  
     Скрипт создаёт базу `ProjectDB_Lab5` как копию `ProjectDB_Lab2`, переводит её в режим FULL и делает полный бэкап в `/var/opt/mssql/backup`.

2. **Log Shipping (sql1 → sql2)**  
   - `sql/02_log_shipping_primary.sql` (в контейнере `lab5_sql1`) — настройки primary и регулярный backup журнала.  
   - `sql/03_log_shipping_secondary.sql` (в контейнере `lab5_sql2`) — первичное восстановление full-бэкапа в режиме `NORECOVERY` и применение лог-бэкапов.  
   Для учебной версии акцент делается на T-SQL и демонстрации доставки логов; автоматизация через SQL Server Agent описана в теоретической части.

3. **Transactional Replication (sql1 → sql3)**  
   - `sql/04_replication_publisher_distributor.sql` (в контейнере `lab5_sql1`) — настройка распределителя (distributor), публикации и моментального создания снимка.  
   - `sql/05_replication_subscriber.sql` (в контейнере `lab5_sql3`) — настройка подписчика и проверка доставки изменений для выбранной таблицы `dbo.Tasks`.

4. **Проверочные скрипты**  
   - `sql/06_verify_log_shipping.sql` — выборки на sql1 и sql2 для подтверждения актуальности данных после «отказа» primary.  
   - `sql/07_verify_replication.sql` — проверка, что изменения в таблице `dbo.Tasks` появляются на подписчике (sql3).

### 3. Отчёт и скриншоты

- Для отчёта используются скриншоты вывода ключевых запросов и состояний log shipping / replication (аналогично `lab3` и `lab4` — отдельный список имён файлов и подписей будет в `СКРИНШОТЫ_ДЛЯ_ОТЧЁТА_lab5.md`).
- Структура отчёта описана в JSON-файле `report_lab5.json` (по образцу `lab2/report_lab2.json` и `lab3/.doc/render.json`): цель, теория по HA/DR, порядок выполнения (Docker, log shipping, replication), проверка и выводы.

### 4. Ограничения Docker-варианта

- Database mirroring не поддерживается в SQL Server для Linux, поэтому в Docker-варианте задание по mirroring выполняется **теоретически** в отчёте: приводятся схемы principal/mirror/witness, режимы синхронный/асинхронный, сценарии failover и сравнение с log shipping / replication.
- Реальная демонстрация DR выполняется через log shipping (ручная/полуавтоматическая доставка лог-бэкапов на `sql2`) и transactional replication на связке `sql1`–`sql3`.

