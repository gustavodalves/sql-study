-- DROP TABLES
DROP TABLE Func_Proj CASCADE CONSTRAINTS;
DROP TABLE Project CASCADE CONSTRAINTS;
DROP TABLE Employee CASCADE CONSTRAINTS;
DROP TABLE Department CASCADE CONSTRAINTS;

-- CREATE TABLES
CREATE TABLE Department
(Department_Code INTEGER,
Department_Name VARCHAR(20),
PRIMARY KEY(Department_Code));

CREATE TABLE Employee
(Employee_Code INTEGER,
Employee_Name VARCHAR(20),
Salary INTEGER,
Department_Code INTEGER,
PRIMARY KEY(Employee_Code),
FOREIGN KEY (Department_Code) REFERENCES Department (Department_Code));

CREATE TABLE Project
(Project_Code INTEGER,
Project_Name VARCHAR(20),
Duration INTEGER,
PRIMARY KEY(Project_Code));

CREATE TABLE Func_Proj
(Employee_Code INTEGER,
Project_Code INTEGER,
Work_Hours INTEGER,
PRIMARY KEY(Employee_Code, Project_Code),
FOREIGN KEY (Employee_Code) REFERENCES Employee(Employee_Code),
FOREIGN KEY (Project_Code) REFERENCES Project(Project_Code));

-- INSERT DATA
INSERT INTO Department (Department_Code, Department_Name)
VALUES (1, 'Marketing');
INSERT INTO Department (Department_Code, Department_Name)
VALUES (2, 'Sales');
INSERT INTO Department (Department_Code, Department_Name)
VALUES (3, 'Data');
INSERT INTO Department (Department_Code, Department_Name)
VALUES (4, 'Research');

INSERT INTO Employee (Employee_Code, Employee_Name, Salary, Department_Code)
VALUES (101, 'Joao da Silva Santos', 2000, 2);
INSERT INTO Employee (Employee_Code, Employee_Name, Salary, Department_Code)
VALUES (102, 'Mario Souza', 1500, 1);
INSERT INTO Employee (Employee_Code, Employee_Name, Salary, Department_Code)
VALUES (103, 'Sergio Silva Santos', 2400, 2);
INSERT INTO Employee (Employee_Code, Employee_Name, Salary, Department_Code)
VALUES (104, 'Maria Castro', 1200, 1);
INSERT INTO Employee (Employee_Code, Employee_Name, Salary, Department_Code)
VALUES (105, 'Marcio Silva Santana', 1400, 4);

INSERT INTO Project (Project_Code, Project_Name, Duration)
VALUES (1001, 'SystemA', 2);
INSERT INTO Project (Project_Code, Project_Name, Duration)
VALUES (1002, 'SystemB', 6);
INSERT INTO Project (Project_Code, Project_Name, Duration)
VALUES (1003, 'SystemX', 4);

INSERT INTO Func_Proj (Employee_Code, Project_Code, Work_Hours)
VALUES (101, 1001, 24);
INSERT INTO Func_Proj (Employee_Code, Project_Code, Work_Hours)
VALUES (101, 1002, 160);
INSERT INTO Func_Proj (Employee_Code, Project_Code, Work_Hours)
VALUES (102, 1001, 56);
INSERT INTO Func_Proj (Employee_Code, Project_Code, Work_Hours)
VALUES (102, 1003, 45);
INSERT INTO Func_Proj (Employee_Code, Project_Code, Work_Hours)
VALUES (103, 1001, 86);
INSERT INTO Func_Proj (Employee_Code, Project_Code, Work_Hours)
VALUES (103, 1003, 64);
INSERT INTO Func_Proj (Employee_Code, Project_Code, Work_Hours)
VALUES (104, 1001, 46);
INSERT INTO Func_Proj (Employee_Code, Project_Code, Work_Hours)
VALUES (105, 1001, 84);
INSERT INTO Func_Proj (Employee_Code, Project_Code, Work_Hours)
VALUES (105, 1002, 86);
COMMIT;

-- 1) Develop a PL/SQL block that updates the salary of the employee with code 103, following these criteria:
-- • If the salary of this employee with code 103 is greater than or equal to 800 and less than 2000, then increase the salary by 50%;
-- • Otherwise, if the salary is less than or equal to 2000, increase it by 40%;
-- • Otherwise, increase it by 10%;
-- • Finally, display the new salary value for employee 103 on the screen.

SELECT employee_code, salary FROM employee WHERE employee_code = 103;
DECLARE
    v_employee_code   employee.employee_code%TYPE := 103;
    v_salary          employee.salary%TYPE;
    v_employee_name   employee.employee_name%TYPE;
BEGIN
    SELECT employee_name, salary INTO v_employee_name, v_salary
    FROM employee
    WHERE employee_code = v_employee_code;

    IF (v_salary >= 800 AND v_salary <= 2000) THEN
        v_salary := v_salary * 1.5;
    ELSIF (v_salary <= 2000) THEN
        v_salary := v_salary * 1.4;
    ELSE
        v_salary := v_salary * 1.1;
    END IF;

    DBMS_OUTPUT.PUT_LINE('Employee Salary: ' || v_salary);

    UPDATE employee SET salary = v_salary
    WHERE employee_code = v_employee_code;
END;
/

SELECT employee_code, salary FROM employee WHERE employee_code = 103;

-- 2) (Use the WHILE structure)
-- Develop a PL/SQL block that increases the salary of the employee with code 101, each time by 10%,
-- as long as his salary is less than or equal to 10000.
-- Each time the salary of employee 101 is increased,
-- insert a new row into the Historico_Salario table (whose creation script is shown below).
-- Finally, display the final value of the new salary for employee 101 after all updates.

SELECT salary FROM employee WHERE employee_code = 101;

DROP TABLE Historico_Salario;
CREATE TABLE Historico_Salario
    (Employee_Code INTEGER,
    New_Salary INTEGER,
    Update_Date DATE,
    PRIMARY KEY(Employee_Code, New_Salary)
);

DECLARE
    v_employee_code   employee.employee_code%TYPE := 101;
    v_salary          employee.salary%TYPE;
    v_employee_name   employee.employee_name%TYPE;
    v_output_str      VARCHAR2(200) := '';
BEGIN
    SELECT employee_name, salary INTO v_employee_name, v_salary
    FROM employee
    WHERE employee_code = v_employee_code;

    WHILE (v_salary < 10000) LOOP
        v_salary := v_salary * 1.1;
        UPDATE employee SET salary = v_salary
        WHERE employee_code = v_employee_code;

        INSERT INTO Historico_Salario (employee_code, new_salary, update_date)
        VALUES (v_employee_code, v_salary, SYSDATE);
    END LOOP;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('The code ' || v_employee_code || ' does not exist');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

SELECT salary FROM employee WHERE employee_code = 101;