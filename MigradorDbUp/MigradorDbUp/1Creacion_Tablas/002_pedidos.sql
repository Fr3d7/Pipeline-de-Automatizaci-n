SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;
  IF OBJECT_ID(N'dbo.Pedidos','U') IS NULL
  BEGIN
    CREATE TABLE dbo.Pedidos(
      PedidoId  INT IDENTITY(1,1) CONSTRAINT PK_Pedidos PRIMARY KEY,
      ClienteId INT NOT NULL,
      Fecha     DATETIME2(0)  NOT NULL CONSTRAINT DF_Pedidos_Fecha DEFAULT SYSUTCDATETIME(),
      Monto     DECIMAL(12,2) NOT NULL CONSTRAINT DF_Pedidos_Monto DEFAULT(0),
      Estado    NVARCHAR(30)  NOT NULL CONSTRAINT DF_Pedidos_Estado DEFAULT N'Pendiente'
    );
  END;
  IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.Pedidos') AND name = N'IX_Pedidos_ClienteId_Fecha')
    CREATE INDEX IX_Pedidos_ClienteId_Fecha ON dbo.Pedidos(ClienteId, Fecha);
  IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_Pedidos_Monto_Pos')
    ALTER TABLE dbo.Pedidos ADD CONSTRAINT CK_Pedidos_Monto_Pos CHECK (Monto >= 0);
  COMMIT;
END TRY
BEGIN CATCH
  IF XACT_STATE() <> 0 ROLLBACK; THROW;
END CATCH;
