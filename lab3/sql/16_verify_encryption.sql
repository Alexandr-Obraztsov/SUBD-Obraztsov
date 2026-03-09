-- Проверка состояния TDE (sys.dm_database_encryption_keys)
USE master;
GO

SELECT
    DB_NAME(dek.database_id) AS database_name,
    dek.encryption_state,
    CASE dek.encryption_state
        WHEN 0 THEN 'No encryption'
        WHEN 1 THEN 'Unencrypted'
        WHEN 2 THEN 'Encryption in progress'
        WHEN 3 THEN 'Encrypted'
        WHEN 4 THEN 'Key change in progress'
        WHEN 5 THEN 'Decryption in progress'
        WHEN 6 THEN 'Protection change in progress'
        ELSE 'Unknown'
    END AS encryption_state_desc,
    dek.key_algorithm,
    dek.key_length,
    dek.encryptor_thumbprint
FROM sys.dm_database_encryption_keys dek
ORDER BY database_id;
