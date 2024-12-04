-- Tabela Produto
CREATE TABLE Produto (
    Codigo INT PRIMARY KEY,
    Nome NVARCHAR(100) NOT NULL,
    Descricao NVARCHAR(255) NOT NULL,
	Fornecedor NVARCHAR(14) NOT NULL DEFAULT '10230480001960', -- Fornecedor fixo
    PrecoUnitario DECIMAL(10, 2) NOT NULL,
    CodigoBarras NVARCHAR(50) UNIQUE NOT NULL,
    QtdeEstoque INT NOT NULL DEFAULT 0
);

-- Tabela SfcPedidoVenda (Cabe�alho da Venda)
CREATE TABLE SfcPedidoVenda (
    Nota NVARCHAR(7) PRIMARY KEY, -- Nota auto gerada como chave prim�ria
    Tipo NVARCHAR(2) NOT NULL DEFAULT 'VD'
    DataMovim DATE NOT NULL DEFAULT GETDATE(),
	Loja INT NOT NULL DEFAULT 0,
    Cliente NVARCHAR(255) NOT NULL DEFAULT�'Desconhecido',
    ValorTotal DECIMAL(12, 2) NOT NULL DEFAULT 0
);

-- Tabela SfcPedidoVendaIt (Itens do Pedido)
CREATE TABLE SfcPedidoVendaIt (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    PedidoId NVARCHAR(7) NOT NULL, -- Relaciona com Nota
    Produto NVARCHAR(100) NOT NULL,
    PrecoUnit DECIMAL(10, 2) NOT NULL,
    Qtde INT NOT NULL,
    ICMS DECIMAL(10, 2) NOT NULL DEFAULT 0,
    IPI DECIMAL(10, 2) NOT NULL DEFAULT 0,
    Subtotal AS (PrecoUnit * Qtde) PERSISTED,
    Total AS (PrecoUnit * Qtde + ICMS + IPI) PERSISTED,
    FOREIGN KEY (PedidoId) REFERENCES SfcPedidoVenda(Nota) ON DELETE CASCADE
);


CREATE TRIGGER trg_UpdateValorTotal
ON SfcPedidoVendaIt
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    UPDATE SfcPedidoVenda
    SET ValorTotal = (
        SELECT SUM(Total)
        FROM SfcPedidoVendaIt
        WHERE SfcPedidoVendaIt.PedidoId = SfcPedidoVenda.Nota
    )
    WHERE Nota IN (
        SELECT DISTINCT PedidoId FROM Inserted
        UNION
        SELECT DISTINCT PedidoId FROM Deleted
    );
END;

CREATE TRIGGER trg_NotaAutoIncrement
ON SfcPedidoVenda
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @NovoId INT;
    DECLARE @NotaGerada NVARCHAR(7);

    -- Obter o pr�ximo n�mero de Nota baseado no maior valor atual
    SELECT @NovoId = ISNULL(MAX(CAST(Nota AS INT)), 0) + 1 FROM SfcPedidoVenda;

    -- Gerar a Nota no formato '0000001'
    SET @NotaGerada = RIGHT('0000000' + CAST(@NovoId AS NVARCHAR(7)), 7);

    -- Inserir com a Nota auto gerada, mantendo os demais campos do INSERT original
    INSERT INTO SfcPedidoVenda (Nota, Tipo, DataMovim, ValorTotal, Loja, Cliente)
    SELECT @NotaGerada, DataMovim, ValorTotal, Loja, Cliente
    FROM Inserted;
END;
