-- Create the ManchesterHotelDb database
CREATE DATABASE ManchesterHotelDb;
GO

-- Use the created database
USE ManchesterHotelDb;
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

-- Create the Room table
CREATE TABLE Room (
    RoomID VARCHAR(10) PRIMARY KEY,
    RoomType VARCHAR(50) NOT NULL,
    Price DECIMAL(10, 2) NOT NULL,
    Status VARCHAR(10) NOT NULL
);
GO

-- Insert data into Room
INSERT INTO Room (RoomID, RoomType, Price, Status) VALUES
('R01', 'Single', 100.00, 'Booked'),
('R02', 'Double', 200.00, 'Booked'),
('R03', 'Suite', 500.00, 'Booked'),
('R04', 'Deluxe', 300.00, 'Booked'),
('R05', 'Single', 100.00, 'Booked'),
('R06', 'Double', 200.00, 'Booked'),
('R07', 'Suite', 500.00, 'Booked'),
('R08', 'Deluxe', 300.00, 'Booked'),
('R09', 'Single', 100.00, 'Booked'),
('R10', 'Suite', 500.00, 'Booked');
GO

-- Create the GuestMaster table
CREATE TABLE GuestMaster (
    GuestID VARCHAR(10) PRIMARY KEY,
    GuestName VARCHAR(50) NOT NULL,
    RoomID VARCHAR(10),
    CheckInDate DATE NOT NULL,
    CheckOutDate DATE NOT NULL,
    StateID INT,
    FOREIGN KEY (RoomID) REFERENCES Room(RoomID),
    FOREIGN KEY (StateID) REFERENCES StateMaster(StateID)
);
GO

-- Insert data into GuestMaster
INSERT INTO GuestMaster (GuestID, GuestName, RoomID, CheckInDate, CheckOutDate, StateID) VALUES
('G01', 'John Doe', 'R01', '2024-08-01', '2024-08-05', 101),
('G02', 'Jane Smith', 'R02', '2024-08-02', '2024-08-07', 102),
('G03', 'Mike Johnson', 'R03', '2024-08-03', '2024-08-08', 103),
('G04', 'Sara Williams', 'R04', '2024-08-04', '2024-08-09', 104),
('G05', 'David Brown', 'R05', '2024-08-05', '2024-08-10', 105),
('G06', 'Emma Davis', 'R06', '2024-08-06', '2024-08-11', 106),
('G07', 'Frank Miller', 'R07', '2024-08-07', '2024-08-12', 107),
('G08', 'Grace Wilson', 'R08', '2024-08-08', '2024-08-13', 108),
('G09', 'Henry Moore', 'R09', '2024-08-09', '2024-08-14', 109),
('G10', 'Linda Taylor', 'R10', '2024-08-10', '2024-08-15', 110);
GO

-- Create the Booking table
CREATE TABLE Booking (
    BookingID VARCHAR(10) PRIMARY KEY,
    GuestID VARCHAR(10),
    RoomID VARCHAR(10),
    CheckInDate DATE NOT NULL,
    CheckOutDate DATE NOT NULL,
    TotalAmount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (GuestID) REFERENCES GuestMaster(GuestID),
    FOREIGN KEY (RoomID) REFERENCES Room(RoomID)
);
GO

-- Insert data into Booking
INSERT INTO Booking (BookingID, GuestID, RoomID, CheckInDate, CheckOutDate, TotalAmount) VALUES
('B01', 'G01', 'R01', '2024-08-01', '2024-08-05', 400.00),
('B02', 'G02', 'R02', '2024-08-02', '2024-08-07', 1000.00),
('B03', 'G03', 'R03', '2024-08-03', '2024-08-08', 2500.00),
('B04', 'G04', 'R04', '2024-08-04', '2024-08-09', 1500.00),
('B05', 'G05', 'R05', '2024-08-05', '2024-08-10', 500.00),
('B06', 'G06', 'R06', '2024-08-06', '2024-08-11', 1000.00),
('B07', 'G07', 'R07', '2024-08-07', '2024-08-12', 2500.00),
('B08', 'G08', 'R08', '2024-08-08', '2024-08-13', 1500.00),
('B09', 'G09', 'R09', '2024-08-09', '2024-08-14', 500.00),
('B10', 'G10', 'R10', '2024-08-10', '2024-08-15', 2500.00);
GO

