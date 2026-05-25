--caso opte por criar uma Tabela de Movimentos, a tabela deverá ter a
--coluna Tipo_Movimento onde 'S' seria saída e 'E' entrada.
--Se manter separado, criar também:
1) Ao ser inserida uma Venda, disparar um Trigger para Subtrair a QTD_Venda
   do Saldo do Produto (Update na tabela Saldo)
 
2) Ao ser inserida uma Venda, disparar um Trigger para Somar a QTD_Compra
   do Saldo do Produto (Update na tabela Saldo)
 
3) Financeiro...
   Acrescentar na tabela Venda a coluna n_parcelas tipo int
   Ao inserir uma linha na tabela Venda, em relação ao n_parcelas:
     No Trigger AO_Inserir_Venda:
   - Dividir o Valor_Total_Venda por n_parcelas para saber o valor mensal
   - Gerar na Tabela Contas_A_Receber as linhas:
     ID_Venda int
     num Parcela int
     Data_Vencimento date
     Valor_Parcela Money
     Data_Pagamento date
 
  OBS: A Data de Vencimento deve ser um dia Útil (Não Sábado, Não Domingo, Não Feriado)
       Para isso, criar a Tabela Feriados_Fixos e Feriados_Do_Ano:
       Data_Feirado date
       Descrição nvarchar(50)
	
CREATE TABLE Produto
(
	ID_PRODUTO int primary key,
	DESCRICAO varchar(80),
	UN int,  --Exemplo: 'pc','un','mt','kg'
)

CREATE TABLE Venda
(
	ID_Cliente int,
   	ID_Produto int,
	ID_VENDA int primary key,
	DATA_VENDA datetime,
  	QTD_Venda int,
   	Valor_Total,
   	Numero_Parcelas int	PRECO float,
	ID_PRODUTO int,
	constraint ID_PRODUTO,
	foreign key (ID_PRODUTO),
	references Produto(ID_PRODUTO)
)

CREATE TABLE Compra
(
	ID_COMPRA int primary key,
	ID_PRODUTO int,
	DATA_COMPRA datetime,
	DESCRICAO varchar(80),
	UN int,
	PRECO decimal(3,2),
	Numero_Parcelas int,
	QTD_Compra int,
   Valor_Total
)

CREATE TABLE Saldo
(
	ID_PRODUTO int primary key,
    Saldo produto decimal
)

CREATE TABLE Feriados_Si
(
-- se a data estiver contida na tabela de feriado 

	ID_Feriado varchar(100),
	Descricao varchar(120),
	Data_feriado date
)

CREATE TABLE Feriados
(
-- data 
-- descrição do feriado
)

CREATE TABLE Contas_A_Receber (
    ID_Venda INT,
    Num_Parcela INT,
    Data_Vencimento DATE,
    Valor_Parcela MONEY,
    Data_Pagamento DATE
);

INSERT INTO Produto (ID_PRODUTO, DESCRICAO, UN, PRECO)
VALUES
(01, 'Esmalte Vermelho Paixao', 101, 3.00),
(02, 'Esmalte Branco Neve', 102, 3.00),
(03, 'Esmalte Preto Galaxia', 103, 3.00),
(04, 'Esmalte Azul Royal', 104, 3.00),
(05, 'Esmalte Amarelindo', 105, 3.59),
(06, 'Shampoo Elseve', 201, 31.59),
(07, 'Condicionador Elseve', 202, 31.59),
(08, 'Shampoo Eudora', 203, 67.99),
(09, 'Condicionador Eudora', 204, 67.99),
(10, 'Shampoo Dove', 205, 26.68),
(11, 'Condicionador Dove', 206, 26.68),
(12, 'Gloss Coca-Cola Bruna Tavares', 301, 59,76),
(12, 'Gloss Framboesa Francine Elke', 302, 70,00),
(13, 'Gloss Lip Bunny Francine Elke', 303, 69,90),
(14, 'Gloss Batom Vult', '304', 19.90),
(15, 'Gloss Carmed OakBerry Açai Hidratante', 305, 25,00),
(16, 'Hidratante Corporal CeraVe com Acido Hialuronico', 401, 83,61),
(17, 'Hidratante Corporal Victoria Secrets Bare Vanilla', '402', 145.00),
(18, 'Hidratante Corporal Neutrogena Sem Fragrância', 71.49),
(19, 'Hidratante Corporal Nativa SPA', '404', 58,90),
(20, 'Hidratante Corporal Oboticario Cuide-se Bem Amoruda ', '405', 78.90)


