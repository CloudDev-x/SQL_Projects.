-- Create the database
CREATE DATABASE FinanceLoanDb;

USE FinanceLoanDb;

-- Create Statemaster table
CREATE TABLE Statemaster (
    StateID INT PRIMARY KEY,
    StateName VARCHAR(50) NOT NULL
);
GO


-- Create Branchmaster table
CREATE TABLE Branchmaster (
    BranchID VARCHAR(3) PRIMARY KEY,
    BranchName VARCHAR(50) NOT NULL,
    Location VARCHAR(100) NOT NULL
);
GO

-- Create Customer table
CREATE TABLE Customer (
    CustomerID VARCHAR(3) PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL,
    StateID INT NOT NULL,
    FOREIGN KEY (StateID) REFERENCES Statemaster(StateID) -- Link to Statemaster
);
GO

-- Create Loan table
CREATE TABLE Loan (
    LoanID VARCHAR(3) PRIMARY KEY,
    LoanType VARCHAR(50) NOT NULL,
    LoanAmount DECIMAL(10, 2) NOT NULL,
    CustomerID VARCHAR(3),
    InterestRate DECIMAL(5, 2) NOT NULL, -- Assuming interest rate is in percentage
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID) -- Link to Customer
);
GO

-- Insert data into Statemaster
INSERT INTO Statemaster (StateID, StateName) VALUES
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

-- Insert data into Branchmaster
INSERT INTO Branchmaster (BranchID, BranchName, Location) VALUES
('B01', 'MainBranch', 'Lagos'),
('B02', 'EastBranch', 'Abuja'),
('B03', 'WestBranch', 'Kano'),
('B04', 'NorthBranch', 'Delta'),
('B05', 'SouthBranch', 'Ido'),
('B06', 'CentralBranch', 'Ibadan'),
('B07', 'PacificBranch', 'Enugu'),
('B08', 'MountainBranch', 'Kaduna'),
('B09', 'SouthernBranch', 'Ogun'),
('B10', 'GulfBranch', 'Anambra');
GO

-- Insert data into Customer
INSERT INTO Customer (CustomerID, CustomerName, StateID) VALUES
('C01', 'Alice Johnson', 101),
('C02', 'Bob Smith', 102),
('C03', 'Carol White', 103),
('C04', 'Dave Williams', 104),
('C05', 'Emma Brown', 105),
('C06', 'Frank Miller', 106),
('C07', 'Grace Davis', 107),
('C08', 'Henry Wilson', 108),
('C09', 'Irene Moore', 109),
('C10', 'Jack Taylor', 110);
GO


-- Insert data into Loan
INSERT INTO Loan (LoanID, LoanType, LoanAmount, CustomerID, InterestRate) VALUES
('L01', 'Home Loan', 50000, 'C01', 5.50),
('L02', 'Auto Loan', 75000, 'C02', 6.00),
('L03', 'Personal Loan', 60000, 'C03', 4.80),
('L04', 'Education Loan', 85000, 'C04', 5.20),
('L05', 'Business Loan', 55000, 'C05', 4.50),
('L06', 'Home Loan', 40000, 'C06', 6.50),
('L07', 'Auto Loan', 95000, 'C07', 5.80),
('L08', 'Personal Loan', 30000, 'C08', 6.20),
('L09', 'Education Loan', 70000, 'C09', 5.00),
('L10', 'Business Loan', 80000, 'C10', 5.70);
GO


--Fetch Customers with the Same Loan Amount
SELECT c.CustomerName, l.LoanAmount
FROM Customer c
JOIN Loan l ON c.CustomerID = l.CustomerID
WHERE l.LoanAmount IN (
    SELECT LoanAmount
    FROM Loan
    GROUP BY LoanAmount
    HAVING COUNT(*) > 1
);
GO

--Find the Second Highest Loan Amount and the Customer and Branch Associated with It
WITH RankedLoans AS (
    SELECT 
        l.LoanAmount, 
        c.CustomerName, 
        b.BranchName,
        ROW_NUMBER() OVER (ORDER BY l.LoanAmount DESC) AS RowNum
    FROM Loan l
    JOIN Customer c ON l.CustomerID = c.CustomerID
    JOIN Branchmaster b ON b.BranchID = l.LoanID -- Adjust based on your actual schema
)
SELECT 
    LoanAmount, 
    CustomerName, 
    BranchName
FROM RankedLoans
WHERE RowNum = 2;
GO

-- Create a View to Fetch Loan Details with an Amount Greater Than $50,000
CREATE VIEW HighValueLoans AS
SELECT 
    l.LoanID, 
    c.CustomerName, 
    l.LoanAmount, 
    b.BranchName
FROM Loan l
JOIN Customer c ON l.CustomerID = c.CustomerID
JOIN Branchmaster b ON b.BranchID = l.LoanID -- Adjust based on your actual schema
WHERE l.LoanAmount > 50000;
GO

-- Create a Procedure to Update the Loan Interest Rate by 2%
CREATE PROCEDURE FetchLoanDetailsSimple
AS
BEGIN
    SELECT 
        c.CustomerName, 
        l.LoanAmount, 
        b.BranchName, 
        s.StateName
    FROM Loan l
    JOIN Customer c ON l.CustomerID = c.CustomerID
    JOIN Branchmaster b ON b.BranchID = l.LoanID  -- Adjust based on your actual schema
    JOIN Statemaster s ON s.StateID = c.StateID;
END;

