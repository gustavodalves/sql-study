-- DROP TABLES
DROP TABLE IF EXISTS Order_Item CASCADE CONSTRAINT;
DROP TABLE IF EXISTS Product CASCADE CONSTRAINT;
DROP TABLE IF EXISTS "Order" CASCADE CONSTRAINT;
DROP TABLE IF EXISTS Seller CASCADE CONSTRAINT;
DROP TABLE IF EXISTS Customer CASCADE CONSTRAINT;

-- CREATE TABLES
CREATE TABLE Customer (
    Cust_Code INTEGER,
    Cust_Name VARCHAR(30),
    City VARCHAR(30),
    State CHAR(2),
    PRIMARY KEY (Cust_Code)
);

CREATE TABLE Seller (
    Seller_Code INTEGER,
    Seller_Name VARCHAR(30),
    Salary INTEGER,
    Commission_Range CHAR(1),
    PRIMARY KEY (Seller_Code)
);

CREATE TABLE "Order" (
    Order_Code INTEGER,
    Cust_Code INTEGER,
    Seller_Code INTEGER,
    PRIMARY KEY (Order_Code),
    FOREIGN KEY (Cust_Code) REFERENCES Customer (Cust_Code),
    FOREIGN KEY (Seller_Code) REFERENCES Seller (Seller_Code)
);

CREATE TABLE Product (
    Prod_Code INTEGER,
    Unit VARCHAR(10),
    Description VARCHAR(30),
    Unit_Price INTEGER,
    PRIMARY KEY (Prod_Code)
);

CREATE TABLE Order_Item (
    Order_Code INTEGER,
    Prod_Code INTEGER,
    Quantity INTEGER,
    PRIMARY KEY (Order_Code, Prod_Code),
    FOREIGN KEY (Order_Code) REFERENCES "Order" (Order_Code),
    FOREIGN KEY (Prod_Code) REFERENCES Product (Prod_Code)
);

-- INSERT DATA
INSERT INTO Customer VALUES (1, 'Ana', 'Niteroi', 'RJ');
INSERT INTO Customer VALUES (2, 'Flavio', 'Sao Paulo', 'SP');
INSERT INTO Customer VALUES (3, 'Jorge', 'Belo Horizonte', 'MG');
INSERT INTO Customer VALUES (4, 'Lucia', 'Sorocaba', 'SP');
INSERT INTO Customer VALUES (5, 'Mauro', 'Contagem', 'MG');
INSERT INTO Seller VALUES (1000, 'Jose', 1800, 'C');
INSERT INTO Seller VALUES (1001, 'Carlos', 2500, 'A');
INSERT INTO Seller VALUES (1002, 'Joao', 2700, 'C');
INSERT INTO Seller VALUES (1003, 'Antonio', 4600, 'C');
INSERT INTO Seller VALUES (1004, 'Jonas', 9500, 'A');
INSERT INTO Seller VALUES (1005, 'Mateus', 3000, 'C');
INSERT INTO "Order" VALUES (100, 5, 1001);
INSERT INTO "Order" VALUES (101, 1, 1002);
INSERT INTO "Order" VALUES (102, 3, 1004);
INSERT INTO "Order" VALUES (103, 2, 1002);
INSERT INTO "Order" VALUES (104, 1, 1005);
INSERT INTO "Order" VALUES (105, 5, 1002);
INSERT INTO Product VALUES (200, 'kg', 'cheese', 10);
INSERT INTO Product VALUES (201, 'kg', 'chocolate', 20);
INSERT INTO Product VALUES (202, 'l', 'wine', 30);
INSERT INTO Product VALUES (203, 'kg', 'sugar', 2);
INSERT INTO Product VALUES (204, 'm', 'paper', 2);
INSERT INTO Order_Item VALUES (100, 201, 3);
INSERT INTO Order_Item VALUES (100, 202, 5);
INSERT INTO Order_Item VALUES (101, 204, 15);
INSERT INTO Order_Item VALUES (102, 203, 5);
INSERT INTO Order_Item VALUES (103, 200, 12);
INSERT INTO Order_Item VALUES (104, 201, 1);
INSERT INTO Order_Item VALUES (104, 203, 4);
INSERT INTO Order_Item VALUES (104, 204, 6);
INSERT INTO Order_Item VALUES (105, 202, 10);
COMMIT;

