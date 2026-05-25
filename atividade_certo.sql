-- TABELA PRODUTO
CREATE TABLE Produto
(
	ID_PRODUTO INT PRIMARY KEY,
	DESCRICAO VARCHAR(50),
	PRECO DECIMAL(10,2)
);

-- TABELA SALDO
CREATE TABLE Saldo
(
	ID_PRODUTO INT PRIMARY KEY,
	Saldo_Produto INT
);

-- TABELA COMPRA
CREATE TABLE Compra
(
	ID_COMPRA INT PRIMARY KEY,
	ID_PRODUTO INT,
	QTD_Compra INT
);

-- TABELA VENDA
CREATE TABLE Venda
(
	ID_VENDA INT PRIMARY KEY,
	ID_PRODUTO INT,
	QTD_Venda INT,
	Valor_Total DECIMAL(10,2),
	n_parcelas INT,
	DATA_VENDA DATE
);

-- TABELA CONTAS A RECEBER
CREATE TABLE Contas_A_Receber
(
	ID_Venda INT,
	Num_Parcela INT,
	Data_Vencimento DATE,
	Valor_Parcela MONEY
);

-- TABELA FERIADOS
CREATE TABLE Feriados
(
	Data_Feriado DATE
);

-- ===================================
-- PRODUTOS
-- ===================================

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

-- ===================================
-- TRIGGER VENDA
-- DIMINUI ESTOQUE
-- ===================================

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

-- ===================================
-- TRIGGER COMPRA
-- AUMENTA ESTOQUE
-- ===================================

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

-- ===================================
-- TRIGGER PARCELAS
-- ===================================

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
(1,1,20);

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
