-- 005_seed_pedidos.sql
-- Inserta pedidos de ejemplo para los clientes anteriores.
-- Idempotente: evita duplicar comparando (ClienteId, Fecha, Monto)
SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @Pedidos TABLE (Email NVARCHAR(200), Fecha DATETIME2(0), Monto DECIMAL(12,2), Estado NVARCHAR(30));

  INSERT INTO @Pedidos (Email, Fecha, Monto, Estado) VALUES
    (N'ana@hotmail.com',    SYSUTCDATETIME(),                      120.50, N'Pendiente'),
    (N'ana@hotmail.com',    DATEADD(DAY, -2, SYSUTCDATETIME()),     89.99, N'Completado'),
    (N'bruno@hotmail.com',  DATEADD(DAY, -1, SYSUTCDATETIME()),     45.00, N'Pendiente'),
    (N'carla@hotmail.com',  DATEADD(HOUR,-12, SYSUTCDATETIME()),   250.00, N'Pendiente');
  -- Mapea Email -> ClienteId y evita duplicados
  INSERT dbo.Pedidos (ClienteId, Fecha, Monto, Estado)
  SELECT c.ClienteId, p.Fecha, p.Monto, p.Estado
  FROM @Pedidos p
  JOIN dbo.Clientes c ON c.Email = p.Email
  WHERE NOT EXISTS (
      SELECT 1
      FROM dbo.Pedidos x
      WHERE x.ClienteId = c.ClienteId
        AND x.Fecha     = p.Fecha
        AND x.Monto     = p.Monto
  );

  COMMIT;
END TRY
BEGIN CATCH
  IF XACT_STATE() <> 0 ROLLBACK;
  THROW;
END CATCH;
GO