INSERT INTO Feriados_Si(ID_Feriado, Descricao ,Data_feriado)
VALUES
(1, 'Confraternização Universal', '2026-01-01', 'Nacional'),
(2, 'Carnaval', '2026-02-17', 'Ponto Facultativo'),
(3, 'Paixão de Cristo', '2026-04-03', 'Nacional'),
(4, 'Tiradentes', '2026-04-21', 'Nacional'),
(5, 'Dia do Trabalho', '2026-05-01', 'Nacional'),
(6, 'Independência do Brasil', '2026-09-07', 'Nacional'),
(7, 'Nossa Senhora Aparecida', '2026-10-12', 'Nacional'),
(8, 'Finados', '2026-11-02', 'Nacional'),
(9, 'Proclamação da República', '2026-11-15', 'Nacional'),
(10, 'Natal', '2026-12-25', 'Nacional')

IF EXISTS (
    SELECT 1
    FROM Feriados_Si
    WHERE DATA_FERIADO = GETDATE()
)
BEGIN
    PRINT 'Hoje é feriado'
END
ELSE
BEGIN
    PRINT 'Hoje não é feriado'
END

ALTER TABLE Venda
ADD n_parcelas INT;


CREATE TRIGGER AO_Inserir_Venda
ON Venda
AFTER INSERT
AS
BEGIN

    DECLARE @ID_Venda INT
    DECLARE @Valor_Total MONEY
    DECLARE @N_Parcelas INT
    DECLARE @Valor_Parcela MONEY
    DECLARE @Contador INT = 1
    DECLARE @Data_Venda DATE

    -- Pegando os dados da venda inserida
    SELECT
        @ID_Venda = ID_Venda,
        @Valor_Total = Valor_Total_Venda,
        @N_Parcelas = n_parcelas,
        @Data_Venda = GETDATE()
    FROM inserted

    -- Calculando valor da parcela
    SET @Valor_Parcela = @Valor_Total / @N_Parcelas

    -- Gerando parcelas
    WHILE @Contador <= @N_Parcelas
    BEGIN

        INSERT INTO Contas_A_Receber (
            ID_Venda,
            Num_Parcela,
            Data_Vencimento,
            Valor_Parcela,
            Data_Pagamento
        )
        VALUES (
            @ID_Venda,
            @Contador,
            DATEADD(MONTH, @Contador, @Data_Venda),
            @Valor_Parcela,
            NULL
        )

        SET @Contador = @Contador + 1

    END

END;
--exercicio:


--1 --- ao ser inserida uma venda, disparar um trigger para subtrair a qtd venda do saldo do prodtuo (update na tabela saldo)

--2 --- ao ser inserida uma venda, disparar um trigger para somar a qtd compra do saldpo do produto (update na tabela saldo)

--3 -- financeiro: acrescentar na tabela venda a coluna n_parcelas tipo int - ao inserir uma linha na tabela venda, em relação ao n_parcelas 
	-- No trigger ao inserir venda:
	-- dividir o valor total venda por n_parcelas oara saber o valor mensal
	-- gerar na tablea contas a receber as linhas:
	-- ID_venda int
	-- num parcela in
	-- data_vencimento date
	-- valor_Parcela money
	-- data_pagamento date


-- OBS: A data de vencimento deve ser um dia Útil nao sábado, nao domingo, nao feriado, para isso 
-- criar a tabela feriados_fixos e feriados_do_ano:

-- Data_Feriado date
-- Descrição nvarchar(50)

--Detalhe: 
-- para verificar se uma data é feriado fixo, bastante 
-- para verificar se uma data é

-- se for dia 7 somar mais 1, 2 ou 3 para chegar até um dia util










