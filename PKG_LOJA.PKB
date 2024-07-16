-- ----------------------------------------------------------------------------
-- Sistemas de Informação e Bases de Dados - António Ferreira, DI-FCUL.
-- Tabelas para a etapa 4 do projeto de SIBD de 2022/2023.


-- Sistemas de Informação e Bases de Dados - 2022/2023- Etapa 3- Grupo 52 
-- Maria Rocha, 58208, TP11
-- Sara Canhoto, 43177, TP16
-- André Santos, 57538, TP16
-- Martim Santos, 58244, TP16
-- ----------------------------------------------------------------------------

CREATE OR REPLACE PACKAGE BODY pkg_loja IS

-- --------------------------------------------------------------------------
-- Cria um novo registo de um cliente.
  PROCEDURE regista_cliente (
    nif_in        IN cliente.nif%TYPE,
    nome_in       IN cliente.nome%TYPE,
    genero_in     IN cliente.genero%TYPE,
    nascimento_in IN cliente.nascimento%TYPE,
    localidade_in IN cliente.localidade%TYPE)
  IS
  BEGIN
    INSERT INTO cliente (nif, nome, genero, nascimento, localidade)
         VALUES (nif_in, nome_in, genero_in, nascimento_in, localidade_in);
  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      RAISE_APPLICATION_ERROR(-20001, 'Já existe um cliente ' ||
                                      'com esse nif.');
    WHEN OTHERS THEN
      BEGIN
        IF (nif_in IS NULL OR nome_in IS NULL OR genero_in IS NULL OR nascimento_in 
        IS NULL OR localidade_in IS NULL) THEN
          RAISE_APPLICATION_ERROR(-20002, 'Nif, nome, genero, nascimento, localidade ' ||
                                          'de um cliente não podem ser valores vazios.');
        END IF;
        IF (nif_in < 100000000 OR nif_in > 999999999) THEN 
          RAISE_APPLICATION_ERROR(-20003, 'Nif do cliente tem de ser constituído por 9 dígitos.');
        END IF;
        IF (genero_in <> 'F' AND genero_in <> 'M') THEN 
          RAISE_APPLICATION_ERROR(-20004, 'Género do cliente deve ser F ou M.');
        END IF;
        IF (nascimento_in < 1900) THEN 
          RAISE_APPLICATION_ERROR(-20005, 'Ano de nascimento do cliente deve ser superior ou igual a 1900.');
        END IF;
        RAISE;
      END;
  END regista_cliente;

  -- Cria um novo registo de um produto.
  PROCEDURE regista_produto (
    ean13_in       IN produto.ean13%TYPE,
    nome_in        IN produto.nome%TYPE,
    categoria_in   IN produto.categoria%TYPE,
    preco_in       IN produto.preco%TYPE,
    stock_in       IN produto.stock%TYPE)
  IS
  BEGIN 
    INSERT INTO produto (ean13, nome, categoria, preco, stock)
         VALUES (ean13_in, nome_in, categoria_in, preco_in, stock_in);

  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      -- produto ganha o stock_in
      UPDATE produto
         SET stock = stock_in
       WHERE (ean13 = ean13_in);

    WHEN OTHERS THEN
      BEGIN
        IF (ean13_in IS NULL OR nome_in IS NULL OR categoria_in IS NULL OR preco_in 
        IS NULL OR stock_in IS NULL) THEN
          RAISE_APPLICATION_ERROR(-20007, 'Ean13, nome, categoria, preco, stock ' ||
                                          'de um cliente não podem ser valores vazios.');
        END IF;
        IF (ean13_in < 1000000000000 OR ean13_in > 9999999999999) THEN 
          RAISE_APPLICATION_ERROR(-20008, 'Ean13 do produto tem de ser constituído por 13 dígitos.');
        END IF;
        IF (categoria_in NOT IN ('Comida', 'Roupa', 'Beleza', 'Animais')) THEN 
          RAISE_APPLICATION_ERROR(-20009, 'Categoria de um produto tem de ser Comida, Roupa' ||
                                            'Beleza ou Animais.');
        END IF;
        IF (preco_in <= 0.0) THEN 
          RAISE_APPLICATION_ERROR(-20010, 'Preço de um produto tem de ser superior a 0€');
        END IF;
        IF (stock_in < 0) THEN 
          RAISE_APPLICATION_ERROR(-20011, 'Stock de um produto tem de ser maior ou igual a 0.');
        END IF;
        RAISE;
      END;
  END regista_produto;
  
  -- --------------------------------------------------------------------------


  -- Cria um novo registo de uma compra.
  FUNCTION regista_compra (
    cliente_in      IN fatura.cliente%TYPE,
    produto_in      IN linhafatura.produto%TYPE,
    unidades_in     IN linhafatura.unidades%TYPE,
    fatura_in       IN linhafatura.fatura%TYPE)
    RETURN NUMBER

  IS
  compra NUMBER := NULL;
  numero_fatura NUMBER := NULL;
  stock_produto NUMBER := NULL;
  data_fatura DATE := NULL;

  BEGIN
    SELECT (COUNT(numero)+1) INTO numero_fatura FROM fatura; 
    SELECT stock INTO stock_produto FROM produto WHERE produto.ean13 = produto_in; 
    IF (fatura_in IS NULL) THEN
      INSERT INTO fatura (numero, data, cliente) 
        VALUES (numero_fatura,TO_CHAR(SYSDATE, 'DD-MM-YYYY HH24:MI') , cliente_in);
      INSERT INTO linhafatura (fatura, produto, unidades)
        VALUES (numero_fatura, produto_in, unidades_in);
        compra :=  numero_fatura; 
    ELSE 
      INSERT INTO linhafatura (fatura, produto, unidades)
         VALUES (fatura_in, produto_in, unidades_in); 
          compra :=  fatura_in;
    END IF;
      UPDATE produto
         SET produto.stock = produto.stock - unidades_in
       WHERE (produto.ean13 = produto_in);
     
    RETURN compra;

  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      RAISE_APPLICATION_ERROR(-20012, 'Já existe uma fatura com esse número');

    WHEN OTHERS THEN
      BEGIN
        IF (cliente_in IS NULL OR produto_in IS NULL OR unidades_in IS NULL) THEN
          RAISE_APPLICATION_ERROR(-20013, 'Cliente, produto e unidades não podem ter valores vazios.');
        END IF;
        IF (fatura_in IS NOT NULL AND fatura_in < 1)  THEN 
            RAISE_APPLICATION_ERROR(-20020, 'Numero de fatura tem de ser > 1.');
        END IF;
        IF (unidades_in <= 0) THEN
          RAISE_APPLICATION_ERROR(-20021, 'Unidades de produto na linha de fatura tem de ser > 0.');
        END IF;
        IF (stock_produto - unidades_in < 0) THEN
          RAISE_APPLICATION_ERROR(-20014, 'Não existem unidades suficientes do produto');
        END IF;
        RAISE;
      END;
  END regista_compra;
 -- --------------------------------------------------------------------------
  -- Remove um registo de uma compra.
  FUNCTION remove_compra (
    fatura_in   IN linhafatura.fatura%TYPE,
    produto_in  IN linhafatura.produto%TYPE)
    RETURN NUMBER

  IS 
  quantidade_compra NUMBER := NULL;
  quantidade_produtos NUMBER := NULL;
  quantidade_produtos_null NUMBER := NULL;
  CURSOR cursor_ean13produtos IS SELECT L.produto FROM linhafatura L WHERE fatura_in = L.fatura;
  tipo_produto linhafatura.produto%TYPE;
  teste NUMBER := NULL;
  numero_stock NUMBER := NULL;

  BEGIN  
  OPEN cursor_ean13produtos;
  
  IF(produto_in IS NOT NULL)THEN 
    SELECT L.unidades INTO numero_stock FROM linhafatura L WHERE fatura_in = L.fatura AND L.produto = produto_in;  
    UPDATE produto
    SET stock = produto.stock + numero_stock
    WHERE produto_in = produto.ean13;
    DELETE FROM linhafatura WHERE (linhafatura.produto = produto_in) AND (fatura_in=linhafatura.fatura);
  ELSE
    SELECT COUNT(produto) INTO quantidade_produtos_null FROM linhafatura WHERE fatura_in = linhafatura.fatura; 
      IF (quantidade_produtos_null > 0) THEN
        FOR contador IN 1 .. quantidade_produtos_null LOOP
        FETCH cursor_ean13produtos INTO tipo_produto;
        IF (cursor_ean13produtos%FOUND) THEN quantidade_produtos := PKG_LOJA.remove_compra(fatura_in, tipo_produto);
        ELSE 
          EXIT;
        END IF;
       END LOOP;

      END IF;
  -- caso nao seja dado produto apaga-se todas
  END IF;
  -- conta quantidade de linhas de fatura ainda  associado  fatura
  SELECT COUNT(fatura) INTO quantidade_produtos FROM linhafatura WHERE fatura_in = linhafatura.fatura; 
  -- Se a fatura ficar sem produtos, também é removida
  IF (quantidade_produtos = 0) THEN
    DELETE FROM fatura WHERE (fatura.numero = fatura_in);
  END IF;

   -- conta quantidade de linhas de fatura ainda na tabela linha de fatura 
   SELECT COUNT(fatura) INTO quantidade_compra FROM linhafatura WHERE fatura_in = linhafatura.fatura; 
   RETURN quantidade_compra;

  EXCEPTION
    WHEN OTHERS THEN 
      BEGIN
        IF (fatura_in IS NULL) THEN
          RAISE_APPLICATION_ERROR(-20022, 'Fatura não pode ter valor vazio.');
        END IF;
        IF (fatura_in < 1) THEN
          RAISE_APPLICATION_ERROR(-20020, 'Numero de fatura tem de ser > 1.');
        END IF;
        IF ((produto_in < 1000000000000)) THEN 
          RAISE_APPLICATION_ERROR(-20008, 'Ean13 do produto tem de ser constituído por 13 dígitos.');
        END IF;
        IF((produto_in > 9999999999999)) THEN
        RAISE_APPLICATION_ERROR(-20008, 'Ean13 do produto tem de ser constituído por 13 dígitos.');
        END IF;
      END
    RAISE;

  END remove_compra;

