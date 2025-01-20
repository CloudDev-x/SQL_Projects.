
-- 1. Create the database
CREATE DATABASE EmployeeDbForHrDept;
USE EmployeeDbForHrDept;

-- 2. Create tables

-- Employee Table
CREATE TABLE Employee (
    EmpID VARCHAR(10),
    EmpName VARCHAR(50),
    Salary DECIMAL(10, 2),
    DepartmentID INT,
    Stateid INT
);

-- Department Table
CREATE TABLE Department (
    DepartmentID INT,
    DepartmentName VARCHAR(50)
);

-- Projectmanager Table
CREATE TABLE Projectmanager (
    ProjectMangerID INT,
    ProjectMangerName VARCHAR(50),
    DepartmentID INT
);

-- Statemaster Table
CREATE TABLE Statemaster (
    Stateid INT,
    Statename VARCHAR(50)
);

-- 3. Insert values into tables

-- Insert into Employee
INSERT INTO Employee (EmpID, EmpName, Salary, DepartmentID, Stateid) VALUES
('A01', 'Monika singh', 10000, 1, 101),
('A02', 'Vishal kumar', 25000, 2, 101),
('B01', 'Sunil Rana', 10000, 3, 102),
('B02', 'Saurav Rawat', 15000, 2, 103),
('B03', 'Vivek Kataria', 19000, 4, 104),
('C01', 'Vipul Gupta', 45000, 2, 105),
('C02', 'Geetika Basin', 33000, 3, 101),
('C03', 'Satish Sharama', 45000, 1, 103),
('C04', 'Sagar Kumar', 50000, 2, 102),
('C05', 'Amitabh singh', 37000, 3, 108);

-- Insert into Department
INSERT INTO Department (DepartmentID, DepartmentName) VALUES
(1, 'IT'),
(2, 'HR'),
(3, 'Admin'),
(4, 'Account');

-- Insert into Projectmanager
INSERT INTO Projectmanager (ProjectMangerID, ProjectMangerName, DepartmentID) VALUES
(1, 'Monika', 1),
(2, 'Vivek', 1),
(3, 'Vipul', 2),
(4, 'Satish', 2),
(5, 'Amitabh', 3);

-- Insert into Statemaster
INSERT INTO Statemaster (Stateid, Statename) VALUES
(101, 'Lagos'),
(102, 'Abuja'),
(103, 'Kano'),
(104, 'Delta'),
(105, 'Ido'),
(106, 'Ibadan');


--  Fetch the list of employees with the same salary.
SELECT EmpName, Salary
FROM Employee
WHERE Salary IN (
    SELECT Salary
    FROM Employee
    GROUP BY Salary
    HAVING COUNT(*) > 1
);

--  Find the second highest salary and the department and name of the earner.
SELECT EmpName, Salary, d.Departmantname
FROM Employee e
JOIN Department d ON e.DepartmentID = d.DepartmentID
WHERE Salary = (
    SELECT DISTINCT Salary
    FROM Employee
    ORDER BY Salary DESC
    OFFSET 1 ROW FETCH NEXT 1 ROW ONLY
);

--  Get the maximum salary from each department, the name of the department, and the name of the earner.
SELECT e.EmpName, e.Salary, d.Departmantname
FROM Employee e
JOIN Department d ON e.DepartmentID = d.DepartmentID
WHERE e.Salary = (
    SELECT MAX(Salary)
    FROM Employee
    WHERE DepartmentID = d.DepartmentID
    GROUP BY DepartmentID
);

--  Project manager-wise count of employees sorted by project manager's count in descending order.
SELECT pm.ProjectMangerName, COUNT(e.EmpID) AS EmployeeCount
FROM ProjectManager pm
LEFT JOIN Employee e ON pm.DepartmentID = e.DepartmentID
GROUP BY pm.ProjectMangerName
ORDER BY EmployeeCount DESC;

--  Fetch only the first name from the EmpName column of Employee table and concatenate it with the salary.
SELECT CONCAT(LEFT(EmpName, CHARINDEX(' ', EmpName + ' ') - 1), '_', Salary) AS EmpSalary
FROM Employee;

--  Fetch only odd salaries from the Employee table.
SELECT *
FROM Employee
WHERE Salary % 2 <> 0;

--  Create a view to fetch EmpID, EmpName, Departmantname, ProjectMangerName where salary is greater than 30000.
CREATE VIEW HighSalaryEmployees AS
SELECT e.EmpID, e.EmpName, d.Departmantname, pm.ProjectMangerName
FROM Employee e
JOIN Department d ON e.DepartmentID = d.DepartmentID
JOIN ProjectManager pm ON d.DepartmentID = pm.DepartmentID
WHERE e.Salary > 30000;

-- Create a view to fetch the top earners from each department, the employee name, and the department they belong to.
CREATE VIEW TopEarners AS
SELECT e.EmpName, d.Departmantname
FROM Employee e
JOIN Department d ON e.DepartmentID = d.DepartmentID
WHERE e.Salary IN (
    SELECT MAX(Salary)
    FROM Employee
    GROUP BY DepartmentID
);

--  Create a procedure to update the employee’s salary by 25% where the department is ‘IT’ and project manager is not ‘Vivek’ or ‘Satish’.
CREATE PROCEDURE UpdateITSalary
AS
BEGIN
    UPDATE Employee
    SET Salary = Salary * 1.25
    WHERE DepartmentID = (SELECT DepartmentID FROM Department WHERE Departmantname = 'IT')
      AND ProjectID NOT IN (
          SELECT ProjectID
          FROM ProjectManager
          WHERE ProjectMangerName IN ('Vivek', 'Satish')
      );
END;

--  Create a stored procedure to fetch all employee names along with DepartmentName, ProjectManagerName, StateName, and include error handling.
CREATE PROCEDURE GetEmployeeDetails
AS
BEGIN
    BEGIN TRY
        SELECT e.EmpName, d.Departmantname, pm.ProjectMangerName, s.Statename
        FROM Employee e
        JOIN Department d ON e.DepartmentID = d.DepartmentID
        JOIN ProjectManager pm ON d.DepartmentID = pm.DepartmentID
        JOIN Statemaster s ON e.StateID = s.Stateid;
    END TRY
    BEGIN CATCH
        SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage;
    END CATCH
END;
