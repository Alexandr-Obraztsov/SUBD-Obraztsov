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

# Перед каждым шагом ждём ввод слова, чтобы успеть сделать скриншот
next_screen() {
  read -p "Введите любое слово и нажмите Enter для следующего скриншота: " _
}

next_screen
docker exec -i lab3_sql1 /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$SA_PASS" -C -W -w 100 -s " | " -Q "SELECT name, create_time FROM sys.dm_xe_sessions WHERE name = N'Lab3_Trace_BatchRpc';"

next_screen
docker exec -i lab3_sql1 /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$SA_PASS" -C -W -w 100 -s " | " -Q "SELECT name, type_desc, is_state_enabled FROM sys.server_audits; SELECT name, is_state_enabled FROM sys.server_audit_specifications;"

next_screen
cat sql/17_audit_view.sql | docker exec -i lab3_sql1 /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$SA_PASS" -C -W -w 120 -s " | "

next_screen
docker exec -i lab3_sql1 /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$SA_PASS" -d ProjectDB_Lab2 -C -W -w 100 -s " | " -Q "
SELECT dp.name AS user_name, r.name AS role_name
FROM sys.database_principals dp
LEFT JOIN sys.database_role_members drm ON drm.member_principal_id = dp.principal_id
LEFT JOIN sys.database_principals r ON r.principal_id = drm.role_principal_id
WHERE dp.type IN ('S','U') AND dp.name NOT IN ('dbo','guest','sys','INFORMATION_SCHEMA')
ORDER BY dp.name, r.name;
"

next_screen
cat sql/16_verify_encryption.sql | docker exec -i lab3_sql1 /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$SA_PASS" -C -W -w 100 -s " | "

next_screen
docker exec -i lab3_sql2 /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$SA_PASS" -C -W -w 100 -s " | " -Q "SELECT DB_NAME(database_id) AS db_name, encryption_state FROM sys.dm_database_encryption_keys WHERE database_id = DB_ID(N'ProjectDB_Lab2');"
docker exec -i lab3_sql2 /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$SA_PASS" -d ProjectDB_Lab2 -C -W -w 100 -s " | " -Q "SELECT COUNT(*) AS UsersCount FROM dbo.Users;"