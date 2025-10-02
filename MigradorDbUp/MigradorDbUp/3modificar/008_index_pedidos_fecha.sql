IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = N'IX_Pedidos_Fecha'
    AND object_id = OBJECT_ID(N'dbo.Pedidos')
)
  CREATE INDEX IX_Pedidos_Fecha
    ON dbo.Pedidos(Fecha)
    INCLUDE (Monto, Estado);
GO
