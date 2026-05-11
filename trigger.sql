-- =============================================
-- 1) CRUD CLIENTES
-- =============================================

-- INCLUIR CLIENTE
CREATE PROCEDURE Incluir_Cliente
	@CIDADE VARCHAR(30),
	@ENDERECO VARCHAR(50),
	@TELEFONE VARCHAR(15),
	@ESTADO VARCHAR(30),
	@NOME VARCHAR(50),
	@BAIRRO VARCHAR(40),
	@RG VARCHAR(9),
	@EMAIL VARCHAR(30),
	@COD_CLIENTE INT,
	@Sexo VARCHAR(30),
	@DATANASCIMENTO DATE
AS
BEGIN
	INSERT INTO CLIENTES 
	(BAIRRO, CIDADE, COD_CLIENTE, ENDERECO, ESTADO, RG, DATANASCIMENTO, EMAIL, Sexo, TELEFONE, NOME)
	VALUES 
	(@BAIRRO, @CIDADE, @COD_CLIENTE, @ENDERECO, @ESTADO, @RG, @DATANASCIMENTO, @EMAIL, @Sexo, @TELEFONE, @NOME)
END
GO

-- EXCLUIR CLIENTE
CREATE PROCEDURE Excluir_Cliente
	@COD_CLIENTE INT
AS
BEGIN
	DELETE FROM CLIENTES
	WHERE COD_CLIENTE = @COD_CLIENTE
END
GO

-- SELECIONAR CLIENTE
CREATE PROCEDURE Listar_Cliente
	@COD_CLIENTE INT
AS
BEGIN
	SELECT * 
	FROM CLIENTES
	WHERE COD_CLIENTE = @COD_CLIENTE
END
GO

-- ALTERAR CLIENTE
CREATE PROCEDURE Alterar_Cliente
	@CIDADE VARCHAR(30),
	@ENDERECO VARCHAR(50),
	@TELEFONE VARCHAR(15),
	@ESTADO VARCHAR(30),
	@NOME VARCHAR(50),
	@BAIRRO VARCHAR(40),
	@RG VARCHAR(9),
	@EMAIL VARCHAR(30),
	@COD_CLIENTE INT,
	@Sexo VARCHAR(30),
	@DATANASCIMENTO DATE
AS
BEGIN
	UPDATE CLIENTES 
	SET 
		RG = @RG,
		BAIRRO = @BAIRRO,
		ESTADO = @ESTADO,
		NOME = @NOME,
		CIDADE = @CIDADE,
		TELEFONE = @TELEFONE,
		EMAIL = @EMAIL,
		DATANASCIMENTO = @DATANASCIMENTO,
		Sexo = @Sexo
	WHERE COD_CLIENTE = @COD_CLIENTE
END
GO

-- =============================================
-- 2) ANIVERSARIANTES DO MÊS
-- =============================================
CREATE PROCEDURE proc_Aniversariantes_Mes
	@Mes INT
AS
BEGIN
	SELECT 
		NOME,
		DAY(DATANASCIMENTO) AS Dia
	FROM CLIENTES
	WHERE MONTH(DATANASCIMENTO) = @Mes
	ORDER BY Dia
END
GO

-- =============================================
-- 3) RESUMO DE ANIVERSARIANTES POR MÊS
-- (MOSTRA MESES COM 0)
-- =============================================
CREATE PROCEDURE Resumo_Aniversariantes
AS
BEGIN
	SELECT 
		m.Mes,
		DATENAME(MONTH, DATEFROMPARTS(2020, m.Mes, 1)) AS Nome_Mes,
		COUNT(c.COD_CLIENTE) AS Total_Aniversariantes
	FROM (
		SELECT 1 AS Mes UNION SELECT 2 UNION SELECT 3 UNION SELECT 4
		UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8
		UNION SELECT 9 UNION SELECT 10 UNION SELECT 11 UNION SELECT 12
	) m
	LEFT JOIN CLIENTES c
		ON MONTH(c.DATANASCIMENTO) = m.Mes
	GROUP BY m.Mes
	ORDER BY m.Mes
