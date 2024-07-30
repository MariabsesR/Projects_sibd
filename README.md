Stage 1 - 2022/2023

Universe: PreçoFixo Chain of Stores

This project involves designing a minimalistic conceptual database diagram for PreçoFixo, a chain of stores, using the entity-relationship model. The diagram captures the following:

Stores and Suppliers: Each store has a unique set of suppliers, updated annually. Both stores and suppliers have unique identifiers and addresses.
Products and Supplies: Fixed product prices and weekly supply schedules are determined at the start of each year. Products have detailed attributes, including barcode, name, and category.
Customers, Purchases, and Returns: Customers have unique identifiers and must be over 18. Purchases generate invoices, and products can be returned within 30 days.

Conceptual database diagram with minimal entities, associations, and integrity constraints, including justifications for any additional constraints.

Stage 2 - 2022/2023

Continuing from Stage 1, we have a conceptual database diagram for managing a chain of stores (PreçoFixo). In this stage, translated this diagram into a relational schema and implemented it using SQL. Objectives

Logical Database Design: Translate the conceptual diagram into a relational schema using SQL-DDL commands, covering as many integrity constraints as possible.
Data Insertion: Use SQL-DML commands to insert sample data into all tables, with at least two rows per table.

Integrity Constraints

Customers must be at least 18 years old at the time of registration.
Invoice dates must be on or after the customer's registration year.
Products on an invoice must be offered by a supplier of the store in the same year.
Additional constraints regarding dates, unique identifiers, and valid attribute values (e.g., NIPC, EAN-13, NIF).

Report Structure

File: SIBD-2223-GXX-E2.SQL
Sections:
    DROP TABLE commands.
    CREATE TABLE commands with named integrity constraints.
    INSERT INTO commands with sample data.

Stage 3 - 2022/2023

In this stage, we are provided with a relational schema for managing a store, inspired by the concepts from stages 1 and 2. The objective is to translate this schema into SQL queries to retrieve specific data. Objectives

Translate the relational schema into SQL queries to answer the following data requests:

Customers named Dias who bought Beauty products in 2021:
    Fields: NIF, name, age, EAN-13, product name, invoice number, invoice date
    Order: Ascending by age and name, descending by invoice date and product name
Male customers who never bought Beauty products and their clothing purchase behavior in 2021:
    Fields: NIF, name
    Order: Ascending by name, descending by NIF
Food products cheaper than the average price and bought by all Porto customers in the morning:
    Fields: Product details
    Order: Descending by price, ascending by EAN-13
Customers who spent the most money each year, separated by gender:
    Fields: NIF, name, gender, total spent, year
    Order: Descending by year, ascending by gender

Key Points

Ensure the SQL queries execute without errors.
Use suggested table initials for clarity (e.g., cliente C, produto P, fatura F, linhafatura L).
Avoid unnecessary tables in FROM clause or excessive subqueries.
Remove duplicate rows only if necessary.
Write intelligible, well-aligned SQL queries.

Content: Annotated SQL queries for each data request Comments on any adopted variants with lower grading

Stage 4 - 2022/2023

In this final stage, we will extend the relational schema for store management (from stage 3) by implementing a PL/SQL package for data management and demonstrating its functionalities through a script. Objectives

Implement a PL/SQL Package (pkg_loja) for Data Management:
    Register a Customer: regista_cliente(nif_in, nome_in, genero_in, nascimento_in, localidade_in)
        Registers a customer with the provided NIF, name, gender, birth year, and locality.
    Register a Product: regista_produto(ean13_in, nome_in, categoria_in, preco_in, stock_in)
        Registers a product with the provided EAN-13, name, category, price, and stock units. Updates stock if the product already exists.
    Register a Purchase: regista_compra(cliente_in, produto_in, unidades_in, fatura_in := NULL) -> NUMBER
        Registers a purchase of one or more units of a product by a customer, adding it to an invoice. Generates a new invoice if not provided. Updates product stock.
    Remove a Purchase: remove_compra(fatura_in, produto_in := NULL) -> NUMBER
        Removes a product purchase from an invoice. Deletes the invoice if it becomes empty. Restocks the product units. Removes all purchases if no product is specified.
    Remove a Product: remove_produto(ean13_in)
        Removes a product and all its purchases by customers. Invokes remove_compra.

Write a Script to Demonstrate PL/SQL Package Functionalities:
    Create a script with invocations of the package procedures and functions to demonstrate a data management scenario.

PL/SQL package pkg_loja with the specified procedures and functions. A script demonstrating the usage of the package.
