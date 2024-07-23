-- ----------------------------------------------------------------------------
-- Sistemas de Informação e Bases de Dados - 2022/2023-Etapa 2- Grupo 52 
-- Maria Rocha, 58208, TP11
-- Sara Canhoto, 43177, TP16
-- André Santos, 57538, TP16
-- Martim Santos, 58244, TP16
-- ----------------------------------------------------------------------------
-- RIA suportadas: 1, 4,8(parcialmente suportada), 9, 11(parcialmente suportada) 12, 14, 16(parcialmente suportada).
-- Não suportadas: 2, 3, 5, 6, 7, 10, 13, 15, 17, 18, 19, 20.
-- ----------------------------------------------------------------------------
-- Novas RIAs: 21-Fornece tem de ter pelo menos 1 produto
               22-Fornece tem de ter pelo menos 1 existe
               23-Loja tem de ter pelo menos 1 ano
-- ----------------------------------------------------------------------------
DROP TABLE fatura;
DROP TABLE oferece;
DROP TABLE fornece;
DROP TABLE fornecedor;
DROP TABLE cliente ;
DROP TABLE existe ;
DROP TABLE ano;
DROP TABLE loja;
DROP TABLE pessoa_coletiva;
DROP TABLE produto;
-- --------------------------------------------------------
CREATE TABLE produto (
    ean13 NUMBER(13), 
    nome  VARCHAR(40),
    peso  NUMBER(4,2),
    largura NUMBER(4,2),
    altura NUMBER(4,2),
    profundidade NUMBER(4,2),
    categoria CHAR(10),
--
    CONSTRAINT pk_produto
        PRIMARY KEY (ean13),
--
    CONSTRAINT ck_produto_ean13
        CHECK (ean13>0),  --RIA 11
--
    CONSTRAINT ck_produto_peso
        CHECK (peso>0.0), --RIA 12
--
    CONSTRAINT ck_produto_largura
        CHECK (largura>0.0), --RIA 12
--
    CONSTRAINT ck_produto_altura
        CHECK (altura>0.0),  --RIA 12
--
    CONSTRAINT ck_produto_profundidade
        CHECK (profundidade>0.0)  --RIA 12
);
-- -------------------------------------------------------------------------------
CREATE TABLE pessoa_coletiva (
    nipc NUMBER(9),
    telefone NUMBER(9),      
    nome VARCHAR(40) CONSTRAINT un_pessoa_coletiva_nome UNIQUE, --RIA 9
--
    CONSTRAINT pk_pessoa_coletiva
        PRIMARY KEY (nipc),  --RIA 8
--
    CONSTRAINT ck_pessoa_coletiva_nipc
        CHECK (nipc>0),         -- RIA 8    
--
    CONSTRAINT ck_pessoa_coletiva_telefone
        CHECK (telefone>0)
);
-- ----------------------------------------------------------------------------
CREATE TABLE loja (
    nipc NUMBER(9), --RIA 23
--
    CONSTRAINT pk_loja
        PRIMARY KEY (nipc),
--
    CONSTRAINT fk_loja_pessoa_coletiva
        FOREIGN KEY (nipc)                         
        REFERENCES pessoa_coletiva (nipc)                   
        ON DELETE CASCADE,                    
--
    CONSTRAINT ck_loja_nipc
        CHECK (nipc>0)
);
-- -----------------------------------------------------------------------
CREATE TABLE ano (
    ano NUMBER (4),
--
    CONSTRAINT pk_ano
        PRIMARY KEY (ano),
--
    CONSTRAINT ck_ano_ano
        CHECK (ano>=1970) --RIA 4
);
-- ----------------------------------------------------------------------------
CREATE TABLE existe(
    loja_nipc NUMBER(9), 
    ano NUMBER (4),
--
    CONSTRAINT pk_existe
        PRIMARY KEY (loja_nipc,ano), 
--
    CONSTRAINT fk_existe_loja
        FOREIGN KEY (loja_nipc)                         
        REFERENCES loja (nipc), 
--
    CONSTRAINT fk_existe_ano
        FOREIGN KEY (ano)                         
        REFERENCES ano (ano),
--  
    CONSTRAINT ck_existe_ano
        CHECK (ano>=1970),
--
    CONSTRAINT ck_existe_loja_nipc 
        CHECK (loja_nipc>0)
); 
-- -----------------------------------------------------------------------------
CREATE TABLE cliente (
    nif NUMBER (9),
    nome VARCHAR (40),
    genero VARCHAR (10),
    nasceu_ano NUMBER (4) CONSTRAINT nn_cliente_nasceu_ano NOT NULL,
    registado_ano NUMBER (4) CONSTRAINT nn_cliente_registado_ano NOT NULL,
--
    CONSTRAINT pk_cliente
        PRIMARY KEY (nif),
--
    CONSTRAINT fk_cliente_nasceu_ano
        FOREIGN KEY (nasceu_ano)                         
        REFERENCES ano(ano), 
--
    CONSTRAINT fk_cliente_registado_ano
        FOREIGN KEY (registado_ano)                         
        REFERENCES ano(ano),    
--
    CONSTRAINT ck_cliente_nasceu_ano
        CHECK (nasceu_ano>=1970), 
-- 
    CONSTRAINT ck_cliente_registado_ano
        CHECK (registado_ano>=1970),
--
    CONSTRAINT ck_cliente_nif
        CHECK (nif>0),                                 --RIA 16
--
    CONSTRAINT ck_cliente_regis_nasc_ano
        CHECK ((registado_ano - nasceu_ano)>=18)      -- RIA 1    
);
-- ------------------------------------------------------------------------------
CREATE TABLE fornecedor (
    nipc NUMBER(9),
--
    CONSTRAINT pk_fornecedor
        PRIMARY KEY (nipc),
--
    CONSTRAINT fk_fornecedor_pessoa_coletiva
        FOREIGN KEY (nipc)                         
        REFERENCES pessoa_coletiva (nipc)                   
        ON DELETE CASCADE,
--
    CONSTRAINT ck_fornecedor_nipc
        CHECK (nipc>0)
);   
-- ------------------------------------------------------------------------------
CREATE TABLE fornece (
    fornecedor_nipc NUMBER(9), --RIA 21 e RIA 22
    loja_nipc NUMBER(9),
    ano NUMBER (4),
--
    CONSTRAINT pk_fornece
        PRIMARY KEY (fornecedor_nipc,loja_nipc,ano),
--
    CONSTRAINT fk_fornece_fornecedor
        FOREIGN KEY (fornecedor_nipc)                         
        REFERENCES fornecedor (nipc),
--
    CONSTRAINT fk_fornece_existe
        FOREIGN KEY (loja_nipc,ano)                         
        REFERENCES existe(loja_nipc,ano),
-- 
    CONSTRAINT ck_fornece_ano
        CHECK (ano>=1970),
--
    CONSTRAINT ck_fornece_loja_nipc
        CHECK (loja_nipc>0), 
--
    CONSTRAINT ck_fornece_fornecedor_nipc
        CHECK (fornecedor_nipc>0)          
);    
-- --------------------------------------------------------------------------------
CREATE TABLE oferece (
  unidade_por_semana INTEGER,
  dia_de_semana_do_fornecimento VARCHAR(40),
  preco NUMBER(10,2),
  ean13 NUMBER(13),
  fornecedor_nipc NUMBER(9),
  loja_nipc NUMBER(9), 
  ano NUMBER (4),
--
    CONSTRAINT pk_oferece
        PRIMARY KEY (ean13,loja_nipc,ano), 
--
    CONSTRAINT fk_oferece_fornece
        FOREIGN KEY (fornecedor_nipc,loja_nipc,ano)                         
        REFERENCES fornece (fornecedor_nipc,loja_nipc,ano),
--
    CONSTRAINT fk_oferece_produto
        FOREIGN KEY (ean13)                         
        REFERENCES produto (ean13),  
--                
	CONSTRAINT ck_oferece_preco
        	CHECK (preco>0), 	--RIA 14 
--
	CONSTRAINT ck_oferece_unidade_por_semana
        	CHECK (unidade_por_semana>0)                                                    
);
-- --------------------------------------------------------------------------------
CREATE TABLE fatura (
    numero_sequencial NUMBER(9),
    data      DATE,
    nif NUMBER (9) CONSTRAINT nn_fatura_nif NOT NULL, 
    loja_nipc NUMBER (9) CONSTRAINT nn_loja_nipc NOT NULL,
    ano NUMBER (4),
--
    CONSTRAINT pk_fatura
        PRIMARY KEY (numero_sequencial), 
--
    CONSTRAINT fk_fatura_cliente
        FOREIGN KEY (nif)                         
        REFERENCES cliente (nif) ON DELETE CASCADE,
--
    CONSTRAINT fk_fatura_existe                
        FOREIGN KEY (loja_nipc,ano)                         
        REFERENCES existe (loja_nipc,ano) ON DELETE CASCADE,
--
    CONSTRAINT ck_fatura_ano
        CHECK (ano>=1970),
--
    CONSTRAINT ck_fatura_nif
        CHECK (nif>0),
--
    CONSTRAINT ck_fatura_numero_sequencial
        CHECK (numero_sequencial>0)
);         
-- -------------------------------------------------------------------------------
ALTER SESSION SET NLS_DATE_FORMAT = 'DD.MM.YYYY';
-- --------------------------------------------------------------------------------
    INSERT INTO produto (ean13, nome, peso, largura, altura, profundidade, categoria)
        VALUES (1234567891234, 'alface', 1.23, 0.50, 0.20, 0.50, 'comida');
