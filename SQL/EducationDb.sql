-- Create the database
CREATE DATABASE EducationStudentDb;
GO

-- Use the created database
USE EducationStudentDb;
GO

-- Create the StateMaster table
CREATE TABLE StateMaster (
    StateID INT PRIMARY KEY,
    StateName VARCHAR(50) NOT NULL
);
GO

-- Insert data into StateMaster
INSERT INTO StateMaster (StateID, StateName) VALUES
(101, 'Lagos'),
(102, 'Abuja'),
(103, 'Kano'),
(104, 'Delta'),
(105, 'Ido'),
(106, 'Ibadan'),
(107, 'Enugu'),
(108, 'Kaduna'),
(109, 'Ogun'),
(110, 'Anambra');
GO

-- Create the TeacherMaster table
CREATE TABLE TeacherMaster (
    TeacherID VARCHAR(10) PRIMARY KEY,
    TeacherName VARCHAR(50) NOT NULL,
    Subject VARCHAR(50) NOT NULL
);
GO

-- Insert data into TeacherMaster
INSERT INTO TeacherMaster (TeacherID, TeacherName, Subject) VALUES
('T01', 'Mr. Johnson', 'Mathematics'),
('T02', 'Ms. Smith', 'Science'),
('T03', 'Mr. Williams', 'English'),
('T04', 'Ms. Brown', 'History');
GO

-- Create the ClassMaster table
CREATE TABLE ClassMaster (
    ClassID INT PRIMARY KEY,
    ClassName VARCHAR(50) NOT NULL,
    TeacherID VARCHAR(10),
    FOREIGN KEY (TeacherID) REFERENCES TeacherMaster(TeacherID)
);
GO

-- Insert data into ClassMaster
INSERT INTO ClassMaster (ClassID, ClassName, TeacherID) VALUES
(1, '10th Grade', 'T01'),
(2, '9th Grade', 'T02'),
(3, '11th Grade', 'T03'),
(4, '12th Grade', 'T04');
GO

-- Create the Student table
CREATE TABLE Student (
    StudentID VARCHAR(10) PRIMARY KEY,
    StudentName VARCHAR(50) NOT NULL,
    Age INT NOT NULL,
    ClassID INT,
    StateID INT,
    FOREIGN KEY (ClassID) REFERENCES ClassMaster(ClassID),
    FOREIGN KEY (StateID) REFERENCES StateMaster(StateID)
);
GO

-- Insert data into Student
INSERT INTO Student (StudentID, StudentName, Age, ClassID, StateID) VALUES
('S01', 'Alice Brown', 16, 1, 101),
('S02', 'Bob White', 15, 2, 102),
('S03', 'Charlie Black', 17, 3, 103),
('S04', 'Daisy Green', 16, 4, 104),
('S05', 'Edward Blue', 14, 1, 105),
('S06', 'Fiona Red', 15, 2, 106),
('S07', 'George Yellow', 18, 3, 107),
('S08', 'Hannah Purple', 16, 4, 108),
('S09', 'Ian Orange', 17, 1, 109),
('S10', 'Jane Grey', 14, 2, 110);
GO

-- 1. Fetch Students with the Same Age
SELECT StudentName, Age
FROM Student
WHERE Age IN (
    SELECT Age
    FROM Student
    GROUP BY Age
    HAVING COUNT(*) > 1
);
GO

-- 2. Find the Second Youngest Student and Their Class and Teacher
WITH RankedStudents AS (
    SELECT 
        StudentName, 
        Age, 
        C.ClassName, 
        T.TeacherName,
        ROW_NUMBER() OVER (ORDER BY Age ASC) AS RowNum
    FROM Student S
    JOIN ClassMaster C ON S.ClassID = C.ClassID
    JOIN TeacherMaster T ON C.TeacherID = T.TeacherID
)
SELECT StudentName, Age, ClassName, TeacherName
FROM RankedStudents
WHERE RowNum = 2;
GO

-- 3. Get the Maximum Age Per Class and the Student Name
SELECT 
    C.ClassName,
    S.StudentName,
    S.Age
FROM Student S
JOIN ClassMaster C ON S.ClassID = C.ClassID
WHERE (S.ClassID, S.Age) IN (
    SELECT ClassID, MAX(Age)
    FROM Student
    GROUP BY ClassID
);
GO

-- 4. Teacher-wise Count of Students Sorted by Count in Descending Order
SELECT 
    T.TeacherName,
    COUNT(S.StudentID) AS StudentCount
FROM TeacherMaster T
LEFT JOIN ClassMaster C ON T.TeacherID = C.TeacherID
LEFT JOIN Student S ON C.ClassID = S.ClassID
GROUP BY T.TeacherName
ORDER BY StudentCount DESC;
GO

-- 5. Fetch Only the First Name from the StudentName and Append the Age
SELECT 
    LEFT(StudentName, CHARINDEX(' ', StudentName) - 1) AS FirstName,
    Age
FROM Student;
GO

-- 6. Fetch Students with Odd Ages
SELECT StudentName, Age
FROM Student
WHERE Age % 2 <> 0;
GO

-- 7. Create a View to Fetch Student Details with an Age Greater Than 15
CREATE VIEW View_Students_Age_Above_15 AS
SELECT 
    S.StudentID, 
    S.StudentName, 
    S.Age, 
    C.ClassName, 
    T.TeacherName, 
    SM.StateName
FROM Student S
JOIN ClassMaster C ON S.ClassID = C.ClassID
JOIN TeacherMaster T ON C.TeacherID = T.TeacherID
JOIN StateMaster SM ON S.StateID = SM.StateID
WHERE S.Age > 15;
GO

-- 8. Create a Procedure to Update the Student's Age by 1 Year Where the Class is '10th Grade' and the Teacher is Not 'Mr. Johnson'
CREATE PROCEDURE UpdateStudentAgeFor10thGrade
AS
BEGIN
    UPDATE Student
    SET Age = Age + 1
    WHERE ClassID = (
        SELECT ClassID
        FROM ClassMaster
        WHERE ClassName = '10th Grade'
    ) AND ClassID IN (
        SELECT ClassID
        FROM ClassMaster C
        JOIN TeacherMaster T ON C.TeacherID = T.TeacherID
        WHERE T.TeacherName <> 'Mr. Johnson'
    );
END;
GO

-- 9. Create a Stored Procedure to Fetch Student Details Along with Their Class, Teacher, and State, Including Error Handling
CREATE PROCEDURE GetStudentDetails
AS
BEGIN
    BEGIN TRY
        SELECT 
            S.StudentID, 
            S.StudentName, 
            S.Age, 
            C.ClassName, 
            T.TeacherName, 
            SM.StateName
        FROM Student S
        JOIN ClassMaster C ON S.ClassID = C.ClassID
        JOIN TeacherMaster T ON C.TeacherID = T.TeacherID
        JOIN StateMaster SM ON S.StateID = SM.StateID;
    END TRY
    BEGIN CATCH
        SELECT 
            ERROR_NUMBER() AS ErrorNumber, 
            ERROR_MESSAGE() AS ErrorMessage;
    END CATCH;
END;
GO
