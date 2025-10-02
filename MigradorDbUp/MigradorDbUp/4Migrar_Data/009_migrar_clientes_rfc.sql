-- 009_migrar_clientes_rfc.sql


SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @Fix TABLE(Email NVARCHAR(200) PRIMARY KEY, Rfc NVARCHAR(26));
  INSERT INTO @Fix(Email, Rfc) VALUES
    (N'ana@hotmail.com',    N'LOAA800101AB1'),
    (N'bruno@hotmail.com',  N'PEJB800101BC2'),
    (N'carla@hotmail.com',  N'DIAC800101CD3'),
    (N'fredy@hotmail.com',  N'LOPF800101DE4'),
    (N'junior@hotmail.com', N'JUXX800101EF5');

  UPDATE c
  SET c.Rfc = f.Rfc
  FROM dbo.Clientes c
  JOIN @Fix f ON f.Email = c.Email
  WHERE c.Rfc IS NULL
     OR c.Rfc = N'XAXX010101000'     
     OR c.Rfc <> f.Rfc;             

  COMMIT;
END TRY
BEGIN CATCH
  IF XACT_STATE() <> 0 ROLLBACK;
  THROW;
END CATCH;
GO