--
    INSERT INTO produto (ean13, nome, peso, largura, altura, profundidade, categoria)
        VALUES (1234567032145, 'meia', 0.10, 0.20, 0.30, 0.20, 'roupa');
--
    INSERT INTO pessoa_coletiva (nipc, telefone, nome)
        VALUES (123456789, 219863131, 'Supermercado');
--
    INSERT INTO pessoa_coletiva (nipc, telefone, nome)
        VALUES (213546859, 21454859, 'VegetaisEFrutas');
--
    INSERT INTO pessoa_coletiva (nipc, telefone, nome)
        VALUES (165789456, 21454859, 'Fedex');
--
    INSERT INTO pessoa_coletiva (nipc, telefone, nome)
        VALUES (984682945, 21454859, 'Anaxes');
--
    INSERT INTO loja (nipc)
        VALUES (123456789);
--
    INSERT INTO loja (nipc)
        VALUES (213546859);
--
    INSERT INTO ano (ano) 
	    VALUES (1980);
--
    INSERT INTO ano (ano) 
	    VALUES (2020);
--
    INSERT INTO existe (loja_nipc, ano)
        VALUES (123456789, 2020);
--
    INSERT INTO existe (loja_nipc, ano)
        VALUES (213546859, 1980);
--
    INSERT INTO existe (loja_nipc, ano)
        VALUES (123456789, 1980);
