-- DROP TABLES
DROP TABLE Departments CASCADE CONSTRAINTS;
DROP TABLE Employees CASCADE CONSTRAINTS;
DROP TABLE Dependents CASCADE CONSTRAINTS;
DROP TABLE Projects CASCADE CONSTRAINTS;
DROP TABLE Machines CASCADE CONSTRAINTS;
DROP TABLE Uses CASCADE CONSTRAINTS;

-- CREATE TABLES
CREATE TABLE Departments (
    Dept_Code INTEGER,
    Dept_Name VARCHAR(20),
    PRIMARY KEY(Dept_Code)
);

CREATE TABLE Employees (
    Emp_Code INTEGER,
    Emp_Name VARCHAR(20),
    Salary INTEGER,
    Sup_Emp_Code INTEGER,
    Dept_Code INTEGER,
    PRIMARY KEY(Emp_Code),
    FOREIGN KEY (Dept_Code) REFERENCES Departments (Dept_Code)
);

CREATE TABLE Dependents (
    Dep_Code INTEGER,
    Dep_Name VARCHAR(20),
    Relationship VARCHAR(20),
    Emp_Code INTEGER,
    PRIMARY KEY(Dep_Code),
    FOREIGN KEY (Emp_Code) REFERENCES Employees(Emp_Code)
);

CREATE TABLE Projects (
    Proj_Code INTEGER,
    Proj_Name VARCHAR(20),
    Duration INTEGER,
    Dept_Code INTEGER,
    PRIMARY KEY(Proj_Code),
    FOREIGN KEY (Dept_Code) REFERENCES Departments (Dept_Code)
);

CREATE TABLE Machines (
    Machine_Code INTEGER,
    Machine_Name VARCHAR(20),
    PRIMARY KEY(Machine_Code)
);

CREATE TABLE Uses (
    Emp_Code INTEGER,
    Proj_Code INTEGER,
    Machine_Code INTEGER,
    Hours INTEGER,
    PRIMARY KEY(Emp_Code, Proj_Code, Machine_Code),
    FOREIGN KEY (Emp_Code) REFERENCES Employees(Emp_Code),
    FOREIGN KEY (Proj_Code) REFERENCES Projects(Proj_Code),
    FOREIGN KEY (Machine_Code) REFERENCES Machines(Machine_Code)
);

-- INSERT DATA
INSERT INTO Departments VALUES (1, 'Research');
INSERT INTO Departments VALUES (2, 'Administration');
INSERT INTO Departments VALUES (3, 'Central');
INSERT INTO Employees VALUES (1, 'Joao', 3000, 3, 3);
INSERT INTO Employees VALUES (2, 'Flavio', 4000, 3, 1);
INSERT INTO Employees VALUES (3, 'Ana', 2500, 5, 2);
INSERT INTO Employees VALUES (4, 'Jose', 4300, 5, 3);
INSERT INTO Employees VALUES (5, 'Renata', 3800, 5, 3);
INSERT INTO Dependents VALUES (101, 'Alvaro', 'Son', 1);
INSERT INTO Dependents VALUES (102, 'Marcia', 'Wife', 2);
INSERT INTO Dependents VALUES (103, 'Carmem', 'Wife', 4);
INSERT INTO Dependents VALUES (104, 'Marcos', 'Son', 4);
INSERT INTO Projects VALUES (1001, 'ProductX', 2, 1);
INSERT INTO Projects VALUES (1002, 'ProductY', 3, 3);
INSERT INTO Projects VALUES (1003, 'ProductZ', 8, 2);
INSERT INTO Projects VALUES (1004, 'Computing', 12, 1);
INSERT INTO Projects VALUES (1005, 'Reorganization', 12, 2);
INSERT INTO Projects VALUES (1006, 'NewBenefits', 8, 2);
INSERT INTO Machines VALUES (201, 'Computer1');
INSERT INTO Machines VALUES (202, 'Computer2');
INSERT INTO Machines VALUES (203, 'Computer3');
INSERT INTO Uses VALUES (1, 1002, 201, 32);
INSERT INTO Uses VALUES (1, 1005, 203, 7);
INSERT INTO Uses VALUES (1, 1005, 202, 14);
INSERT INTO Uses VALUES (2, 1004, 201, 40);
INSERT INTO Uses VALUES (2, 1001, 201, 30);
INSERT INTO Uses VALUES (3, 1005, 203, 20);
INSERT INTO Uses VALUES (4, 1002, 203, 10);
INSERT INTO Uses VALUES (4, 1006, 201, 10);
INSERT INTO Uses VALUES (5, 1003, 201, 30);
INSERT INTO Uses VALUES (5, 1005, 202, 10);
INSERT INTO Uses VALUES (5, 1006, 203, 35);

-- Exercise 1: Get the name and salary of all employees
SELECT Emp_Name, Salary FROM Employees;

-- Exercise 2: Get the name and relationship of dependents along with the name of their respective employees
SELECT D.Dep_Name, D.Relationship, E.Emp_Name
FROM Dependents D
JOIN Employees E ON D.Emp_Code = E.Emp_Code;

-- Exercise 3: Get the name of employees who are supervisors
SELECT E.Emp_Name
FROM Employees E
WHERE E.Emp_Code IN (SELECT DISTINCT Sup_Emp_Code FROM Employees WHERE Sup_Emp_Code IS NOT NULL);

-- Exercise 4: Increase the salary of employees in the 'Research' department by 20%
UPDATE Employees 
SET Salary = Salary + Salary * 0.20
WHERE Dept_Code IN (
    SELECT Dept_Code 
    FROM Departments
    WHERE Dept_Name = 'Research'
);

-- Exercise 5: Delete all information from the Uses table related to projects and machines that employee 'Renata' worked on
DELETE FROM Uses
WHERE Emp_Code IN (
    SELECT Emp_Code 
    FROM Employees
    WHERE Emp_Name = 'Renata'
);

-- Display the updated Uses table
SELECT * FROM Uses;
