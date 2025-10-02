-- Crea la base si no existe 
IF DB_ID(N'migraciondb') IS NULL
    EXEC(N'CREATE DATABASE [migraciondb]');
GO