END
GO

-- =============================================
-- 4) CLIENTES POR CIDADE E IDADE
-- =============================================
CREATE PROCEDURE Clientes_Cidade_Idade
	@Cidade VARCHAR(80),
	@Idade_Max INT
AS
BEGIN
	SELECT 
		NOME AS Nome_Cliente,
		DATANASCIMENTO AS Data_Nascimento,
		DATEDIFF(YEAR, DATANASCIMENTO, GETDATE()) AS Idade
	FROM CLIENTES
	WHERE CIDADE = @Cidade
	AND DATEDIFF(YEAR, DATANASCIMENTO, GETDATE()) <= @Idade_Max
	ORDER BY NOME
END
GO

-- =============================================
-- 5) ALTERAÇÕES NAS TABELAS
-- =============================================
ALTER TABLE Filme
ADD Status VARCHAR(10) DEFAULT 'Disponível'
GO

ALTER TABLE Locacoes
ADD Data_Devolucao DATE NULL
GO

-- =============================================
-- 5) INCLUIR LOCAÇÃO
-- =============================================
CREATE PROCEDURE Incluir_Locacao
	@ID_Cliente INT,
	@ID_Filme INT
AS
BEGIN
	INSERT INTO Locacoes (ID_Cliente, ID_Filme, Data_Locacao, Data_Devolucao)
	VALUES (@ID_Cliente, @ID_Filme, GETDATE(), NULL)

	UPDATE Filme
	SET Status = 'alugado'
	WHERE ID_Filme = @ID_Filme
END
GO

-- =============================================
-- 6) DEVOLVER FILME
-- =============================================
CREATE PROCEDURE Devolver_Filme
	@ID_Locacao INT
AS
BEGIN
	DECLARE @ID_Filme INT

	SELECT @ID_Filme = ID_Filme
	FROM Locacoes
	WHERE ID_Locacao = @ID_Locacao

	UPDATE Locacoes
	SET Data_Devolucao = GETDATE()
	WHERE ID_Locacao = @ID_Locacao

	UPDATE Filme
	SET Status = 'Disponível'
	WHERE ID_Filme = @ID_FilME
END
GO
-- =============================================
-- 7) TRIGGERS
-- =============================================

CREATE TABLE Historico_Locacoes (
    ID_Historico INT IDENTITY(1,1) PRIMARY KEY,
    ID_Locacao INT,
    ID_Cliente INT,
    ID_Filme INT,
    Tipo_Acao VARCHAR(20), -- 'LOCACAO' ou 'DEVOLUCAO'
    Data_Acao DATETIME
)
GO

CREATE TRIGGER trg_AfterInsert_Locacao
ON Locacoes
AFTER INSERT
AS
BEGIN
    INSERT INTO Historico_Locacoes (ID_Locacao, ID_Cliente, ID_Filme, Tipo_Acao, Data_Acao)
    SELECT 
        i.ID_Locacao,
        i.ID_Cliente,
        i.ID_Filme,
        'LOCACAO',
        GETDATE()
    FROM inserted i
END
GO

CREATE TRIGGER trg_AfterUpdate_Devolucao
ON Locacoes
AFTER UPDATE
AS
BEGIN
    INSERT INTO Historico_Locacoes (ID_Locacao, ID_Cliente, ID_Filme, Tipo_Acao, Data_Acao)
    SELECT 
        i.ID_Locacao,
        i.ID_Cliente,
        i.ID_Filme,
        'DEVOLUCAO',
        GETDATE()
    FROM inserted i
    INNER JOIN deleted d ON i.ID_Locacao = d.ID_Locacao
    WHERE d.Data_Devolucao IS NULL
      AND i.Data_Devolucao IS NOT NULL
END
GO
