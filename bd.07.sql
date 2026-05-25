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