-- Fetch Guests with the Same Check-In Date
SELECT GuestName, CheckInDate
FROM GuestMaster
WHERE CheckInDate IN (
    SELECT CheckInDate
    FROM GuestMaster
    GROUP BY CheckInDate
    HAVING COUNT(*) > 1
);
GO

-- Find the Guest with the Latest Check-Out Date
SELECT GuestName, CheckOutDate
FROM GuestMaster
WHERE CheckOutDate = (SELECT MAX(CheckOutDate) FROM GuestMaster);
GO

-- Get the Total Amount Paid by Each Guest
SELECT 
    G.GuestName, 
    SUM(B.TotalAmount) AS TotalPaid
FROM GuestMaster G
JOIN Booking B ON G.GuestID = B.GuestID
GROUP BY G.GuestName;
GO

-- Room-wise Count of Bookings Sorted by Count in Descending Order
SELECT 
    R.RoomID,
    R.RoomType,
    COUNT(B.BookingID) AS BookingCount
FROM Room R
LEFT JOIN Booking B ON R.RoomID = B.RoomID
GROUP BY R.RoomID, R.RoomType
ORDER BY BookingCount DESC;
GO

-- Fetch Only the First Name from the GuestName and Append the Check-In Date
SELECT 
    LEFT(GuestName, CHARINDEX(' ', GuestName) - 1) AS FirstName,
    CheckInDate
FROM GuestMaster;
GO

-- Fetch Guests Who Checked In on Even Days
SELECT GuestName, CheckInDate
FROM GuestMaster
WHERE DAY(CheckInDate) % 2 = 0;
GO

-- Create a View to Fetch Guest Details with a Check-Out Date After 8/10/2024
CREATE VIEW View_Guests_CheckOut_After_Aug10 AS
SELECT 
    G.GuestID, 
    G.GuestName, 
    G.CheckInDate, 
    G.CheckOutDate, 
    R.RoomType, 
    SM.StateName
FROM GuestMaster G
JOIN Room R ON G.RoomID = R.RoomID
JOIN StateMaster SM ON G.StateID = SM.StateID
WHERE G.CheckOutDate > '2024-08-10';
GO

-- Create a Procedure to Update the Room Status to 'Available' for Checked-Out Guests
CREATE PROCEDURE UpdateRoomStatusForCheckedOutGuests
AS
BEGIN
    UPDATE Room
    SET Status = 'Available'
    WHERE RoomID IN (
        SELECT RoomID
        FROM GuestMaster
        WHERE CheckOutDate < GETDATE()
    );
END;
GO

-- Create a Stored Procedure to Fetch Guest Details Along with Their Booking and State, Including Error Handling
CREATE PROCEDURE GetGuestDetails
AS
BEGIN
    BEGIN TRY
        SELECT 
            G.GuestID, 
            G.GuestName, 
            G.CheckInDate, 
            G.CheckOutDate, 
            R.RoomType, 
            SM.StateName
        FROM GuestMaster G
        JOIN Room R ON G.RoomID = R.RoomID
        JOIN StateMaster SM ON G.StateID = SM.StateID;
    END TRY
    BEGIN CATCH
        SELECT 
            ERROR_NUMBER() AS ErrorNumber, 
            ERROR_MESSAGE() AS ErrorMessage;
    END CATCH;
END;
GO

-- Fetch Guests Who Stayed for the Same Number of Days
SELECT G.GuestName, DATEDIFF(DAY, G.CheckInDate, G.CheckOutDate) AS StayDuration
FROM GuestMaster G
WHERE DATEDIFF(DAY, G.CheckInDate, G.CheckOutDate) IN (
    SELECT StayDuration
    FROM (
        SELECT DATEDIFF(DAY, CheckInDate, CheckOutDate) AS StayDuration
        FROM GuestMaster
        GROUP BY DATEDIFF(DAY, CheckInDate, CheckOutDate)
        HAVING COUNT(*) > 1
    ) AS StayDurations
);
GO

