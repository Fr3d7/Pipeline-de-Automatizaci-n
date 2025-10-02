IF OBJECT_ID(N'dbo.Clientes','U') IS NOT NULL
AND OBJECT_ID(N'dbo.Pedidos','U')  IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Pedidos_Clientes')
BEGIN
  ALTER TABLE dbo.Pedidos WITH CHECK
    ADD CONSTRAINT FK_Pedidos_Clientes
      FOREIGN KEY (ClienteId) REFERENCES dbo.Clientes(ClienteId)
      ON DELETE CASCADE;
END;