-- 1) Create a procedure that updates the sold quantity of a specific product in a particular order.
-- Arguments: product description, order code, new quantity.
-- Use the procedure to update the quantity sold of the 'sugar' product in order 102 to 250 kilograms.

CREATE OR REPLACE PROCEDURE UpdateQuantity(
    p_product_description IN VARCHAR,
    p_order_code IN INTEGER,
    p_new_quantity IN INTEGER
)
IS
BEGIN
    UPDATE Order_Item
    SET Quantity = p_new_quantity
    WHERE Order_Code = p_order_code
    AND Prod_Code IN (SELECT Prod_Code FROM Product WHERE Description = p_product_description);
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error updating quantity.');
END;
/

EXEC UpdateQuantity('sugar', 102, 250);
SELECT * FROM Order_Item;

-- 2) Create a procedure that updates the salary of a specific seller based on the number of orders they have handled.
-- Criteria: no increase if they haven't handled any orders; 10% increase if they handled up to 2 orders; 20% increase if they handled more than 2 orders.
-- Argument: seller name.
-- Use the procedure to update (if needed) the salary of the seller 'Mateus'.

CREATE OR REPLACE PROCEDURE UpdateSalaryBasedOnOrders(
    p_seller_name IN VARCHAR
)
IS
    v_order_count INTEGER;
    v_salary_increase NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_order_count
    FROM "Order"
    WHERE Seller_Code = (SELECT Seller_Code FROM Seller WHERE Seller_Name = p_seller_name);
    
    IF v_order_count = 0 THEN
        v_salary_increase := 0; -- No increase if no orders
    ELSIF v_order_count <= 2 THEN
        v_salary_increase := 0.10; -- 10% increase for up to 2 orders
    ELSE
        v_salary_increase := 0.20; -- 20% increase for more than 2 orders
    END IF;
    
    UPDATE Seller
    SET Salary = Salary * (1 + v_salary_increase)
    WHERE Seller_Name = p_seller_name;
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error updating salary.');
END;
/

EXEC UpdateSalaryBasedOnOrders('Mateus');
SELECT * FROM Seller;

-- 3) Create a procedure that inserts a new customer, a new order for that customer, with a single product in a specified quantity.
-- Arguments: customer name, city, state, seller name, product description, quantity.
-- Use the procedure to insert yourself as a new customer, buying 20 kilograms of 'chocolate' in your order, attended by the seller 'Carlos'.

CREATE OR REPLACE PROCEDURE InsertNewOrder(
    p_customer_name IN VARCHAR,
    p_customer_city IN VARCHAR,
    p_customer_state IN CHAR,
    p_seller_name IN VARCHAR,
    p_product_description IN VARCHAR,
    p_quantity IN INTEGER
)
IS
    v_customer_id INTEGER;
    v_seller_id INTEGER;
    v_product_id INTEGER;
    v_order_id INTEGER;
BEGIN
    SELECT MAX(Cust_Code) + 1 INTO v_customer_id FROM Customer;
    INSERT INTO Customer (Cust_Code, Cust_Name, City, State)
    VALUES (v_customer_id, p_customer_name, p_customer_city, p_customer_state);
    
    SELECT Seller_Code

 INTO v_seller_id
    FROM Seller
    WHERE Seller_Name = p_seller_name;
    
    SELECT Prod_Code INTO v_product_id
    FROM Product
    WHERE Description = p_product_description;
    
    SELECT MAX(Order_Code) + 1 INTO v_order_id FROM "Order";
    
    INSERT INTO "Order" (Order_Code, Cust_Code, Seller_Code)
    VALUES (v_order_id, v_customer_id, v_seller_id);
    
    INSERT INTO Order_Item (Order_Code, Prod_Code, Quantity)
    VALUES (v_order_id, v_product_id, p_quantity);
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error inserting new customer and order.');
END;
/

EXEC InsertNewOrder('Gustavo', 'São Paulo', 'SP', 'Carlos', 'chocolate', 20);
SELECT * FROM Customer C ORDER BY C.Cust_Code ASC;
SELECT * FROM "Order" O ORDER BY O.Order_Code ASC;
SELECT * FROM Order_Item OI ORDER BY OI.Order_Code ASC;