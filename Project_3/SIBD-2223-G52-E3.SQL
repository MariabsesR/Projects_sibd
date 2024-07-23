
-- ----------------------------------------------------------------------------
-- Sistemas de Informação e Bases de Dados - António Ferreira, DI-FCUL.
-- Tabelas para a etapa 3 do projeto de SIBD de 2022/2023.

-- Sistemas de Informação e Bases de Dados - 2022/2023- Etapa 3- Grupo 52 
-- Maria Rocha, 58208, TP11
-- Sara Canhoto, 43177, TP16
-- André Santos, 57538, TP16
-- Martim Santos, 58244, TP16
-- ----------------------------------------------------------------------------


-- PERGUNTA 1 - NIF, nome, e idade das clientes femininas com apelido Dias, que compraram um ou mais
-- produtos de Beleza durante o ano de 2021. O EAN-13 e nome do(s) produto(s) também
-- devem ser mostrados, bem como o número e data da(s) respetiva(s) fatura(s) de compra. O
-- resultado deve vir ordenado de forma ascendente pela idade e nome das clientes, e de forma 
-- descendente pela data das faturas e nome dos produtos. Nota: a extração do ano a partir de uma data 
-- pode ser feita usando TO_CHAR(data, 'YYYY').---------------------------------------------------------------

SELECT C.nif , C.nome, TO_CHAR(SYSDATE, 'YYYY')  - C.nascimento AS idade, P.ean13, 
P.nome AS nome_produto, F.numero AS numero_fatura, F.data AS data_fatura
     FROM cliente C , fatura F ,linhafatura L, produto P
     WHERE (C.nome LIKE '%Dias') -- apelido Dias
     AND (P.categoria = 'Beleza') -- categoria do produto
     AND (C.genero = 'F') -- apenas clientes femininas
     AND (F.cliente = C.nif )
     AND (L.fatura = F.numero)
     AND (L.produto = P.ean13)
     AND (L.unidades >= 1) -- um ou mais produtos
     AND (TO_CHAR(F.data, 'YYYY') = '2021') -- apenas em 2021
     ORDER BY (TO_CHAR(SYSDATE, 'YYYY')  - C.nascimento) ASC, C.nome ASC, F.data DESC, P.nome DESC;  
-- ----------------------------------------------------------------------------
-- PERGUNTA 2 - NIF e nome dos clientes masculinos que nunca compraram produtos de Beleza (independentemente do ano), 
-- e que, considerando apenas 2021, ou não compraram Roupa nesse ano ou compraram Roupa em até duas ocasiões. 
-- Assuma que cada fatura com algum produto de Roupa representa uma ocasião de compra, não interessando se foi 
-- comprada pouca ou muita roupa. O resultado deve vir ordenado pelo nome dos clientes de forma ascendente e pelo NIF 
-- dos clientes de forma descendente. Nota: a extração do ano a partir de uma data pode ser feita usando TO_CHAR(data, 'YYYY').---------------------------------------------------------------


SELECT C.nome AS nome, C.nif AS nif
     FROM cliente C, fatura F ,linhafatura L, produto P
     WHERE (C.genero = 'M') -- clientes masculinos
     AND (C.nome NOT IN (SELECT C.nome
                              FROM cliente C, fatura F ,linhafatura L, produto P
                              WHERE (C.nif = F.cliente)
                              AND (L.fatura = F.numero)
                              AND (L.produto = P.ean13)
                              AND (P.categoria = 'Beleza') )) -- tabela com clientes que compraram beleza
     GROUP BY (C.nif, C.nome)
INTERSECT
SELECT  C.nome AS nome, C.nif AS nif
     FROM fatura F, linhafatura L, produto P, cliente C
     WHERE (C.genero = 'M')
     AND (C.nif NOT IN (SELECT F.cliente
                              FROM fatura F, linhafatura L, produto P, cliente C
                              WHERE (P.categoria = 'Roupa')
                              AND (L.fatura = F.numero)
                              AND (L.produto = P.ean13)
                              AND (F.cliente = C.nif)
                              AND (C.genero = 'M')
                              AND (TO_CHAR(F.data,'YYYY') = '2021')
                              HAVING (COUNT (F.cliente) > 2)
                              GROUP BY (F.cliente))) -- clientes masculinos que compraram Roupa mais do 
                                                     -- que em 2 ocasioes em 2021
     ORDER BY nome ASC, nif DESC;
-- ----------------------------------------------------------------------------
-- PERGUNTA 3 - Produtos de Comida com preço abaixo da média dos preços de todos os produtos (independentemente da categoria), 
-- e que tenham sido alguma vez comprados por todos os clientes do Porto na parte da manhã dos dias, isto é, entre as 8h e as 12h. 
-- O resultado deve vir ordenado pelo preço dos produtos de forma descendente e pelo EAN-13 dos produtos de forma ascendente. 
-- Nota: a extração da hora do dia a partir de uma data pode ser feita usando TO_CHAR(data, 'HH24').---------------------------------------------------------------------------


