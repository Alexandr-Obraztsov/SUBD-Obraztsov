# Лабораторная работа № 3 — Безопасность: аудит, роли и шифрование

Окружение подготовлено: контейнеры запущены, база развёрнута, Extended Events, Audit, пользователи, TDE и восстановление на sql2 выполнены.

---

## Что осталось сделать вам

1. **Запустить скрипт для скриншотов** (из каталога lab3):
   ```bash
   bash scripts/run-screenshots-lab3.sh
   ```

2. **Сделать скриншоты** каждого блока вывода и сохранить в **.doc/images/** с именами:
   - fig_01_xe_session.png
   - fig_02_audit_settings.png
   - fig_03_audit_log.png
   - fig_04_users_roles.png
   - fig_05_encryption_state.png
   - fig_06_restore_sql2.png

3. **Пересобрать отчёт**: MCP **compile_report** (json_path = `.doc/render.json`, output_path = `.doc/otchet_lab3.docx`) или CLI `bsuir-compile .doc/render.json .doc/otchet_lab3.docx`.

Подробно: [docs/commands-for-screenshots-lab3.md](docs/commands-for-screenshots-lab3.md).

---

## Структура проекта

- **docker-compose.yml** — sql1 (порт 1433), sql2 (порт 1434); тома xel, audit, backup.
- **.env** — пароль SA (SA_PASSWORD или MSSQL_SA_PASSWORD).
- **sql/** — скрипты 03–17 (БД, XE, Audit, пользователи, TDE, бэкап, восстановление, проверки).
- **scripts/run-screenshots-lab3.sh** — команды для снятия скриншотов к отчёту.
- **.doc/** — render.json, otchet_lab3.docx, images/.
- **docs/** — теория и описание (README, 01–07, commands-for-screenshots-lab3.md).

---

## Запуск контейнеров (если останавливали)

```bash
docker compose up -d
```

Пароль в `.env` должен совпадать с тем, что использовался при первом запуске (образ SQL Server запоминает пароль SA при инициализации).
