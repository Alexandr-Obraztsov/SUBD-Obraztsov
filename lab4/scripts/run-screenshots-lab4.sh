#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/.."

if [ -f .env ]; then
  set -a
  source .env
  set +a
fi

SA_PASS="${SA_PASSWORD:-$MSSQL_SA_PASSWORD}"
if [ -z "$SA_PASS" ]; then
  echo "Ошибка: в .env задайте SA_PASSWORD или MSSQL_SA_PASSWORD"
  exit 1
fi

next_screen() {
  read -p "Сделайте скриншот, затем нажмите Enter для следующего вывода: " _
}

echo "=== Скриншот 1 (fig_01): цепочка резервных копий — список файлов в /var/opt/mssql/backup ==="
next_screen
docker exec lab4_sql1 ls -la /var/opt/mssql/backup/

echo ""
echo "=== Скриншот 2 (fig_02): SELECT до/после — таблица Users ==="
next_screen
docker exec -i lab4_sql1 /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$SA_PASS" -d ProjectDB_Lab4 -C -W -w 120 -s " | " -Q "SELECT * FROM dbo.Users ORDER BY UserId;"

echo ""
echo "=== Скриншот 3 (fig_03): SELECT до/после — таблица Chats ==="
next_screen
docker exec -i lab4_sql1 /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$SA_PASS" -d ProjectDB_Lab4 -C -W -w 120 -s " | " -Q "SELECT * FROM dbo.Chats ORDER BY ChatId;"

echo ""
echo "=== Скриншот 4 (fig_04): SELECT до/после — таблица Tasks ==="
next_screen
docker exec -i lab4_sql1 /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$SA_PASS" -d ProjectDB_Lab4 -C -W -w 120 -s " | " -Q "SELECT * FROM dbo.Tasks ORDER BY TaskId;"

echo ""
echo "=== Скриншот 5 (fig_05): протокол восстановления на sql2 — данные после RESTORE ==="
next_screen
docker exec -i lab4_sql2 /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$SA_PASS" -d ProjectDB_Lab4 -C -W -w 120 -s " | " -Q "SELECT * FROM dbo.Users ORDER BY UserId; SELECT * FROM dbo.Chats ORDER BY ChatId; SELECT * FROM dbo.Tasks ORDER BY TaskId;"

echo ""
echo "=== Скриншот 6 (fig_06): резервная копия master — наличие файла в каталоге бэкапов ==="
next_screen
docker exec lab4_sql1 sh -c 'ls -la /var/opt/mssql/backup/master* 2>/dev/null || ls -la /var/opt/mssql/backup/'

echo ""
echo "Готово. Все выводы для скриншотов показаны."
