-- ----------------------------------------------------------------------------
-- Sistemas de Informação e Bases de Dados - António Ferreira, DI-FCUL.
-- Tabelas para a etapa 4 do projeto de SIBD de 2022/2023.


-- Sistemas de Informação e Bases de Dados - 2022/2023- Etapa 3- Grupo 52 
-- Maria Rocha, 58208, TP11
-- Sara Canhoto, 43177, TP16
-- André Santos, 57538, TP16
-- Martim Santos, 58244, TP16
-- ----------------------------------------------------------------------------
@tabelas.SQL
@pkg_loja.PKS
@pkg_loja.PKB 

BEGIN 
pkg_loja.regista_cliente(111111111, 'Tiago', 'M', '2000', 'Lisboa');
pkg_loja.regista_cliente(222222222, 'Laura', 'F', '2001', 'Lisboa');
pkg_loja.regista_cliente(333333333, 'Rui', 'M', '2000', 'Lisboa');
pkg_loja.regista_cliente(444444444, 'Adolf', 'M', '1900', 'Stuttgart');
pkg_loja.regista_produto(1111111111111, 'banana', 'Comida', 0.7, 20);
pkg_loja.regista_produto(4444444444444, 'coco', 'Comida', 0.5, 20);
pkg_loja.regista_produto(2222222222222, 'calcas', 'Roupa', 20.5, 20);
pkg_loja.regista_produto(5555555555555, 'meias', 'Roupa', 5.4, 20);
pkg_loja.regista_produto(3333333333333, 'osso', 'Animais', 3.6, 20);
pkg_loja.regista_produto(6666666666666, 'trela', 'Animais', 12.3, 20);
END;
/
-- ----------------------------------------------------------------------------
SELECT * FROM produto;
SELECT * FROM cliente;
-- ----------------------------------------------------------------------------
INSERT INTO fatura (numero, data, cliente) VALUES (1, '20-12-2020', 111111111);
VARIABLE compra1 NUMBER;
BEGIN :compra1 := pkg_loja.regista_compra(111111111, 2222222222222, 1, 1); END;
/
VARIABLE compra11 NUMBER;
BEGIN :compra11 := pkg_loja.regista_compra(111111111, 3333333333333, 1, 1); END;
/
VARIABLE compra12 NUMBER;
BEGIN :compra12 := pkg_loja.regista_compra(111111111, 4444444444444, 1, 1); END;
/

VARIABLE compra2 NUMBER;
BEGIN :compra2 := pkg_loja.regista_compra(111111111, 2222222222222, 1, NULL); END; 
-- deve ser a fatura 2
/ 
VARIABLE compra21 NUMBER;
BEGIN :compra2 := pkg_loja.regista_compra(111111111, 2222222222222, 1, NULL); END;
/ 
-- deve ser a fatura 3
-- ----------------------------------------------------------------------------

INSERT INTO fatura (numero, data, cliente) VALUES (4, '25-12-2020', 222222222);
VARIABLE compra3 NUMBER;
BEGIN :compra3 := pkg_loja.regista_compra(222222222, 3333333333333, 3, 4); END; 
/
VARIABLE compra31 NUMBER;
BEGIN :compra31 := pkg_loja.regista_compra(222222222, 4444444444444, 1, NULL); END;
/ 
-- deve ser a fatura 5
-- ----------------------------------------------------------------------------
VARIABLE compra41 NUMBER;
BEGIN :compra41 := pkg_loja.regista_compra(333333333, 4444444444444, 1, NULL); END;
/
-- deve ser a fatura 6
VARIABLE compra4 NUMBER;
BEGIN :compra4 := pkg_loja.regista_compra(333333333, 2222222222222, 2, NULL); END;
/
 -- deve ser a fatura 7
-- ----------------------------------------------------------------------------
INSERT INTO fatura (numero, data, cliente) VALUES (8, '30-12-2020', 444444444);
VARIABLE compra5 NUMBER;
BEGIN :compra5 := pkg_loja.regista_compra(444444444, 1111111111111, 2, 8); END;
/
VARIABLE compra51 NUMBER;
BEGIN :compra51 := pkg_loja.regista_compra(444444444, 4444444444444, 1, NULL); END;
/
-- deve ser a fatura 9
VARIABLE compra52 NUMBER;
BEGIN :compra52 := pkg_loja.regista_compra(111111111, 6666666666666, 1, NULL); END;
/
-- deve ser a fatura 10
-- ----------------------------------------------------------------------------
SELECT * FROM linhafatura;
SELECT * FROM fatura;
SELECT * FROM produto; 
-- verificar que stock desceu
-- ----------------------------------------------------------------------------
VARIABLE devolucao1 NUMBER;
BEGIN :devolucao1 := pkg_loja.remove_compra(3, 2222222222222); END;
/

VARIABLE devolucao2 NUMBER;
BEGIN :devolucao2 := pkg_loja.remove_compra(1, NULL); END;
/
-- ----------------------------------------------------------------------------
SELECT * FROM linhafatura;
SELECT * FROM fatura;
SELECT * FROM produto; 

-- verificar que stock desceu
-- ----------------------------------------------------------------------------
BEGIN 
pkg_loja.remove_produto(2222222222222);
END;
/
-- ----------------------------------------------------------------------------
SELECT * FROM linhafatura;
SELECT * FROM fatura;
SELECT * FROM produto; 

-- verificar que produto desaparece dos produtos e das faturas
-- ----------------------------------------------------------------------------
BEGIN 
pkg_loja.remove_cliente(444444444);
END;
/
-- ----------------------------------------------------------------------------
SELECT * FROM linhafatura;
SELECT * FROM fatura;
SELECT * FROM cliente; 

-- verificar que cliente 444444444 e suas faturas desaparecem
-- ----------------------------------------------------------------------------
VARIABLE lista REFCURSOR;
BEGIN :lista := pkg_loja.lista_produtos('Comida'); END;
/
PRINT lista;









