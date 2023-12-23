--Script de Criação
Drop table Item_do_Pedido cascade constraint;
Drop table Produto cascade constraint;
Drop table Pedido cascade constraint;
Drop table Vendedor cascade constraint;
Drop table Cliente cascade constraint;
Create table Cliente(
Cod_Cli integer,
Nome_Cli varchar(30),
Cidade varchar(30),
UF char(2),
Primary key(Cod_cli));
Create table Vendedor (
Cod_Vend integer,
Nome_Vend varchar(30),
Salario integer,
Faixa_comissao char(1),
Primary key (Cod_Vend));
Create table Pedido (
Cod_Ped integer,
Cod_Cli integer,
Cod_Vend integer,
Primary key(Cod_Ped),
Foreign key (Cod_Cli) References Cliente (Cod_Cli),
Foreign key (Cod_Vend) References Vendedor (Cod_Vend));
Create table Produto(
Cod_Prod integer,
Unidade varchar(10),
Descricao varchar(30),
Valor_Unit integer,
Primary key(Cod_Prod));
Create table Item_do_Pedido (
Cod_Ped integer,
Cod_Prod integer,
Quantidade integer,
Primary key(Cod_Ped, Cod_Prod),
Foreign key (Cod_Ped) References Pedido (Cod_Ped),
Foreign key (Cod_Prod) References Produto (Cod_Prod));
Insert into Cliente values (1, 'Ana', 'Niteroi', 'RJ');
Insert into Cliente values (2, 'Flavio', 'Sao Paulo', 'SP');
Insert into Cliente values (3, 'Jorge', 'Belo Horizonte', 'MG');
Insert into Cliente values (4, 'Lucia', 'Sorocaba', 'SP');
Insert into Cliente values (5, 'Mauro', 'Contagem', 'MG');
Insert into Vendedor values (1000, 'Jose', 1800, 'C');
Insert into Vendedor values (1001, 'Carlos', 2500, 'A');
Insert into Vendedor values (1002, 'Joao', 2700, 'C');
Insert into Vendedor values (1003, 'Antonio', 4600, 'C');
Insert into Vendedor values (1004, 'Jonas', 9500, 'A');
Insert into Vendedor values (1005, 'Mateus', 3000, 'C');
Insert into Pedido values (100, 5, 1001);
Insert into Pedido values (101, 1, 1002);
Insert into Pedido values (102, 3, 1004);
Insert into Pedido values (103, 2, 1002);
Insert into Pedido values (104, 1, 1005);
Insert into Pedido values (105, 5, 1002);
Insert into Produto values (200, 'kg','queijo', 10);
Insert into Produto values (201, 'kg','chocolate', 20);
Insert into Produto values (202, 'l','vinho', 30);
Insert into Produto values (203, 'kg','acucar', 2);
Insert into Produto values (204, 'm','papel', 2);
Insert into Item_do_Pedido values (100, 201,3);
Insert into Item_do_Pedido values (100, 202,5);
Insert into Item_do_Pedido values (101, 204,15);
Insert into Item_do_Pedido values (102, 203,5);
Insert into Item_do_Pedido values (103, 200,12);
Insert into Item_do_Pedido values (104, 201,1);
Insert into Item_do_Pedido values (104, 203,4);
Insert into Item_do_Pedido values (104, 204,6);
Insert into Item_do_Pedido values (105, 202,10);
COMMIT;


-- 1) Crie uma função que retorne o total de pedidos (número de pedidos) que um determinado cliente fez,
--de acordo com um nome de cliente especificado como argumento desta função.
-- Utilize a função criada para selecionar o nome de todos os clientes
--(mesmo aqueles que não fizeram nenhum pedido ainda) e o total de pedidos feitos por cada um dos clientes,
--mas somente para aqueles clientes que fizeram menos pedidos que o cliente 'Mauro' (utilize a função nesta consulta).


CREATE OR REPLACE FUNCTION TotalPedidosPorCliente(
    nome_cliente IN varchar)
RETURN number IS
    total_pedidos number;
BEGIN
    SELECT COUNT(*) INTO total_pedidos
    FROM Pedido P
    JOIN Cliente C ON P.Cod_Cli = C.Cod_Cli
    WHERE C.Nome_Cli = nome_cliente;
    
    RETURN total_pedidos;
END TotalPedidosPorCliente;
/

SELECT
    C.Nome_Cli,
    TotalPedidosPorCliente(C.Nome_Cli) AS total_pedidos
FROM Cliente C
WHERE TotalPedidosPorCliente(C.Nome_Cli) < TotalPedidosPorCliente('Mauro');


-- 2) Crie uma função que retorne o valor total que um cliente vai pagar
-- pelos produtos comprados em um determinado pedido,
-- considerando que será passado, como argumento desta função,
-- somente o código do pedido.


CREATE OR REPLACE FUNCTION ValorTotalPedido(
    codigo_pedido IN integer)
RETURN integer IS
    valor_total integer;
BEGIN
    SELECT SUM(P.Valor_Unit * I.Quantidade) INTO valor_total
    FROM Item_do_Pedido I
    JOIN Produto P ON I.Cod_Prod = P.Cod_Prod
    WHERE I.Cod_Ped = codigo_pedido;

    RETURN valor_total;
END ValorTotalPedido;
/

DECLARE
    valor_pedido integer;
BEGIN
    valor_pedido := ValorTotalPedido(100);
    DBMS_OUTPUT.PUT_LINE('O valor total do pedido é: ' || valor_pedido);
END;
/

-- 3) Crie uma função que retorne o nome do cliente que fez um determinado pedido,
--considerando que será passado, como argumento desta função,
--somente o código do pedido.

CREATE OR REPLACE FUNCTION NomeClientePorPedido(
    codigo_pedido IN integer)
RETURN varchar AS
    nome_cliente varchar(30);
BEGIN
    SELECT C.Nome_Cli INTO nome_cliente
    FROM Pedido P
    JOIN Cliente C ON P.Cod_Cli = C.Cod_Cli
    WHERE P.Cod_Ped = codigo_pedido;

    RETURN nome_cliente;
END NomeClientePorPedido;
/


DECLARE
    nome_cliente_pedido varchar(30);
BEGIN
    nome_cliente_pedido := NomeClientePorPedido(100);
    DBMS_OUTPUT.PUT_LINE('O nome do cliente que fez o pedido é: ' || nome_cliente_pedido);
END;
/

