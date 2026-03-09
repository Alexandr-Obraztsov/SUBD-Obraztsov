USE master;
GO

IF DB_ID(N'ProjectDB_Lab5') IS NULL
BEGIN
    RAISERROR(N'База ProjectDB_Lab5 не найдена. Сначала выполните 01_prepare_projectdb_lab5.sql на sql1.', 16, 1);
    RETURN;
END;
GO

EXEC sp_configure N'show advanced options', 1;
RECONFIGURE WITH OVERRIDE;
GO

EXEC sp_configure N'replication', 1;
RECONFIGURE WITH OVERRIDE;
GO

DECLARE @publisher sysname = N'lab5_sql1';
DECLARE @distribution_db sysname = N'distribution_lab5';
DECLARE @snapshot_folder nvarchar(260) = N'/var/opt/mssql/replication';

IF NOT EXISTS (SELECT 1 FROM sys.servers WHERE is_distributor = 1)
BEGIN
    EXEC sp_adddistributor
        @distributor = @publisher,
        @heartbeat_interval = 10,
        @password = NULL;
END;

IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = @distribution_db)
BEGIN
    EXEC sp_adddistributiondb
        @database = @distribution_db,
        @data_folder = N'/var/opt/mssql/data',
        @log_folder = N'/var/opt/mssql/data',
        @log_file_size = 5,
        @min_distretention = 0,
        @max_distretention = 72,
        @history_retention = 48,
        @security_mode = 1;
END;
GO

IF NOT EXISTS (SELECT 1 FROM msdb.dbo.MSdistpublishers WHERE name = @publisher)
BEGIN
    EXEC sp_adddistpublisher
        @publisher = @publisher,
        @distribution_db = @distribution_db,
        @security_mode = 1,
        @working_directory = @snapshot_folder,
        @trusted = N'false',
        @thirdparty_flag = 0,
        @publisher_type = N'MSSQLSERVER';
END;
GO

USE [ProjectDB_Lab5];
GO

DECLARE @publication sysname = N'Lab5_Tasks_TransactionalPublication';

IF NOT EXISTS (SELECT 1 FROM syspublications WHERE name = @publication)
BEGIN
    EXEC sp_addpublication
        @publication = @publication,
        @description = N'Transactional replication для таблицы dbo.Tasks в ProjectDB_Lab5',
        @status = N'active',
        @sync_method = N'concurrent',
        @repl_freq = N'continuous',
        @publication_type = 0, -- transactional
        @allow_push = N'true',
        @allow_pull = N'true',
        @allow_anonymous = N'false',
        @enabled_for_internet = N'false',
        @immediate_sync = N'false',
        @retention = 0,
        @allow_initialize_from_backup = N'false';

    EXEC sp_addpublication_snapshot
        @publication = @publication,
        @frequency_type = 1,  -- on demand
        @frequency_interval = 0,
        @frequency_relative_interval = 0,
        @frequency_recurrence_factor = 0,
        @frequency_subday = 0,
        @frequency_subday_interval = 0,
        @active_start_time_of_day = 0,
        @active_end_time_of_day = 235959,
        @active_start_date = 0;
END;
GO

USE [ProjectDB_Lab5];
GO

IF NOT EXISTS (SELECT 1 FROM sysextendedarticlesview WHERE publication = N'Lab5_Tasks_TransactionalPublication' AND artname = N'dbo_Tasks')
BEGIN
    EXEC sp_addarticle
        @publication = N'Lab5_Tasks_TransactionalPublication',
        @article = N'dbo_Tasks',
        @source_owner = N'dbo',
        @source_object = N'Tasks',
        @type = N'logbased',
        @pre_creation_cmd = N'drop',
        @schema_option = 0x000000000803509F,
        @identityrangemanagementoption = N'manual';
END;
GO

EXEC sp_startpublication_snapshot @publication = N'Lab5_Tasks_TransactionalPublication';
GO

