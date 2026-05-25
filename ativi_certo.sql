-- =========================================
-- CRIAÇÃO DAS TABELAS
-- =========================================

CREATE TABLE Produto
(
	ID_PRODUTO INT PRIMARY KEY,
	DESCRICAO VARCHAR(80),
	UN INT,
	PRECO DECIMAL(10,2)
);

-- =========================================

CREATE TABLE Saldo
(
	ID_PRODUTO INT PRIMARY KEY,
	Saldo_Produto INT,

	FOREIGN KEY (ID_PRODUTO)
	REFERENCES Produto(ID_PRODUTO)
);

-- =========================================

CREATE TABLE Compra
(
	ID_COMPRA INT PRIMARY KEY,
	ID_PRODUTO INT,
	DATA_COMPRA DATETIME,
	QTD_Compra INT,
	Valor_Total DECIMAL(10,2),

	FOREIGN KEY (ID_PRODUTO)
	REFERENCES Produto(ID_PRODUTO)
);

-- =========================================

CREATE TABLE Venda
(
	ID_VENDA INT PRIMARY KEY,
	ID_Cliente INT,
	ID_PRODUTO INT,
	DATA_VENDA DATETIME,
	QTD_Venda INT,
	Valor_Total DECIMAL(10,2),
	n_parcelas INT,

	FOREIGN KEY (ID_PRODUTO)
	REFERENCES Produto(ID_PRODUTO)
);

-- =========================================

CREATE TABLE Feriados
(
	ID_Feriado INT PRIMARY KEY,
	Descricao VARCHAR(120),
	Data_Feriado DATE
);

-- =========================================

CREATE TABLE Contas_A_Receber
(
	ID_Venda INT,
	Num_Parcela INT,
	Data_Vencimento DATE,
	Valor_Parcela MONEY,
	Data_Pagamento DATE
);

-- =========================================
-- INSERT PRODUTOS
-- =========================================

INSERT INTO Produto
VALUES
(1, 'Esmalte Vermelho Paixao', 101, 3.00),
(2, 'Esmalte Branco Neve', 102, 3.00),
(3, 'Esmalte Preto Galaxia', 103, 3.00),
(4, 'Esmalte Azul Royal', 104, 3.00),
(5, 'Esmalte Amarelindo', 105, 3.59),
(6, 'Shampoo Elseve', 201, 31.59),
(7, 'Condicionador Elseve', 202, 31.59),
(8, 'Shampoo Eudora', 203, 67.99),
(9, 'Condicionador Eudora', 204, 67.99),
(10, 'Shampoo Dove', 205, 26.68);

-- =========================================
-- SALDO INICIAL
-- =========================================

INSERT INTO Saldo
VALUES
(1, 100),
(2, 100),
(3, 100),
(4, 100),
(5, 100),
(6, 100),
(7, 100),
(8, 100),
(9, 100),
(10, 100);

-- =========================================
-- FERIADOS
-- =========================================

INSERT INTO Feriados
VALUES
(1, 'Confraternização Universal', '2026-01-01'),
(2, 'Carnaval', '2026-02-17'),
(3, 'Paixão de Cristo', '2026-04-03'),
(4, 'Tiradentes', '2026-04-21'),
(5, 'Dia do Trabalho', '2026-05-01'),
(6, 'Independência do Brasil', '2026-09-07'),
(7, 'Nossa Senhora Aparecida', '2026-10-12'),
(8, 'Finados', '2026-11-02'),
(9, 'Proclamação da República', '2026-11-15'),
(10, 'Natal', '2026-12-25');

-- =========================================
-- TRIGGER 1
-- BAIXAR ESTOQUE NA VENDA
-- =========================================

CREATE TRIGGER TRG_BAIXAR_ESTOQUE
ON Venda
AFTER INSERT
AS
BEGIN

	-- VERIFICA ESTOQUE
	IF EXISTS
	(
		SELECT 1
		FROM Saldo S
		INNER JOIN inserted I
			ON S.ID_PRODUTO = I.ID_PRODUTO
		WHERE S.Saldo_Produto < I.QTD_Venda
	)
	BEGIN
		RAISERROR('Estoque insuficiente.',16,1);
		ROLLBACK TRANSACTION;
		RETURN;
	END

	-- BAIXA ESTOQUE
	UPDATE S
	SET S.Saldo_Produto = S.Saldo_Produto - I.QTD_Venda
	FROM Saldo S
	INNER JOIN inserted I
		ON S.ID_PRODUTO = I.ID_PRODUTO;

END;

-- =========================================
-- TRIGGER 2
-- AUMENTAR ESTOQUE NA COMPRA
-- =========================================

CREATE TRIGGER TRG_AUMENTAR_ESTOQUE
ON Compra
AFTER INSERT
AS
BEGIN

	UPDATE S
	SET S.Saldo_Produto = S.Saldo_Produto + I.QTD_Compra
	FROM Saldo S
	INNER JOIN inserted I
		ON S.ID_PRODUTO = I.ID_PRODUTO;

END;

-- =========================================
-- TRIGGER 3
-- GERAR CONTAS A RECEBER
-- =========================================

CREATE TRIGGER AO_Inserir_Venda
ON Venda
AFTER INSERT
AS
BEGIN

	DECLARE @ID_Venda INT;
	DECLARE @Valor_Total MONEY;
	DECLARE @N_Parcelas INT;
	DECLARE @Valor_Parcela MONEY;
	DECLARE @Contador INT = 1;
	DECLARE @Data_Venda DATE;
	DECLARE @DataVencimento DATE;

	SELECT
		@ID_Venda = ID_VENDA,
		@Valor_Total = Valor_Total,
		@N_Parcelas = n_parcelas,
		@Data_Venda = CAST(DATA_VENDA AS DATE)
	FROM inserted;

	SET @Valor_Parcela = @Valor_Total / @N_Parcelas;

	WHILE @Contador <= @N_Parcelas
	BEGIN

		SET @DataVencimento =
			DATEADD(MONTH, @Contador, @Data_Venda);

		-- AJUSTAR SE FOR FINAL DE SEMANA
		WHILE
			DATENAME(WEEKDAY, @DataVencimento) IN ('Saturday','Sunday')
			OR EXISTS
			(
				SELECT 1
				FROM Feriados
				WHERE Data_Feriado = @DataVencimento
			)

		BEGIN

			SET @DataVencimento =
				DATEADD(DAY,1,@DataVencimento);

		END

		INSERT INTO Contas_A_Receber
		(
			ID_Venda,
			Num_Parcela,
			Data_Vencimento,
			Valor_Parcela,
			Data_Pagamento
		)
		VALUES
		(
			@ID_Venda,
			@Contador,
			@DataVencimento,
			@Valor_Parcela,
			NULL
		);

		SET @Contador = @Contador + 1;

	END

END;

-- =========================================
-- TESTE DE COMPRA
-- =========================================

INSERT INTO Compra
VALUES
(
	1,
	1,
	GETDATE(),
	50,
	150.00
);

-- =========================================
-- TESTE DE VENDA
-- =========================================

INSERT INTO Venda
VALUES
(
	1,
	1,
	1,
	GETDATE(),
	5,
	500.00,
	3
);

-- =========================================
-- CONSULTAS
-- =========================================

SELECT * FROM Produto;

SELECT * FROM Saldo;

SELECT * FROM Compra;

SELECT * FROM Venda;

SELECT * FROM Contas_A_Receber;
