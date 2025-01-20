-- 1. Create Database
CREATE DATABASE RetailInventoryDb;
GO

-- 2. Use the created Database
USE RetailInventoryDb;
GO

-- 3. Create Product Table
CREATE TABLE Product (
    ProductID VARCHAR(10) PRIMARY KEY,
    ProductName VARCHAR(100),
    CategoryID INT,
    Price DECIMAL(10, 2),
    Quantity INT,
    SupplierID INT
);
GO

-- 4. Insert Sample Data into Product Table
INSERT INTO Product (ProductID, ProductName, CategoryID, Price, Quantity, SupplierID) VALUES
('P01', 'Laptop', 1, 1200.00, 50, 101),
('P02', 'Smartphone', 1, 800.00, 100, 102),
('P03', 'TV', 2, 1500.00, 30, 103),
('P04', 'Refrigerator', 2, 900.00, 25, 104),
('P05', 'Microwave', 3, 200.00, 60, 105),
('P06', 'Washing Machine', 2, 1100.00, 20, 106),
('P07', 'Headphones', 4, 100.00, 200, 107),
('P08', 'Camera', 1, 700.00, 15, 108),
('P09', 'Air Conditioner', 2, 1300.00, 10, 109),
('P10', 'Blender', 3, 150.00, 80, 110);
GO

-- 5. Create Category Table
CREATE TABLE Category (
    CategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(50)
);
GO

-- 6. Insert Sample Data into Category Table
INSERT INTO Category (CategoryID, CategoryName) VALUES
(1, 'Electronics'),
(2, 'Appliances'),
(3, 'Kitchenware'),
(4, 'Accessories');
GO

-- 7. Create Supplier Table
CREATE TABLE Supplier (
    SupplierID INT PRIMARY KEY,
    SupplierName VARCHAR(100),
    ContactNumber VARCHAR(15)
);
GO

-- 8. Insert Sample Data into Supplier Table
INSERT INTO Supplier (SupplierID, SupplierName, ContactNumber) VALUES
(101, 'SupplierA', '123-456-7890'),
(102, 'SupplierB', '234-567-8901'),
(103, 'SupplierC', '345-678-9012'),
(104, 'SupplierD', '456-789-0123'),
(105, 'SupplierE', '567-890-1234'),
(106, 'SupplierF', '678-901-2345'),
(107, 'SupplierG', '789-012-3456'),
(108, 'SupplierH', '890-123-4567'),
(109, 'SupplierI', '901-234-5678'),
(110, 'SupplierJ', '012-345-6789');
GO

-- 9. Create Warehouse Table
CREATE TABLE Warehouse (
    WarehouseID VARCHAR(10) PRIMARY KEY,
    WarehouseName VARCHAR(100),
    Location VARCHAR(100)
);
GO

-- 10. Insert Sample Data into Warehouse Table
INSERT INTO Warehouse (WarehouseID, WarehouseName, Location) VALUES
('W01', 'MainWarehouse', 'New York'),
('W02', 'EastWarehouse', 'Boston'),
('W03', 'WestWarehouse', 'San Diego'),
('W04', 'NorthWarehouse', 'Chicago'),
('W05', 'SouthWarehouse', 'Miami'),
('W06', 'CentralWarehouse', 'Dallas'),
('W07', 'PacificWarehouse', 'San Francisco'),
('W08', 'MountainWarehouse', 'Denver'),
('W09', 'SouthernWarehouse', 'Atlanta'),
('W10', 'GulfWarehouse', 'Houston');
GO

-- Fetch products with the same price.
SELECT ProductName, Price
FROM Product
WHERE Price IN (
    SELECT Price
    FROM Product
    GROUP BY Price
    HAVING COUNT(*) > 1
);
GO

-- Find the second highest priced product and its category.
SELECT ProductName, Price, c.CategoryName
FROM Product p
JOIN Category c ON p.CategoryID = c.CategoryID
WHERE Price = (
    SELECT DISTINCT Price
    FROM Product
    ORDER BY Price DESC
    OFFSET 1 ROW FETCH NEXT 1 ROW ONLY
);
GO

-- Get the maximum price per category and the product name.
SELECT c.CategoryName, p.ProductName, p.Price
FROM Product p
JOIN Category c ON p.CategoryID = c.CategoryID
WHERE p.Price IN (
    SELECT MAX(Price)
    FROM Product
    GROUP BY CategoryID
);
GO

-- Supplier-wise count of products sorted by count in descending order.
SELECT s.SupplierName, COUNT(p.ProductID) AS ProductCount
FROM Supplier s
LEFT JOIN Product p ON s.SupplierID = p.SupplierID
GROUP BY s.SupplierName
ORDER BY ProductCount DESC;
GO

-- Fetch only the first word from the ProductName and append the price.
SELECT CONCAT(SUBSTRING(ProductName, 1, CHARINDEX(' ', ProductName + ' ') - 1), '_', Price) AS ProductPriceInfo
FROM Product;
GO

-- Fetch products with odd prices.
SELECT *
FROM Product
WHERE Price % 2 = 1;
GO

-- Create a view to fetch products with a price greater than $500.
CREATE VIEW ProductsOver500 AS
SELECT ProductID, ProductName, Price
FROM Product
WHERE Price > 500;
GO

-- Create a procedure to update product prices by 15% where the category is 'Electronics' and the supplier is not 'SupplierA'.
CREATE PROCEDURE UpdateElectronicsPrices
AS
BEGIN
    UPDATE Product
    SET Price = Price * 1.15
    WHERE CategoryID = (SELECT CategoryID FROM Category WHERE CategoryName = 'Electronics')
      AND SupplierID <> (SELECT SupplierID FROM Supplier WHERE SupplierName = 'SupplierA');
END;
GO

-- Create a stored procedure to fetch product details along with their category, supplier, and warehouse location, including error handling.
CREATE PROCEDURE FetchProductDetails
AS
BEGIN
    BEGIN TRY
        SELECT 
            p.ProductID,
            p.ProductName,
            p.Price,
            c.CategoryName,
            s.SupplierName,
            w.WarehouseName,
            w.Location
        FROM Product p
        JOIN Category c ON p.CategoryID = c.CategoryID
        JOIN Supplier s ON p.SupplierID = s.SupplierID
        JOIN Warehouse w ON p.SupplierID = w.WarehouseID;  -- Assuming a relationship; adjust as needed
    END TRY
    BEGIN CATCH
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage;
    END CATCH;
END;
GO