--
    INSERT INTO existe (loja_nipc, ano)
        VALUES (213546859, 2020);
--
    INSERT INTO cliente (nif, nome, genero, nasceu_ano, registado_ano)
        VALUES (836745987, 'Miguel', 'masculino', 1980, 2020);
--
    INSERT INTO cliente (nif, nome, genero, nasceu_ano, registado_ano)
        VALUES (123556732, 'Filipa', 'feminino', 1980, 2020);
--
    INSERT INTO fornecedor (nipc)
        VALUES (165789456);
--
    INSERT INTO fornecedor (nipc)
        VALUES (984682945);
--
    INSERT INTO fornece (fornecedor_nipc, loja_nipc, ano)
	    VALUES (165789456,123456789, 2020);
--
    INSERT INTO fornece (fornecedor_nipc, loja_nipc, ano)
	    VALUES (984682945,213546859, 1980);
--
    INSERT INTO oferece (unidade_por_semana, dia_de_semana_do_fornecimento, preco, ean13, fornecedor_nipc, loja_nipc, ano)
	    VALUES (1, 'segunda-feira', 20.00, 1234567891234,165789456,123456789, 2020);  
--
    INSERT INTO oferece (unidade_por_semana, dia_de_semana_do_fornecimento, preco, ean13, fornecedor_nipc, loja_nipc, ano)
	    VALUES(2, 'quarta-feira', 15.00,1234567032145,984682945,213546859, 1980);
--
    INSERT INTO fatura (numero_sequencial, data, loja_nipc, nif, ano)
        VALUES (32, '18.06.2020',123456789,836745987, 2020);
--
    INSERT INTO fatura (numero_sequencial, data, loja_nipc, nif, ano)
        VALUES (40, '23.12.2020',213546859,123556732, 2020);
--
COMMIT; 