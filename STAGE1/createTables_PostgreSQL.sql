-- Airport Commercial Hub - Department 7
-- PostgreSQL 19 / pgAdmin 4
-- Run in Query Tool connected to AirportCommercialDB.
-- Does not delete existing tables or data.
-- Flight_ID_FK and Gate_Id_FK are external references without FK constraints for now.

BEGIN;

CREATE TABLE IF NOT EXISTS ProductCategories (
    Category_ID INTEGER PRIMARY KEY,
    CategoryName VARCHAR(100) NOT NULL,
    Description TEXT,
    CONSTRAINT chk_category_name CHECK (length(btrim(CategoryName)) > 0)
);

CREATE TABLE IF NOT EXISTS Stores (
    Store_ID INTEGER PRIMARY KEY,
    StoreName VARCHAR(100) NOT NULL,
    StoreType VARCHAR(50) NOT NULL,
    Terminal VARCHAR(20) NOT NULL,
    Gate_Id_FK INTEGER NOT NULL,
    Opening_Date DATE NOT NULL,
    Is_Active BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT chk_store_name CHECK (length(btrim(StoreName)) > 0)
);

CREATE TABLE IF NOT EXISTS Products (
    Product_Id INTEGER PRIMARY KEY,
    Product_Name VARCHAR(100) NOT NULL,
    BarCode VARCHAR(50) UNIQUE,
    Unit_Cost NUMERIC(10,2) NOT NULL CHECK (Unit_Cost >= 0),
    IsActive BOOLEAN NOT NULL DEFAULT TRUE,
    Category_ID INTEGER NOT NULL REFERENCES ProductCategories(Category_ID)
);

CREATE TABLE IF NOT EXISTS Customers (
    Customer_ID INTEGER PRIMARY KEY,
    IdentityNumber VARCHAR(30),
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    CustomerType VARCHAR(40) NOT NULL,
    Email VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS StoreProducts (
    StoreProduct_ID INTEGER PRIMARY KEY,
    SellingPrice NUMERIC(10,2) NOT NULL CHECK (SellingPrice >= 0),
    StockQuantity INTEGER NOT NULL CHECK (StockQuantity >= 0),
    ReorderLevel INTEGER NOT NULL CHECK (ReorderLevel >= 0),
    LastRestockDate DATE NOT NULL,
    Store_ID INTEGER NOT NULL REFERENCES Stores(Store_ID),
    Product_Id INTEGER NOT NULL REFERENCES Products(Product_Id),
    CONSTRAINT uq_store_product UNIQUE (Store_ID, Product_Id)
);

CREATE TABLE IF NOT EXISTS Sales (
    Sale_ID INTEGER PRIMARY KEY,
    SaleDateTime TIMESTAMP NOT NULL,
    PaymentMethod VARCHAR(30) NOT NULL,
    SaleStatus VARCHAR(30) NOT NULL,
    Flight_ID_FK INTEGER NOT NULL,
    Customer_ID INTEGER NOT NULL REFERENCES Customers(Customer_ID),
    Store_ID INTEGER NOT NULL REFERENCES Stores(Store_ID),
    CONSTRAINT uq_sale_store UNIQUE (Sale_ID, Store_ID)
);

CREATE TABLE IF NOT EXISTS SaleItems (
    LineNumber INTEGER NOT NULL,
    Sale_ID INTEGER NOT NULL REFERENCES Sales(Sale_ID),
    Quantity INTEGER NOT NULL CHECK (Quantity > 0),
    UnitPriceAtSale NUMERIC(10,2) NOT NULL CHECK (UnitPriceAtSale >= 0),
    StoreProduct_ID INTEGER NOT NULL REFERENCES StoreProducts(StoreProduct_ID),
    PRIMARY KEY (Sale_ID, LineNumber)
);

COMMIT;

-- Confirm that the seven tables exist:
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
ORDER BY table_name;