-- Find the Second Most Expensive Booking and the Guest Associated with It
WITH RankedBookings AS (
    SELECT B.BookingID, G.GuestName, B.TotalAmount,
           ROW_NUMBER() OVER (ORDER BY B.TotalAmount DESC) AS Rank
    FROM Booking B
    JOIN GuestMaster G ON B.GuestID = G.GuestID
)
SELECT BookingID, GuestName, TotalAmount
FROM RankedBookings
WHERE Rank = 2;
GO

-- Get the Maximum Room Price Per Room Type and the Guest Name
SELECT 
    R.RoomType, 
    MAX(R.Price) AS MaxPrice,
    G.GuestName
FROM Room R
JOIN Booking B ON R.RoomID = B.RoomID
JOIN GuestMaster G ON B.GuestID = G.GuestID
GROUP BY R.RoomType, G.GuestName
ORDER BY R.RoomType;
GO

-- Room Type-wise Count of Guests Sorted by Count in Descending Order
SELECT 
    R.RoomType,
    COUNT(G.GuestID) AS GuestCount
FROM Room R
LEFT JOIN Booking B ON R.RoomID = B.RoomID
LEFT JOIN GuestMaster G ON B.GuestID = G.GuestID
GROUP BY R.RoomType
ORDER BY GuestCount DESC;
GO

-- Fetch Only the First Name from the GuestName and Append the Total Amount Spent
SELECT 
    LEFT(G.GuestName, CHARINDEX(' ', G.GuestName) - 1) AS FirstName,
    SUM(B.TotalAmount) AS TotalAmountSpent
FROM GuestMaster G
JOIN Booking B ON G.GuestID = B.GuestID
GROUP BY G.GuestName;
GO

-- Fetch Bookings with Odd Total Amounts
SELECT B.BookingID, G.GuestName, B.TotalAmount
FROM Booking B
JOIN GuestMaster G ON B.GuestID = G.GuestID
WHERE B.TotalAmount % 2 = 1;
GO

-- Create a View to Fetch Bookings with a Total Amount Greater Than $1000
CREATE VIEW View_Bookings_Over_1000 AS
SELECT 
    B.BookingID, 
    G.GuestName, 
    B.CheckInDate, 
    B.CheckOutDate, 
    B.TotalAmount
FROM Booking B
JOIN GuestMaster G ON B.GuestID = G.GuestID
WHERE B.TotalAmount > 1000;
GO

-- Create a Procedure to Update the Room Prices by 10% Where the Room Type is 'Suite' and the State is Not 'Lagos'
CREATE PROCEDURE UpdateRoomPricesForSuites
AS
BEGIN
    UPDATE Room
    SET Price = Price * 1.10
    WHERE RoomType = 'Suite' 
    AND RoomID IN (
        SELECT RoomID
        FROM GuestMaster
        WHERE StateID <> 101 -- Assuming 101 is Lagos
    );
END;
GO

-- Create a Stored Procedure to Fetch Booking Details Along with the Guest, Room, and State, Including Error Handling
CREATE PROCEDURE GetBookingDetails
AS
BEGIN
    BEGIN TRY
        SELECT 
            B.BookingID, 
            G.GuestName, 
            R.RoomType, 
            SM.StateName, 
            B.CheckInDate, 
            B.CheckOutDate, 
            B.TotalAmount
        FROM Booking B
        JOIN GuestMaster G ON B.GuestID = G.GuestID
        JOIN Room R ON B.RoomID = R.RoomID
        JOIN StateMaster SM ON G.StateID = SM.StateID;
    END TRY
    BEGIN CATCH
        SELECT 
            ERROR_NUMBER() AS ErrorNumber, 
            ERROR_MESSAGE() AS ErrorMessage;
    END CATCH;
END;
GO

