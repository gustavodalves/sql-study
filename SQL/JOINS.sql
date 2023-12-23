-- DROP TABLES
DROP TABLE Institute CASCADE CONSTRAINT;
DROP TABLE Course CASCADE CONSTRAINT;
DROP TABLE Discipline CASCADE CONSTRAINT;
DROP TABLE Professor CASCADE CONSTRAINT;
DROP TABLE Student CASCADE CONSTRAINT;
DROP TABLE Student_Discipline CASCADE CONSTRAINT;
DROP TABLE Prof_Discipline CASCADE CONSTRAINT;

-- CREATE TABLES
CREATE TABLE Institute (
    Institute_Code INTEGER,
    Institute_Name VARCHAR(30),
    PRIMARY KEY(Institute_Code)
);

CREATE TABLE Course (
    Course_Code INTEGER,
    Course_Name VARCHAR(30),
    Institute_Code INTEGER,
    PRIMARY KEY(Course_Code),
    FOREIGN KEY (Institute_Code) REFERENCES Institute (Institute_Code)
);

CREATE TABLE Discipline (
    Discipline_Code INTEGER,
    Discipline_Name VARCHAR(30),
    Course_Code INTEGER,
    PRIMARY KEY(Discipline_Code),
    FOREIGN KEY (Course_Code) REFERENCES Course (Course_Code)
);

CREATE TABLE Professor (
    Professor_Code INTEGER,
    Professor_Name VARCHAR(30),
    Salary INTEGER,
    PRIMARY KEY(Professor_Code)
);

CREATE TABLE Student (
    Enrollment INTEGER,
    Student_Name VARCHAR(30),
    District VARCHAR(30),
    Age INTEGER,
    Course_Code INTEGER,
    Professor_Advisor_Code INTEGER,
    PRIMARY KEY(Enrollment),
    FOREIGN KEY (Course_Code) REFERENCES Course (Course_Code),
    FOREIGN KEY (Professor_Advisor_Code) REFERENCES Professor(Professor_Code)
);

CREATE TABLE Student_Discipline (
    Enrollment INTEGER,
    Discipline_Code INTEGER,
    Grade INTEGER,
    PRIMARY KEY(Enrollment, Discipline_Code),
    FOREIGN KEY (Enrollment) REFERENCES Student (Enrollment),
    FOREIGN KEY (Discipline_Code) REFERENCES Discipline (Discipline_Code)
);

CREATE TABLE Prof_Discipline (
    Professor_Code INTEGER,
    Discipline_Code INTEGER,
    Day_of_Week VARCHAR(10),
    Room INTEGER,
    PRIMARY KEY(Professor_Code, Discipline_Code),
    FOREIGN KEY (Professor_Code) REFERENCES Professor(Professor_Code),
    FOREIGN KEY (Discipline_Code) REFERENCES Discipline (Discipline_Code)
);

-- INSERT DATA
INSERT INTO Institute VALUES (1, 'Exact Sciences');
INSERT INTO Institute VALUES (2, 'Human Sciences');
INSERT INTO Institute VALUES (3, 'Biological Sciences');

INSERT INTO Course VALUES (1001, 'Computer Science', 1);
INSERT INTO Course VALUES (1002, 'Business Administration', 2);

INSERT INTO Discipline VALUES (2001, 'Database I', 1001);
INSERT INTO Discipline VALUES (2002, 'Software Engineering I', 1001);
INSERT INTO Discipline VALUES (2003, 'Database II', 1001);
INSERT INTO Discipline VALUES (2004, 'Human-Computer Interaction', 1001);
INSERT INTO Discipline VALUES (2005, 'Software Engineering II', 1001);

INSERT INTO Professor VALUES (3001, 'Camila', 1500);
INSERT INTO Professor VALUES (3002, 'Joao', 3000);
INSERT INTO Professor VALUES (3003, 'Ana', 3000);
INSERT INTO Professor VALUES (3004, 'Pedro', 2500);

INSERT INTO Student VALUES (1, 'Claudia', 'Vila Mariana', 20, 1001, 3001);
INSERT INTO Student VALUES (2, 'Andrea', 'Lapa', 24, 1001, 3002);
INSERT INTO Student VALUES (3, 'Regiane', 'Penha', 22, 1001, 3004);
INSERT INTO Student VALUES (4, 'Rodrigo', 'Sumare', 20, 1002, 3001);
INSERT INTO Student VALUES (5, 'Renata', 'Vila Mariana', 22, 1002, 3004);

INSERT INTO Student_Discipline VALUES (1, 2001, 8);
INSERT INTO Student_Discipline VALUES (1, 2002, 7);
INSERT INTO Student_Discipline VALUES (4, 2003, 6);
INSERT INTO Student_Discipline VALUES (4, 2004, 10);
INSERT INTO Student_Discipline VALUES (4, 2005, 8);

INSERT INTO Prof_Discipline VALUES (3001, 2001, 'Monday', 201);
INSERT INTO Prof_Discipline VALUES (3002, 2002, 'Wednesday', 104);
INSERT INTO Prof_Discipline VALUES (3001, 2003, 'Friday', 105);
INSERT INTO Prof_Discipline VALUES (3004, 2004, 'Tuesday', 106);
INSERT INTO Prof_Discipline VALUES (3002, 2005, 'Wednesday', 110);

-- QUERIES

-- 1) Return the name of each student who has taken courses, and for each student, their average grade
-- (considering all courses taken).

SELECT (s.Student_Name), AVG(sd.Grade) AS Average_Grade
FROM Student s 
INNER JOIN Student_Discipline sd ON s.Enrollment = sd.Enrollment
GROUP BY s.Student_Name;

-- 2) Return the name of all courses (even those without registered disciplines) and the number
-- of disciplines for each course.

SELECT (c.Course_Name) AS Course_Name, COUNT(d.Discipline_Code) AS Number_of_Disciplines
FROM Course c 
LEFT JOIN Discipline d
ON c.Course_Code = d.Course_Code
GROUP BY c.Course_Name;

-- 3) Return the name of all students (even those who have not finished any discipline) and, for
-- each student, the number of courses taken.

SELECT (s.Student_Name), COUNT(sd.Discipline_Code) AS Number_of_Disciplines_Taken
FROM Student s
LEFT JOIN Student_Discipline sd ON sd.Enrollment = s.Enrollment
GROUP BY s.Student_Name;

-- 4) Return the name of all university students (even those who have not finished any discipline),
-- the names of the disciplines, and the grades of each discipline that the students took.

SELECT (s.Student_Name) AS Student, (d.Discipline_Name) AS Discipline, (sd.Grade) AS Grade
FROM Student s
LEFT JOIN Student_Discipline sd ON sd.Enrollment = s.Enrollment
LEFT JOIN Discipline d ON sd.Discipline_Code = d.Discipline_Code;

-- 5) (in this question, use LEFT JOIN and RIGHT JOIN) Return the name of all university professors (even those who are not teaching any discipline),
-- and the names of the disciplines they teach.

SELECT P.Professor_Name, D.Discipline_Name
FROM Discipline D LEFT JOIN Prof_Discipline PD
ON PD.Discipline_Code = D.Discipline_Code 
RIGHT JOIN Professor P 
ON P.Professor_Code = PD.Professor_Code;
