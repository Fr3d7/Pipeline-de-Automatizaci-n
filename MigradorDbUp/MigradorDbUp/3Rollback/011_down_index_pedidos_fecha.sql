-- 012_down_clientes_drop_rfc.sql
-- Reversa de 007_alter_clientes_add_rfc.sql
IF COL_LENGTH('dbo.Clientes', 'Rfc') IS NOT NULL
BEGIN
    -- Si hubiera DEFAULT en Rfc, quítalo primero
    DECLARE @df sysname;

    SELECT TOP (1) @df = d.name
    FROM sys.default_constraints AS d
    JOIN sys.columns AS c
      ON c.object_id = OBJECT_ID(N'dbo.Clientes')
     AND c.default_object_id = d.object_id
     AND c.name = N'Rfc'
    WHERE d.parent_object_id = OBJECT_ID(N'dbo.Clientes');

    IF @df IS NOT NULL
    BEGIN
        DECLARE @sql nvarchar(4000);
        -- Escapar corchetes por si el nombre los contiene
        SET @sql = N'ALTER TABLE dbo.Clientes DROP CONSTRAINT [' 
                 + REPLACE(@df, ']', ']]') + N'];';
        EXEC sys.sp_executesql @sql;
    END;

    ALTER TABLE dbo.Clientes DROP COLUMN Rfc;
END;
GO
