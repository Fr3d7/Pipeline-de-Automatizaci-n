IF COL_LENGTH('dbo.Pedidos', 'Estado') IS NOT NULL
BEGIN
    -- Si hay estados distintos (o NULL), regrésalos a 'Pendiente'
    UPDATE p
    SET    Estado = N'Pendiente'
    FROM   dbo.Pedidos AS p
    WHERE  p.Estado IS NULL
        OR p.Estado <> N'Pendiente';
END
GO