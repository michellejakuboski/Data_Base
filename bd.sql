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


INSERT INTO Produto (ID_PRODUTO,DESCRICAO,UN,PRECO)
VALUES(01, '', '1', 10,)