SELECT DISTINCT P.ean13, P.nome, P.preco
     FROM produto P, cliente C, fatura F, linhafatura L 
     WHERE (P.categoria = 'Comida') -- categoria do produto tem de ser comida
     AND (F.cliente = C.nif)
     AND (L.fatura = F.numero)
     AND (P.ean13 = L.produto)
     AND (C.localidade = 'Porto') -- apenas clientes do porto
     AND (TO_CHAR(F.data, 'HH24') BETWEEN 8 AND 12) -- apenas entre as 8:00 e 12:00
     AND (P.preco < (SELECT AVG (P.preco)
                         FROM produto P)); 
                         -- preco abaixo da media de todos os produtos

-- ----------------------------------------------------------------------------
-- PERGUNTA 4 - NIF e nome dos clientes que gastaram mais dinheiro em compras em cada ano, separadamente para clientes 
-- femininos e masculinos, devendo o género dos clientes e o total gasto em cada ano também aparecer no resultado. 
-- A ordenação do resultado deve ser pelo ano de forma descendente e pelo género dos clientes de forma ascendente. 
-- No caso de haver mais do que um(a) cliente com o mesmo máximo de dinheiro gasto num ano, devem ser mostrados todos esses clientes.--------------------------------------------------------------------------------------


SELECT DISTINCT C.nif AS nif,C.nome AS nome, custoTotal.total AS gasto_Total,  TO_CHAR(F.data, 'YYYY') AS ano, C.genero AS genero
     FROM produto P, cliente C, fatura F ,linhafatura L, (SELECT C.nome AS nome,  SUM  (p.PRECO * L.unidades) AS total
                                                            FROM produto P, cliente C, fatura F, linhafatura L
                                                            WHERE (P.ean13 = L.produto)
                                                            AND (F.cliente = C.nif)
                                                            AND (L.fatura = F.numero)
                                                            GROUP BY ( TO_CHAR(F.data, 'YYYY'), C.nome)) custoTotal, -- tabela geral dos custos dos clientes, por ano
                                                        -- -----------------------------------------------------------------------
                                                       (SELECT custoTotal2.ano , MAX(custoTotal2.preco_final) AS valores
                                                         FROM cliente C,
                                                         -- 
                                                            (SELECT   SUM  (p.PRECO * L.unidades) AS preco_final, TO_CHAR(F.data, 'YYYY') AS ano , C.nome AS nome
                                                                 FROM produto P, cliente C, fatura F, linhafatura L
                                                                 WHERE (P.ean13 = L.produto)
                                                                 AND (F.cliente = C.nif)
                                                                 AND (C.genero ='M')
                                                                 AND (L.fatura = F.numero)
                                                                 GROUP BY ( TO_CHAR(F.data, 'YYYY'), C.nome)) custoTotal2 --tabela geral so Masculino
                                                  --
                                                          WHERE C.nome = custoTotal2.nome
                                                          GROUP BY ( custoTotal2.ano)) custoMax -- MAX ano masculino
                                                   --  ----------------------------------------------------------------------------------       
     WHERE (C.nome = custoTotal.nome)
     AND (P.ean13 = L.produto)
     AND (F.cliente = C.nif)
     AND (L.fatura = F.numero)
     AND (custoTotal.total = custoMax.valores)
UNION -- uniao entre MAX ano masculino e MAX ano feminino
SELECT DISTINCT C.nif AS nif,C.nome AS nome, custoTotal.total AS gasto_Total,  TO_CHAR(F.data, 'YYYY') AS ano, C.genero AS genero
     FROM produto P, cliente C, fatura F ,linhafatura L, (SELECT C.nome AS nome,  SUM  (p.PRECO * L.unidades) AS total
                                                            FROM produto P, cliente C, fatura F, linhafatura L
                                                            WHERE (P.ean13 = L.produto)
                                                            AND (F.cliente = C.nif)
                                                            AND (L.fatura = F.numero)
                                                            GROUP BY ( TO_CHAR(F.data, 'YYYY'), C.nome)) custoTotal, -- tabela geral
                                                       -- -----------------------------------------------------------------------
                                                 (SELECT custoTotal2.ano , MAX(custoTotal2.preco_final) AS valores
                                                       FROM cliente C,
                                                  --
                                                       (SELECT   SUM  (p.PRECO * L.unidades) AS preco_final, TO_CHAR(F.data, 'YYYY') AS ano, C.nome AS nome
                                                            FROM produto P, cliente C, fatura F, linhafatura L
                                                            WHERE (P.ean13 = L.produto)
                                                            AND (F.cliente = C.nif)
                                                            AND (C.genero = 'F')
                                                            AND (L.fatura = F.numero)
                                                            GROUP BY ( TO_CHAR(F.data, 'YYYY'), C.nome)) custoTotal2 --tabela geral so Feminino
                                                  --
                                                       WHERE C.nome = custoTotal2.nome
                                                       GROUP BY (custoTotal2.ano)) custoMax -- MAX ano feminino
     WHERE (C.nome = custoTotal.nome)
     AND (P.ean13 = L.produto)
     AND (F.cliente = C.nif)
     AND (L.fatura = F.numero)
     AND (custoTotal.total = custoMax.valores)
     ORDER BY ano DESC, genero ASC;
-- --------------------------------------------------------------------------------------------------
COMMIT;
-- --------------------------------------------------------------------------------------------------



