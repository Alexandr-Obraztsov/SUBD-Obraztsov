-- Лабораторная №3 (macOS): Extended Events — трассировка sql_batch_completed и rpc_completed
-- Цель: аналог Profiler; события без sql_statement/sp_statement; вывод в .xel в смонтированном каталоге
-- Путь /var/opt/mssql/xel должен быть смонтирован с хоста (volumes/sql1/xel)

USE master;
GO

-- Удалить сессию, если уже есть (для повторного запуска)
IF EXISTS (SELECT * FROM sys.dm_xe_sessions WHERE name = N'Lab3_Trace_BatchRpc')
BEGIN
    ALTER EVENT SESSION [Lab3_Trace_BatchRpc] ON SERVER STATE = STOP;
    DROP EVENT SESSION [Lab3_Trace_BatchRpc] ON SERVER;
END
GO

CREATE EVENT SESSION [Lab3_Trace_BatchRpc]
ON SERVER
ADD EVENT sqlserver.sql_batch_completed
(
    SET collect_batch_text = 1
),
ADD EVENT sqlserver.rpc_completed
(
    SET collect_statement = 0
)
ADD TARGET package0.event_file
(
    SET filename = N'/var/opt/mssql/xel/lab3_trace',
    max_file_size = 10,
    max_rollover_files = 5
)
WITH
(
    MAX_MEMORY = 4096 KB,
    EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS,
    MAX_DISPATCH_LATENCY = 5 SECONDS,
    STARTUP_STATE = OFF
);
GO

-- Запуск сессии
ALTER EVENT SESSION [Lab3_Trace_BatchRpc] ON SERVER STATE = START;
GO

-- Проверка: сессия должна быть в состоянии running
-- SELECT name, create_time FROM sys.dm_xe_sessions WHERE name = N'Lab3_Trace_BatchRpc';
