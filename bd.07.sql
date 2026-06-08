--Incluir_Cliente ==============================================================
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
	@DATANASCIMENTO VARCHAR(30)
AS
BEGIN
	INSERT INTO dbo.CLIENTES ([BAIRRO], [CIDADE], [COD_CLIENTE], [ENDERECO], [ESTADO], [RG], [DATANASCIMENTO], [EMAIL], [Sexo], [TELEFONE], [NOME])
    VALUES (@CIDADE, @ENDERECO, @TELEFONE, @ESTADO, @NOME, @BAIRRO, @RG, @EMAIL, @COD_CLIENTE, @Sexo, @DATANASCIMENTO)
END
GO

--EXCLUIR CLIENTE ================================================================
CREATE PROCEDURE Excluir_Cliente
	@COD_CLIENTE INT
AS
BEGIN
	DELETE FROM CLIENTES
	WHERE COD_CLIENTE = @COD_CLIENTE
END
GO
--====================================================================
--SELECIONAR CLIENTE
CREATE PROCEDURE Listar_Cliente
	@COD_CLIENTE INT
AS
BEGIN
	SELECT* 
	FROM CLIENTES
	WHERE COD_CLIENTE = @COD_CLIENTE
END
GO

--ALTERAR CLIENTE====================================================
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
	@DATANASCIMENTO NUMERIC(2,0)
AS
BEGIN
	UPDATE CLIENTES SET RG = @RG, BAIRRO = @BAIRRO, ESTADO = @ESTADO, NOME = @NOME, CIDADE = @CIDADE, TELEFONE = @TELEFONE, EMAIL = @EMAIL, COD_CLIENTE = @COD_CLIENTE, DATANASCIMENTO = @DATANASCIMENTO, Sexo = @Sexo
	WHERE COD_CLIENTE = @COD_CLIENTE
END 
GO


CREATE PROCEDURE Aniversariente_Cliente
	@DATANASCIMENTO NUMERIC (2,0)
	@MES
AS
BEGIN
	SELECT NOME, DATANASCIMENTO 
	FROM CLIENTES
	WHERE DATANASCIMENTO = @DATANASCIMENTO 
	AS
END
GO


============================================================
-- ALTERAÇÕES NAS TABELAS (exercícios 5 e 6)

ALTER TABLE Filme
    ADD COLUMN Status VARCHAR(10) DEFAULT 'Disponível';

ALTER TABLE Locacoes
    ADD COLUMN Data_Devolucao DATE NULL;

-- ============================================================
CREATE PROCEDURE proc_Aniversariantes_Mes (IN p_Mes INT)
SELECT Nome, DAY(Data_Nasc) AS Dia
FROM Clientes
WHERE MONTH(Data_Nasc) = p_Mes
ORDER BY Dia;


-- ============================================================
-- 3. RESUMO DE ANIVERSARIANTES POR MÊS
-- Meses sem aniversariantes aparecem com 0 
CREATE PROCEDURE Resumo_Aniversariantes()
SELECT 
    m.Mes,
    MONTHNAME(STR_TO_DATE(CONCAT('2000-', m.Mes, '-01'), '%Y-%m-%d')) AS Nome_Mes,
    COUNT(c.ID_Cliente) AS Total_Aniversariantes
FROM (
    SELECT 1 AS Mes UNION SELECT 2 UNION SELECT 3 UNION SELECT 4
    UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8
    UNION SELECT 9 UNION SELECT 10 UNION SELECT 11 UNION SELECT 12
) AS m
LEFT JOIN Clientes c 
    ON MONTH(c.Data_Nasc) = m.Mes
GROUP BY m.Mes
ORDER BY m.Mes;

============================================================
-- 4. CLIENTES DE UMA CIDADE COM IDADE <= SOLICITADA
-- Resultado: [Nome do Cliente] | [Data Nascimento] | [Idade]
CREATE PROCEDURE Clientes_Cidade_Idade (
    IN p_Cidade VARCHAR(80),
    IN p_Idade_Max INT
)
SELECT 
    Nome AS Nome_Cliente,
    Data_Nasc AS Data_Nascimento,
    TIMESTAMPDIFF(YEAR, Data_Nasc, CURDATE()) AS Idade
FROM Clientes
WHERE Cidade = p_Cidade
  AND TIMESTAMPDIFF(YEAR, Data_Nasc, CURDATE()) <= p_Idade_Max
ORDER BY Nome;


-- ============================================================
-- 5. INCLUIR LOCAÇÃO
-- Data_Locacao vem do sistema; marca filme como 'alugado'
CREATE PROCEDURE Incluir_Locacao (
    IN p_ID_Cliente INT,
    IN p_ID_Filme INT
)
BEGIN
    INSERT INTO Locacoes (ID_Cliente, ID_Filme, Data_Locacao, Data_Devolucao)
    VALUES (p_ID_Cliente, p_ID_Filme, CURDATE(), NULL);

    UPDATE Filme
    SET Status = 'alugado'
    WHERE ID_Filme = p_ID_Filme;
