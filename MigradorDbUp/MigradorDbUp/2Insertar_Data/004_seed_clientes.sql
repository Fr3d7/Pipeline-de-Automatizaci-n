-- 004_seed_clientes.sql
-- Inserta clientes de ejemplo (idempotente por Email)
SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @Clientes TABLE (Nombre NVARCHAR(120), Email NVARCHAR(200), Telefono NVARCHAR(30));
  INSERT INTO @Clientes (Nombre, Email, Telefono) VALUES
    (N'Ana López',   N'ana@hotmail.com',   N'555-1001'),
    (N'Bruno Pérez', N'bruno@hotmail.com', N'555-1002'),
    (N'Carla Díaz',  N'carla@hotmail.com', N'555-1003');

  INSERT dbo.Clientes (Nombre, Email, Telefono)
  SELECT c.Nombre, c.Email, c.Telefono
  FROM @Clientes c
  WHERE NOT EXISTS (SELECT 1 FROM dbo.Clientes x WHERE x.Email = c.Email);

  COMMIT;
END TRY
BEGIN CATCH
  IF XACT_STATE() <> 0 ROLLBACK;
  THROW;
END CATCH;
GO
