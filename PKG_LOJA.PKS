-- ----------------------------------------------------------------------------
-- Sistemas de Informação e Bases de Dados - António Ferreira, DI-FCUL.
-- Especificação da interface aplicacional enriquecida para a aula de PL/SQL.

-- Sistemas de Informação e Bases de Dados - 2022/2023- Etapa 3- Grupo 52 
-- Maria Rocha, 58208, TP11
-- Sara Canhoto, 43177, TP16
-- André Santos, 57538, TP16
-- Martim Santos, 58244, TP16
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------

CREATE OR REPLACE PACKAGE pkg_loja IS

  -- Todas as operações lançam exceções para sinalizar casos de erro.
  --
  -- Exceção Mensagem
  --  -20001 Já existe um cliente com esse nif.
  --  -20002 Nif, nome, genero, nascimento, localidade de um cliente não podem ser valores vazios.
  --  -20003 Nif do cliente tem de ser constituído por 9 dígitos.
  --  -20004 Género do cliente deve ser F ou M.
  --  -20005 Ano de nascimento do cliente deve ser superior ou igual a 1900.
  --  -20006 Já existe um produto com esse ean13.
  --  -20007 Ean13, nome, categoria, preco, stock de um cliente não podem ser valores vazios.
  --  -20008 Ean13 do produto tem de ser constituído por 13 dígitos.
  --  -20009 Categoria de um produto tem de ser Comida, Roupa, Beleza ou Animais.
  --  -20010 Preço de um produto tem de ser superior a 0€.
  --  -20011 Stock de um produto tem de ser maior ou igual a 0.
  --  -20012 Já existe uma fatura com esse número.
  --  -20013 Cliente, produto e unidades não podem ter valores vazios.
  --  -20014 Não existem unidades suficientes do produto.
  --  -20015 Produto a remover não existe.
  --  -20016 Fatura e produto não podem ter valores vazios.
  --  -20017 Produto não pode ter valor vazio.
  --  -20018 Cliente não pode ter valor vazio.
  --  -20019 Categoria nao pode ter um valor nulo.
  --  -20020 Numero de fatura tem de ser > 1.
  --  -20021 Unidades de produto na linha de fatura tem de ser > 0.
  --  -20022 Fatura não pode ter valor vazio.
 
  -- Cria um novo registo de um cliente.
  PROCEDURE regista_cliente (
    nif_in        IN cliente.nif%TYPE,
    nome_in       IN cliente.nome%TYPE,
    genero_in     IN cliente.genero%TYPE,
    nascimento_in IN cliente.nascimento%TYPE,
    localidade_in IN cliente.localidade%TYPE);

  -- Cria um novo registo de um produto.
  PROCEDURE regista_produto (
    ean13_in       IN produto.ean13%TYPE,
    nome_in        IN produto.nome%TYPE,
    categoria_in   IN produto.categoria%TYPE,
    preco_in       IN produto.preco%TYPE,
    stock_in       IN produto.stock%TYPE);

  -- Devolve o número da fatura onde foi registada a compra.
  FUNCTION regista_compra (
    cliente_in      IN fatura.cliente%TYPE,
    produto_in      IN linhafatura.produto%TYPE,
    unidades_in     IN linhafatura.unidades%TYPE,
    fatura_in       IN linhafatura.fatura%TYPE)
    RETURN NUMBER;
  
  -- o devolve o número de linhas que ainda constam no talão
  -- da fatura, ou zero se a fatura tiver sido removida.
  FUNCTION remove_compra (
    fatura_in   IN linhafatura.fatura%TYPE,
    produto_in  IN linhafatura.produto%TYPE)
    RETURN NUMBER;

  -- Remove um produto.
  PROCEDURE remove_produto (
    ean13_in   IN produto.ean13%TYPE);

   -- Remove um cliente.
  PROCEDURE remove_cliente (
    nif_in   IN cliente.nif%TYPE);
  
  -- Devolve um cursor com os produtos da categoria indicada mais comprados pelos clientes, 
  -- por ordem descendente do número de unidades
  FUNCTION lista_produtos (
    categoria_in   IN produto.categoria%TYPE)
    RETURN SYS_REFCURSOR;

END pkg_loja;
/

-- ----------------------------------------------------------------------------