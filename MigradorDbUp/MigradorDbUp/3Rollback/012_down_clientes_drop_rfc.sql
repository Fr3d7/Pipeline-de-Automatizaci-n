-- 012_down_clientes_drop_rfc.sql
-- Reversa de 007_alter_clientes_add_rfc.sql

IF COL_LENGTH(N'dbo.Clientes', N'Rfc') IS NOT NULL
BEGIN
    DECLARE @df  sysname,
            @sql nvarchar(4000);

    /* Localiza el DEFAULT de la columna Rfc (si existiera) */
    SELECT TOP (1) @df = dc.name
    FROM sys.default_constraints AS dc
    JOIN sys.columns AS c
         ON c.object_id  = dc.parent_object_id
        AND c.column_id  = dc.parent_column_id   -- join exacto por columna
    WHERE dc.parent_object_id = OBJECT_ID(N'dbo.Clientes')
      AND c.name = N'Rfc';

    /* Si hay DEFAULT, elimínalo primero */
    IF @df IS NOT NULL
    BEGIN
        -- Opción 1 (preferida): QUOTENAME
        SET @sql = N'ALTER TABLE dbo.Clientes DROP CONSTRAINT ' + QUOTENAME(@df) + N';';
        -- Si tu editor marcara QUOTENAME como error, usa esta alternativa:
        -- SET @sql = N'ALTER TABLE dbo.Clientes DROP CONSTRAINT [' + REPLACE(@df, ']', ']]') + N'];';

        EXEC sys.sp_executesql @sql;
    END;

    /* Quita la columna */
    ALTER TABLE dbo.Clientes DROP COLUMN Rfc;
END;
GO
