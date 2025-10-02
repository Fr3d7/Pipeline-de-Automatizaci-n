-- 010_migrar_pedidos_estado.sql
SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  UPDATE dbo.Pedidos
  SET    Estado = N'Atrasado'
  WHERE  Estado = N'Pendiente'
     AND Fecha  < DATEADD(DAY, -1, SYSUTCDATETIME());

  COMMIT;
END TRY
BEGIN CATCH
  IF XACT_STATE() <> 0 ROLLBACK;
  THROW;
END CATCH;
GO
