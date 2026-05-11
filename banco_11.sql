CREATE TABLE Produto
(
	ID_PRODUTO int primary key,
	DESCRICAO varchar(80),
	UN int,
	PRECO float
)

CREATE TABLE Venda
(
	ID_VENDA int primary key,
	DATA_VENDA datetime,
	UN int,
	PRECO float,
	ID_PRODUTO int,
	constraint ID_PRODUTO
	foreign key (ID_PRODUTO)
	references Produto(ID_PRODUTO)
)

CREATE TABLE Compra
(
	ID_COMPRA int primary key,
	ID_PRODUTO int,
	DATA_COMPRA datetime,
	DESCRICAO varchar(80),
	UN int,
	PRECO decimal(3,2)
)

CREATE TABLE Saldo
(
	ID_PRODUTO int primary key,
	QTD int
)


INSERT INTO Produto (ID_PRODUTO, DESCRICAO, UN, PRECO)
VALUES
(01, 'Esmalte Vermelho Paixao', '101', 'R$3,00')
(02, 'Esmalte Branco Neve', '102', 'R$3,00')
(03, 'Esmalte Preto Galaxia', '103', 'R$3,00',)
(04, 'Esmalte Azul Royal', '104', 'R$3,00',)
(05, 'Esmalte Amarelindo', '105', 'R$3,00',)
(06, 'Shampoo Elseve', '201', 'R$31,59',)
(07, 'Condicionador Elseve', '202', 'R$31,59',)
(08, 'Shampoo Eudora', '203', 'R$67,99',)
(09, 'Condicionador Eudora', '204', 'R$67,99',)
(10, 'Shampoo Dove', '205', 'R$26,68',)
(11, 'Condicionador Dove', '206', 'R$26,68',)
(12, 'Gloss Coca-Cola Bruna Tavares', '301', 'R$59,76',)
(12, 'Gloss Framboesa Francine Elke', '302', 'R$70,00',)
(13, 'Gloss Lip Bunny Francine Elke', '303', 'R$69,90',)
(14, 'Gloss Batom Vult', '304', 'R$19,90',)
(15, 'Gloss Carmed OakBerry Açai Hidratante', '305', 'R$25,00',)
(16, 'Hidratante Corporal CeraVe com Acido Hialuronico', '401', 'R$83,61',)
(17, 'Hidratante Corporal Victoria Secrets Bare Vanilla', '402', 'R$145,00',)
(18, 'Hidratante Corporal Neutrogena Sem Fragrância', '403', 'R$71,49',)
(19, 'Hidratante Corporal Nativa SPA', '404', 'R$58,90',)
(20, 'Hidratante Corporal Oboticario Cuide-se Bem Amoruda ', '405', 'R$78,90',)
