SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  IF COL_LENGTH('dbo.Clientes', 'Rfc') IS NULL
    ALTER TABLE dbo.Clientes ADD Rfc NVARCHAR(13) NULL;

  IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'UQ_Clientes_Rfc'
      AND object_id = OBJECT_ID(N'dbo.Clientes')
  )
    CREATE UNIQUE INDEX UQ_Clientes_Rfc
      ON dbo.Clientes(Rfc)
      WHERE Rfc IS NOT NULL;

  COMMIT;
END TRY
BEGIN CATCH
  IF XACT_STATE() <> 0 ROLLBACK;
  THROW;
END CATCH;
GO
