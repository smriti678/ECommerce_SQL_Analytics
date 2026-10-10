/* 
E-commerce analysis project
Looking at sales trends, locations, and wallet preferences
*/

-- basic schema cleanup
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Users;

-- setting up main database tables
CREATE TABLE Users (
    User_ID INT PRIMARY KEY,
    Name VARCHAR(100),
    City VARCHAR(50),
    Join_Date DATE
);

CREATE TABLE Products (
    Product_ID INT PRIMARY KEY,
    Product_Name VARCHAR(100),
    Category VARCHAR(50),
    Price DECIMAL(10, 2)
);

CREATE TABLE Orders (
    Order_ID INT PRIMARY KEY,
    User_ID INT,
    Product_ID INT,
    Order_Date DATE,
    Quantity INT,
    Payment_Method VARCHAR(50),
    FOREIGN KEY (User_ID) REFERENCES Users(User_ID),
    FOREIGN KEY (Product_ID) REFERENCES Products(Product_ID)
);

-- adding sample records for testing queries
INSERT INTO Users VALUES 
(1, 'Aayush Shrestha', 'Kathmandu', '2026-01-15'),
(2, 'Sita Thapa', 'Pokhara', '2026-02-10'),
(3, 'Rohan Adhikari', 'Lalitpur', '2026-03-01'),
(4, 'Pooja Singh', 'Kathmandu', '2026-03-15'),
(5, 'Niranjan Joshi', 'Bhaktapur', '2026-04-20');

INSERT INTO Products VALUES 
(101, 'Wireless Earbuds', 'Electronics', 3500.00),
(102, 'Mechanical Keyboard', 'Electronics', 5500.00),
(103, 'Running Shoes', 'Apparel', 4200.00),
(104, 'Oversized Hoodie', 'Apparel', 2500.00),
(105, 'Water Bottle 1L', 'Home & Living', 1200.00);

INSERT INTO Orders VALUES 
(1001, 1, 101, '2026-08-01', 1, 'Digital Wallet'),
(1002, 2, 103, '2026-08-05', 1, 'Cash on Delivery'),
(1003, 1, 104, '2026-08-10', 2, 'Digital Wallet'),
(1004, 3, 102, '2026-08-12', 1, 'Digital Wallet'),
(1005, 4, 101, '2026-08-15', 1, 'Cash on Delivery'),
(1006, 1, 105, '2026-09-01', 3, 'Digital Wallet'),
(1007, 5, 104, '2026-09-05', 1, 'Cash on Delivery'),
(1008, 4, 102, '2026-09-10', 1, 'Digital Wallet'),
(1009, 2, 105, '2026-09-15', 2, 'Cash on Delivery'),
(1010, 1, 102, '2026-10-01', 1, 'Digital Wallet');


-- 1. category revenue analysis
SELECT 
    p.Category,
    SUM(o.Quantity * p.Price) AS Total_Revenue,
    SUM(o.Quantity) AS Total_Items_Sold
FROM Orders o
JOIN Products p ON o.Product_ID = p.Product_ID
GROUP BY p.Category
ORDER BY Total_Revenue DESC;

-- 2. average spending by city
SELECT 
    u.City,
    ROUND(AVG(o.Quantity * p.Price), 2) AS Average_Order_Value,
    COUNT(o.Order_ID) AS Total_Orders
FROM Orders o
JOIN Users u ON o.User_ID = u.User_ID
JOIN Products p ON o.Product_ID = p.Product_ID
GROUP BY u.City
ORDER BY Average_Order_Value DESC;

-- 3. digital wallet vs cod split percentages
SELECT 
    Payment_Method,
    COUNT(Order_ID) AS Total_Transactions,
    ROUND(COUNT(Order_ID) * 100.0 / (SELECT COUNT(*) FROM Orders), 2) AS Percentage
FROM Orders
GROUP BY Payment_Method;

-- 4. loyal users check (ordered 2 or more times)
SELECT 
    u.Name,
    u.City,
    COUNT(o.Order_ID) AS Total_Orders_Placed
FROM Orders o
JOIN Users u ON o.User_ID = u.User_ID
GROUP BY u.Name, u.City
HAVING COUNT(o.Order_ID) >= 2
ORDER BY Total_Orders_Placed DESC;

-- 5. ranking most popular items in each category
SELECT 
    Category,
    Product_Name,
    Total_Sold,
    DENSE_RANK() OVER (PARTITION BY Category ORDER BY Total_Sold DESC) AS Product_Rank
FROM (
    SELECT 
        p.Category,
        p.Product_Name,
        SUM(o.Quantity) AS Total_Sold
    FROM Orders o
    JOIN Products p ON o.Product_ID = p.Product_ID
    GROUP BY p.Category, p.Product_Name
) Subquery;
