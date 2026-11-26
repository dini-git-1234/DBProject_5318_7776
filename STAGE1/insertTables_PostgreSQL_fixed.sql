-- Airport Commerce Hub | Department 7
-- PostgreSQL 19 | Initial sample data (manual INSERT method)
-- Run AFTER createTables_PostgreSQL.sql, connected to AirportCommercialDB.
-- This is a small test dataset, NOT the final large dataset. Existing primary keys are skipped.
-- Connect to AirportCommercialDB in pgAdmin before running.

BEGIN;

INSERT INTO ProductCategories (Category_ID, CategoryName, Description) VALUES
(1, 'Perfumes', 'Fragrances'),
(2, 'Electronics', 'Travel electronics'),
(3, 'Snacks', 'Packaged snacks'),
(4, 'Travel Accessories', 'Travel essentials'),
(5, 'Books', 'Books and magazines') ON CONFLICT DO NOTHING;

INSERT INTO Stores (Store_ID, StoreName, StoreType, Terminal, Gate_Id_FK, Opening_Date, Is_Active) VALUES
(1, 'Sky Duty Free', 'Duty Free', 'T1', 101, '2020-03-15', TRUE),
(2, 'Gate Tech', 'Electronics', 'T1', 102, '2021-06-01', TRUE),
(3, 'Quick Bites', 'Food', 'T2', 201, '2019-09-10', TRUE),
(4, 'Travel Corner', 'Accessories', 'T2', 202, '2022-01-20', TRUE),
(5, 'Airport Books', 'Bookstore', 'T3', 301, '2018-11-05', TRUE) ON CONFLICT DO NOTHING;

INSERT INTO Products (Product_Id, Product_Name, BarCode, Unit_Cost, IsActive, Category_ID) VALUES
(1, 'Travel Perfume 50ml', '7290000000001', 35.00, TRUE, 1),
(2, 'USB-C Charger', '7290000000002', 12.00, TRUE, 2),
(3, 'Chocolate Bar', '7290000000003', 2.50, TRUE, 3),
(4, 'Neck Pillow', '7290000000004', 8.00, TRUE, 4),
(5, 'Travel Guide', '7290000000005', 10.00, TRUE, 5) ON CONFLICT DO NOTHING;

INSERT INTO Customers (Customer_ID, IdentityNumber, FirstName, LastName, CustomerType, Email) VALUES
(1, 'P100001', 'Daniel', 'Levi', 'Passenger', 'daniel.levi@example.com'),
(2, 'P100002', 'Maya', 'Cohen', 'Passenger', 'maya.cohen@example.com'),
(3, 'C100003', 'Noam', 'Shapiro', 'Pilot', NULL),
(4, 'C100004', 'Yael', 'Barak', 'Flight Attendant', 'yael.barak@example.com'),
(5, NULL, 'Avi', 'Rosen', 'Passenger', NULL) ON CONFLICT DO NOTHING;

INSERT INTO StoreProducts (StoreProduct_ID, SellingPrice, StockQuantity, ReorderLevel, LastRestockDate, Store_ID, Product_Id) VALUES
(1, 59.90, 80, 15, '2026-11-01', 1, 1),
(2, 24.90, 65, 10, '2026-11-02', 2, 2),
(3, 5.90, 200, 40, '2026-11-03', 3, 3),
(4, 19.90, 55, 12, '2026-11-04', 4, 4),
(5, 22.00, 45, 10, '2026-11-05', 5, 5) ON CONFLICT DO NOTHING;

-- Flight_ID_FK values are placeholders until integration with Flight Operations.
INSERT INTO Sales (Sale_ID, SaleDateTime, PaymentMethod, SaleStatus, Flight_ID_FK, Customer_ID, Store_ID) VALUES
(1, '2026-11-06 09:15:00', 'Credit Card', 'Completed', 1001, 1, 1),
(2, '2026-11-06 10:20:00', 'Cash', 'Completed', 1002, 2, 2),
(3, '2026-11-07 11:05:00', 'Debit Card', 'Completed', 1003, 3, 3),
(4, '2026-11-07 12:40:00', 'Mobile Payment', 'Completed', 1004, 4, 4),
(5, '2026-11-08 14:30:00', 'Credit Card', 'Completed', 1005, 5, 5) ON CONFLICT DO NOTHING;

INSERT INTO SaleItems (Sale_ID, LineNumber, Quantity, UnitPriceAtSale, StoreProduct_ID) VALUES
(1, 1, 1, 59.90, 1),
(2, 1, 2, 24.90, 2),
(3, 1, 3, 5.90, 3),
(4, 1, 1, 19.90, 4),
(5, 1, 1, 22.00, 5) ON CONFLICT DO NOTHING;

COMMIT;

-- Verify row counts:
SELECT 'ProductCategories' AS TableName, COUNT(*) AS RowCount FROM ProductCategories
UNION ALL SELECT 'Stores', COUNT(*) FROM Stores
UNION ALL SELECT 'Products', COUNT(*) FROM Products
UNION ALL SELECT 'Customers', COUNT(*) FROM Customers
UNION ALL SELECT 'StoreProducts', COUNT(*) FROM StoreProducts
UNION ALL SELECT 'Sales', COUNT(*) FROM Sales
UNION ALL SELECT 'SaleItems', COUNT(*) FROM SaleItems;