END;


-- ============================================================
-- 6. DEVOLVER FILME
-- Registra Data_Devolucao e volta Status para 'Disponível'
CREATE PROCEDURE Devolver_Filme (
    IN p_ID_Locacao INT
)
BEGIN
    UPDATE Locacoes
    SET Data_Devolucao = CURDATE()
    WHERE ID_Locacao = p_ID_Locacao;

    UPDATE Filme
    SET Status = 'Disponível'
    WHERE ID_Filme = (
        SELECT ID_Filme 
        FROM Locacoes 
        WHERE ID_Locacao = p_ID_Locacao
    );
END;

-- 4 criar um procedimento armazenado que liste os clientes de uma cidade espectativa com 
-- idade menor ou igual a solicitada. a resultante ter  3 colunas: 
-- [Nome do cliente] [Data de nascimento] [Idade]


===========================================================================================


-- TABELA PRODUTO
CREATE TABLE Produto
(
	ID_PRODUTO INT PRIMARY KEY identity(1,1),
	DESCRICAO VARCHAR(50),
	PRECO DECIMAL(10,2)
);


-- TABELA SALDO
CREATE TABLE Saldo
(
	ID_PRODUTO INT FOREIGN KEY REFERENCES Produto (ID_PRODUTO),
	Saldo_Produto INT
);

-- TABELA COMPRA
CREATE TABLE Compra
(
	ID_COMPRA INT PRIMARY KEY identity(1,1),
	ID_PRODUTO INT,
	DATA_COMPRA datetime,
	DESCRICAO varchar(80),
	UN int,
	PRECO decimal(3,2),
	QTD_Compra INT
);

-- TABELA VENDA
CREATE TABLE Venda
(
	ID_VENDA INT PRIMARY KEY identity(1,1),
	ID_PRODUTO INT,
	QTD_Venda INT,
	Valor_Total DECIMAL(10,2),
	n_parcelas INT,
	DATA_VENDA DATE
);

-- TABELA CONTAS A RECEBER
CREATE TABLE Contas_Receber
(
	ID_Venda INT FOREIGN KEY REFERENCES Venda (ID_VENDA),
	Num_Parcela INT,
	Data_Vencimento DATE,
	Valor_Parcela MONEY
);


-- TABELA FERIADOS
CREATE TABLE Feriados
(
	Data_Feriado DATE
);


-- PRODUTOS


INSERT INTO Produto
VALUES
(1,'Shampoo',20.00),
(2,'Condicionador',25.00);

-- SALDO INICIAL

INSERT INTO Saldo
VALUES
(1,100),
(2,100);

-- FERIADO

INSERT INTO Feriados
VALUES
('2026-12-25');

-- TRIGGER VENDA
CREATE TRIGGER TRG_VENDA
ON Venda
AFTER INSERT
AS
BEGIN

	UPDATE Saldo
	SET Saldo_Produto = Saldo_Produto - inserted.QTD_Venda
	FROM inserted
	WHERE Saldo.ID_PRODUTO = inserted.ID_PRODUTO;

END;

-- TRIGGER COMPRA
CREATE TRIGGER TRG_COMPRA
ON Compra
AFTER INSERT
AS
BEGIN

	UPDATE Saldo
	SET Saldo_Produto = Saldo_Produto + inserted.QTD_Compra
	FROM inserted
	WHERE Saldo.ID_PRODUTO = inserted.ID_PRODUTO;

END;

-- TRIGGER PARCELAS

CREATE TRIGGER TRG_PARCELAS
ON Venda
AFTER INSERT
AS
BEGIN

	DECLARE @ID INT
	DECLARE @VALOR MONEY
	DECLARE @PARCELAS INT
	DECLARE @VALORPARCELA MONEY
	DECLARE @DATA DATE
	DECLARE @I INT = 1

	SELECT
		@ID = ID_VENDA,
		@VALOR = Valor_Total,
		@PARCELAS = n_parcelas,
		@DATA = DATA_VENDA
	FROM inserted

	SET @VALORPARCELA = @VALOR / @PARCELAS

	WHILE @I <= @PARCELAS
	BEGIN

		INSERT INTO Contas_A_Receber
		VALUES
		(
			@ID,
			@I,
			DATEADD(MONTH,@I,@DATA),
			@VALORPARCELA
		)

		SET @I = @I + 1

	END

END;

-- ===================================
-- TESTE COMPRA
-- ===================================

INSERT INTO Compra
VALUES
(1,2,25);

-- ===================================
-- TESTE VENDA
-- ===================================

INSERT INTO Venda
VALUES
(1,1,5,300,3,GETDATE());

-- ===================================
-- CONSULTAS
-- ===================================

SELECT * FROM Produto;
SELECT * FROM Saldo;
SELECT * FROM Compra;
SELECT * FROM Venda;
SELECT * FROM Contas_A_Receber;
