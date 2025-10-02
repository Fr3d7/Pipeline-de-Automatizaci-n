SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;
  IF OBJECT_ID(N'dbo.Clientes','U') IS NULL
  BEGIN
    CREATE TABLE dbo.Clientes(
      ClienteId INT IDENTITY(1,1) CONSTRAINT PK_Clientes PRIMARY KEY,
      Nombre    NVARCHAR(120) NOT NULL,
      Email     NVARCHAR(200) NULL,
      Telefono  NVARCHAR(30)  NULL,
      CreadoEn  DATETIME2(0)  NOT NULL
        CONSTRAINT DF_Clientes_CreadoEn DEFAULT SYSUTCDATETIME()
    );
  END;
  IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.Clientes') AND name = N'UQ_Clientes_Email')
    CREATE UNIQUE INDEX UQ_Clientes_Email ON dbo.Clientes(Email) WHERE Email IS NOT NULL;
  COMMIT;
END TRY
BEGIN CATCH
  IF XACT_STATE() <> 0 ROLLBACK; THROW;
END CATCH;
