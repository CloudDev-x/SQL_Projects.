
-- Database: HealthcarePatientDb
CREATE DATABASE HealthcarePatientDb
GO

USE HealthcarePatientDb
GO


-- Creating the Patient table
CREATE TABLE Patient (
    PatientID VARCHAR(5) PRIMARY KEY,
    PatientName VARCHAR(100),
    Age INT,
    Gender CHAR(1),
    DoctorID INT,
    StateID INT
);

-- Inserting data into Patient table
INSERT INTO Patient (PatientID, PatientName, Age, Gender, DoctorID, StateID)
VALUES
('PT01', 'John Doe', 45, 'M', 1, 101),
('PT02', 'Jane Smith', 30, 'F', 2, 102),
('PT03', 'Mary Johnson', 60, 'F', 3, 103),
('PT04', 'Michael Brown', 50, 'M', 4, 104),
('PT05', 'Patricia Davis', 40, 'F', 1, 105),
('PT06', 'Robert Miller', 55, 'M', 2, 106),
('PT07', 'Linda Wilson', 35, 'F', 3, 107),
('PT08', 'William Moore', 65, 'M', 4, 108),
('PT09', 'Barbara Taylor', 28, 'F', 1, 109),
('PT10', 'James Anderson', 70, 'M', 2, 110);

-- Creating the Doctor table
CREATE TABLE Doctor (
    DoctorID INT PRIMARY KEY,
    DoctorName VARCHAR(100),
    Specialization VARCHAR(100)
);

-- Inserting data into Doctor table
INSERT INTO Doctor (DoctorID, DoctorName, Specialization)
VALUES
(1, 'Dr. Smith', 'Cardiology'),
(2, 'Dr. Adams', 'Neurology'),
(3, 'Dr. White', 'Orthopedics'),
(4, 'Dr. Johnson', 'Dermatology');

-- Creating the Statemaster table
CREATE TABLE Statemaster (
    StateID INT PRIMARY KEY,
    StateName VARCHAR(100)
);

-- Inserting data into Statemaster table
INSERT INTO Statemaster (StateID, StateName)
VALUES
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

-- Creating the Department table
CREATE TABLE Department (
    DepartmentID INT PRIMARY KEY,
    DepartmentName VARCHAR(100)
);

-- Inserting data into Department table
INSERT INTO Department (DepartmentID, DepartmentName)
VALUES
(1, 'Cardiology'),
(2, 'Neurology'),
(3, 'Orthopedics'),
(4, 'Dermatology');


-- Fetch patients with the same age
SELECT PatientName, Age
FROM Patient
GROUP BY Age, PatientName
HAVING COUNT(Age) > 1;


-- Find the second oldest patient and their doctor and department
WITH RankedPatients AS (
    SELECT PatientName, Age, DoctorName, DepartmentName,
           ROW_NUMBER() OVER (ORDER BY Age DESC) AS RowNum
    FROM Patient P
    JOIN Doctor D ON P.DoctorID = D.DoctorID
    JOIN Department Dept ON D.DoctorID = Dept.DepartmentID
)
SELECT PatientName, Age, DoctorName, DepartmentName
FROM RankedPatients
WHERE RowNum = 2;


-- Get the maximum age per department and the patient name
SELECT Dept.DepartmentName, MAX(P.Age) AS MaxAge, P.PatientName
FROM Patient P
JOIN Doctor D ON P.DoctorID = D.DoctorID
JOIN Department Dept ON D.DoctorID = Dept.DepartmentID
GROUP BY Dept.DepartmentName, P.PatientName;


-- Doctor-wise count of patients sorted by count in descending order
SELECT D.DoctorName, COUNT(P.PatientID) AS PatientCount
FROM Patient P
JOIN Doctor D ON P.DoctorID = D.DoctorID
GROUP BY D.DoctorName
ORDER BY PatientCount DESC;


-- Fetch only the first name from the PatientName and append the age
SELECT SUBSTRING(PatientName, 1, CHARINDEX(' ', PatientName) - 1) AS FirstName, Age
FROM Patient;


-- Fetch patients with odd ages
SELECT PatientName, Age
FROM Patient
WHERE Age % 2 <> 0;

-- Create a view to fetch patient details with an age greater than 50
CREATE VIEW View_PatientDetailsOver50 AS
SELECT P.PatientID, P.PatientName, P.Age, P.Gender, D.DoctorName, S.StateName
FROM Patient P
JOIN Doctor D ON P.DoctorID = D.DoctorID
JOIN Statemaster S ON P.StateID = S.StateID
WHERE P.Age > 50;


-- Create a procedure to update the patient's age by 10% where the department is 'Cardiology' and the doctor is not 'Dr. Smith'
CREATE PROCEDURE UpdateAgeForCardiologyPatients
AS
BEGIN
    UPDATE P
    SET P.Age = P.Age * 1.1
    FROM Patient P
    JOIN Doctor D ON P.DoctorID = D.DoctorID
    JOIN Department Dept ON D.DoctorID = Dept.DepartmentID
    WHERE Dept.DepartmentName = 'Cardiology' AND D.DoctorName <> 'Dr. Smith';
END;


-- Create a stored procedure to fetch patient details along with their doctor, department, and state, including error handling
CREATE PROCEDURE FetchPatientDetails
AS
BEGIN
    BEGIN TRY
        SELECT P.PatientID, P.PatientName, P.Age, P.Gender, D.DoctorName, Dept.DepartmentName, S.StateName
        FROM Patient P
        JOIN Doctor D ON P.DoctorID = D.DoctorID
        JOIN Department Dept ON D.DoctorID = Dept.DepartmentID
        JOIN Statemaster S ON P.StateID = S.StateID;
    END TRY
    BEGIN CATCH
        PRINT 'An error occurred while fetching patient details.';
    END CATCH;
END;