-- --------------------------------------------------------------------------
  -- Remove um produto.
  PROCEDURE remove_produto (
    ean13_in   IN produto.ean13%TYPE)
    
  IS 

  CURSOR cursor_fatura IS SELECT numero FROM fatura, linhafatura WHERE fatura.numero = linhafatura.fatura AND ean13_in = linhafatura.produto;
  numero_fatura fatura.numero%TYPE;
  teste NUMBER := NULL;
  quantidade_produtos NUMBER := 0;
  quantidade_cursor NUMBER := NULL;
  
  BEGIN 

  SELECT COUNT(L.produto) INTO quantidade_produtos FROM linhafatura L WHERE ean13_in = L.produto; 
  SELECT COUNT(ean13) INTO teste FROM produto WHERE ean13_in = produto.ean13;
  OPEN cursor_fatura;  
    IF (quantidade_produtos > 0) THEN
        FOR contador IN 1 .. quantidade_produtos LOOP
        FETCH cursor_fatura INTO numero_fatura;
        IF (cursor_fatura%FOUND) THEN quantidade_cursor := PKG_LOJA.remove_compra(numero_fatura, ean13_in);
        ELSE 
          EXIT;
        END IF;
        END LOOP;
    END IF;

    DELETE FROM produto WHERE (ean13 = ean13_in);

    IF (teste = 0) THEN
      -- Nenhuma linha foi afetada pelo comando DELETE.
      RAISE_APPLICATION_ERROR(-20015, 'Produto a remover não existe.');
    END IF;

    IF (ean13_in IS NULL) THEN
      RAISE_APPLICATION_ERROR(-20017, 'Produto não pode ter valor vazio.');
    END IF;
    IF ((ean13_in < 1000000000000)) THEN 
      RAISE_APPLICATION_ERROR(-20008, 'Ean13 do produto tem de ser constituído por 13 dígitos.');
    END IF;
    IF((ean13_in > 9999999999999)) THEN
      RAISE_APPLICATION_ERROR(-20008, 'Ean13 do produto tem de ser constituído por 13 dígitos.');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN 
      
    RAISE;

  END remove_produto;

