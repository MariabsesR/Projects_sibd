-- ----------------------------------------------------------------------------
-- Sistemas de Informação e Bases de Dados - António Ferreira, DI-FCUL.
-- Tabelas para a etapa 4 do projeto de SIBD de 2022/2023.


-- Sistemas de Informação e Bases de Dados - 2022/2023- Etapa 3- Grupo 52 
-- Maria Rocha, 58208, TP11
-- Sara Canhoto, 43177, TP16
-- André Santos, 57538, TP16
-- Martim Santos, 58244, TP16
-- ----------------------------------------------------------------------------
DROP TABLE linhafatura;
DROP TABLE fatura;
DROP TABLE produto CASCADE CONSTRAINT;
DROP TABLE cliente;

-- ----------------------------------------------------------------------------

CREATE TABLE cliente (
  nif        NUMBER  (9),
  nome       VARCHAR (20) CONSTRAINT nn_cliente_nome       NOT NULL,
  genero     CHAR    (1)  CONSTRAINT nn_cliente_genero     NOT NULL,
  nascimento NUMBER  (4)  CONSTRAINT nn_cliente_nascimento NOT NULL,  -- Ano.
  localidade VARCHAR (20) CONSTRAINT nn_cliente_localidade NOT NULL,
--
  CONSTRAINT pk_cliente
    PRIMARY KEY (nif),
--
  CONSTRAINT ck_cliente_nif  -- RIA 16.
    CHECK (nif BETWEEN 100000000 AND 999999999),
--
  CONSTRAINT ck_cliente_genero  -- RIA 17.
    CHECK (genero IN ('F', 'M')),
--
  CONSTRAINT ck_cliente_nascimento
    CHECK (nascimento >= 1900)  -- Valor razoável.
);

-- ----------------------------------------------------------------------------

CREATE TABLE produto (
  ean13      NUMBER  (13),
  nome       VARCHAR (20)  CONSTRAINT nn_produto_nome      NOT NULL,
  categoria  CHAR    (7)   CONSTRAINT nn_produto_categoria NOT NULL,
  preco      NUMBER  (6,2) CONSTRAINT nn_produto_preco     NOT NULL,
  stock      NUMBER  (4)   CONSTRAINT nn_produto_stock     NOT NULL,
--
  CONSTRAINT pk_produto
    PRIMARY KEY (ean13),
--
  CONSTRAINT ck_produto_ean13  -- RIA 11.
    CHECK (ean13 BETWEEN 1000000000000 AND 9999999999999),
--
  CONSTRAINT ck_produto_categoria  -- RIA 13.
    CHECK (categoria IN ('Comida', 'Roupa', 'Beleza', 'Animais')),
--
  CONSTRAINT ck_produto_preco  -- RIA 14.
    CHECK (preco > 0.0),
--
  CONSTRAINT ck_produto_stock
    CHECK (stock >= 0)
);

-- ----------------------------------------------------------------------------

CREATE TABLE fatura (
  numero  NUMBER (6),
  data    DATE        CONSTRAINT nn_fatura_data    NOT NULL,
  cliente             CONSTRAINT nn_fatura_cliente NOT NULL,
--
  CONSTRAINT pk_fatura
    PRIMARY KEY (numero),
--
  CONSTRAINT fk_fatura_cliente
    FOREIGN KEY (cliente)
    REFERENCES cliente (nif),
--
  CONSTRAINT ck_fatura_numero  -- RIA 18.
    CHECK (numero >= 1)
);

-- ----------------------------------------------------------------------------

CREATE TABLE linhafatura (
  fatura,
  produto,
  unidades NUMBER (4) CONSTRAINT nn_linhafatura_unidades NOT NULL,
--
  CONSTRAINT pk_linhafatura
    PRIMARY KEY (fatura, produto),
--
  CONSTRAINT fk_linhafatura_fatura
    FOREIGN KEY (fatura)
    REFERENCES fatura (numero),
--
  CONSTRAINT fk_linhafatura_produto
    FOREIGN KEY (produto)
    REFERENCES produto (ean13),
--
  CONSTRAINT ck_linhafatura_unidades  -- RIA 19.
    CHECK (unidades > 0)
);

-- ----------------------------------------------------------------------------