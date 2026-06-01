create trigger [dbo].[Alugado] em LOCACOES
after update
as
begin 
	select * from inserted
	update dbo.FILME set ESTADO = 'RESERVADO' from dbo.FILME f inner join inserted i on f.COD_FILME = i.COD_FILME

END
GO 

USE [db_250176];
GO

INSERT INTO [dbo].[LOCACOES] (COD_CLIENTE, COD_FILME, DATA_LOCACAO, DATA_EXPIRACAO, Data_Devolucao)
VALUES (1, 10, GETDATE(), DATEADD(day, 3, GETDATE()), NULL);
GO
SELECT * FROM dbo.FILME WHERE COD_FILME = 10;

create trigger Devolve_Filme on LOCACOES
after update
as
begin
	update filme set ESTADO = 'DISPONIVEL' from filme f inner join inserteed i on f.COD_FILME = i.COD_FILME
end


UPDATE LOCACOES
SET DATA_DEVOLUCAO = GETDATE()
WHERE COD_LOCACAO = 43;