-- --------------------------------------------------------------------------
-- Remove um cliente.
  PROCEDURE remove_cliente (
    nif_in   IN cliente.nif%TYPE)
    
  IS 
  CURSOR cursor_fatura IS SELECT F.numero FROM fatura F WHERE nif_in = F.cliente;
  numero_fatura fatura.numero%TYPE;
  teste NUMBER := NULL;
  quantidade_fatura NUMBER := NULL;
  quantidade_cursor NUMBER := NULL;
  

  BEGIN 
  SELECT COUNT(numero) INTO quantidade_fatura FROM fatura WHERE nif_in = fatura.cliente; 
 
  OPEN cursor_fatura;  
    IF (quantidade_fatura > 0) THEN
        FOR contador IN 1 .. quantidade_fatura LOOP
        FETCH cursor_fatura INTO numero_fatura;
        IF (cursor_fatura%FOUND) THEN quantidade_cursor := PKG_LOJA.remove_compra(numero_fatura, NULL);
        ELSE 
          EXIT;
        END IF;
        END LOOP;

    END IF;
    DELETE FROM cliente WHERE (nif = nif_in);

  EXCEPTION
    WHEN OTHERS THEN 
    IF (nif_in IS NULL) THEN
          RAISE_APPLICATION_ERROR(-20018, 'Cliente não pode ter valor vazio.');
    END IF;
    IF (nif_in < 100000000 OR nif_in > 999999999) THEN 
          RAISE_APPLICATION_ERROR(-20003, 'Nif do cliente tem de ser constituído por 9 dígitos.');
    END IF;
    RAISE;
  END remove_cliente;
  -- --------------------------------------------------------------------------

  -- Devolve um cursor com os produtos da categoria indicada mais comprados pelos clientes, 
  -- por ordem descendente do número de unidades
  FUNCTION lista_produtos (
    categoria_in   IN produto.categoria%TYPE)
    RETURN SYS_REFCURSOR

  IS 
    cursor_categoria SYS_REFCURSOR;

  BEGIN
  IF (categoria_in IS NULL) THEN
          RAISE_APPLICATION_ERROR(-20019, 'Categoria nao pode ter um valor nulo.');
  END IF;
  IF (categoria_in NOT IN ('Comida', 'Roupa', 'Beleza', 'Animais')) THEN 
          RAISE_APPLICATION_ERROR(-20009, 'Categoria de um produto tem de ser Comida, Roupa' ||
                                            'Beleza ou Animais.');
  END IF;
  OPEN cursor_categoria FOR SELECT DISTINCT P.ean13, P.nome, P.preco, 0 AS unidades
                                      FROM linhafatura L, fatura F, produto P
                                      WHERE P.ean13 NOT IN (SELECT L.produto
                                                                FROM linhafatura L)
                                      AND P.categoria = categoria_in
                                                                --nao comprados 
                                    UNION
                                    SELECT L.produto, P.nome, P.preco, uni.total AS unidades
                                      FROM linhafatura L, fatura F, produto P, (SELECT L.produto AS tipo_produto, SUM(L.unidades) AS total
                                                                                  FROM linhafatura L, fatura F, produto P
                                                                                  WHERE L.fatura = F.numero
                                                                                  AND L.produto = P.ean13
                                                                                  AND P.categoria = categoria_in
                                                                                  GROUP BY (L.produto)
                                                                                  ORDER BY SUM(L.unidades) DESC) uni
                                      WHERE L.fatura = F.numero
                                      AND L.produto = P.ean13          
                                      AND uni.tipo_produto = P.ean13 
                                      ORDER BY unidades DESC;
  RETURN cursor_categoria;
  EXCEPTION
    WHEN OTHERS THEN 
    IF (categoria_in IS NULL) THEN
          RAISE_APPLICATION_ERROR(-20019, 'Categoria nao pode ter um valor nulo.');
    END IF;
    IF (categoria_in NOT IN ('Comida', 'Roupa', 'Beleza', 'Animais')) THEN 
          RAISE_APPLICATION_ERROR(-20009, 'Categoria de um produto tem de ser Comida, Roupa' ||
                                            'Beleza ou Animais.');
    END IF;
    RAISE;
  END lista_produtos;
  
END pkg_loja;
/




 


