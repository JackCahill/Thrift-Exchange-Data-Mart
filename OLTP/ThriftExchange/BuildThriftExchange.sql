-- Thrift Exchange database developed and written by Jack Cahill
-- Written April 20th, 2020 - Updated October 25th, 2020
-----------------------------------------------------------
-- Replace <data_path> with the full path to this file 
-- Ensure it ends with a backslash 
-- E.g., C:\MyDatabases\ See line 16
-----------------------------------------------------------
IF NOT EXISTS(SELECT * FROM sys.databases
	WHERE NAME = N'ThriftExchange')
	CREATE DATABASE ThriftExchange
GO
USE ThriftExchange

-- Alter the path so the script can find the CSV files 
DECLARE @data_path NVARCHAR(256);
SELECT @data_path = 'C:\Users\jackc\Desktop\Uni\INFO3300\ThriftExchange\';

-- Delete existing tables: 

---------------------------------
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'Accepted'
       )
	DROP TABLE Accepted;
---------------------------------
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'Donation'
       )
	DROP TABLE Donation;
---------------------------------
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'OrderLine'
       )
	DROP TABLE OrderLine;
---------------------------------
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'ClothesFabric'
       )
	DROP TABLE ClothesFabric;
---------------------------------
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'Clothing'
       )
	DROP TABLE Clothing;
---------------------------------
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'Order'
       )
	DROP TABLE [Order];
---------------------------------
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'Location'
       )
	DROP TABLE [Location];
---------------------------------
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'Donor'
       )
	DROP TABLE Donor;
---------------------------------
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'Fabric'
       )
	DROP TABLE Fabric;
---------------------------------
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'Customer'
       )
	DROP TABLE Customer;
---------------------------------
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'Employee'
       )
	DROP TABLE Employee;
---------------------------------
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'LocationCategory'
       )
	DROP TABLE LocationCategory;
---------------------------------
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'CustomerCategory'
       )
	DROP TABLE CustomerCategory;
---------------------------------
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'ClothingCategory'
       )
	DROP TABLE ClothingCategory;
---------------------------------
--
-- Create tables, 14 in total: 
--
CREATE TABLE LocationCategory (
	LocationCategoryID	INT CONSTRAINT pk_location_category PRIMARY KEY,
	LocationCategory	NVARCHAR(15) CONSTRAINT nn_location_category NOT NULL
);
--
CREATE TABLE [Location] (
	LocationID			INT CONSTRAINT	pk_location PRIMARY KEY,
	LocationCategoryID	INT CONSTRAINT	fk_location_category FOREIGN KEY REFERENCES LocationCategory(LocationCategoryID),
	LocationAddress		NVARCHAR(35) CONSTRAINT nn_location_address NOT NULL,
	LocationCity		NVARCHAR(20) CONSTRAINT nn_location_city NOT NULL,
	LocationState		NVARCHAR(25) CONSTRAINT nn_location_state NOT NULL,
	LocationZipcode		NVARCHAR(10) CONSTRAINT nn_location_zip NOT NULL
);
CREATE TABLE ClothingCategory (
	ClothingCategoryID	INT CONSTRAINT pk_clothing_category PRIMARY KEY,
	ClothingCategory	NVARCHAR(20) CONSTRAINT	nn_clothing_category NOT NULL
);
--
CREATE TABLE Clothing (
	ClothingID			INT CONSTRAINT pk_clothing PRIMARY KEY,
	ClothingCategoryID	INT CONSTRAINT fk_clothing_category FOREIGN KEY REFERENCES ClothingCategory(ClothingCategoryID),
	LocationID			INT CONSTRAINT fk_location_clothing FOREIGN KEY REFERENCES [Location](LocationID),
	ClothingPrice		MONEY CONSTRAINT nn_selling_price NOT NULL CONSTRAINT ck_not_negatvie CHECK (ClothingPrice >= 0),
	ClothingType		NVARCHAR(15) CONSTRAINT nn_clothing_type NOT NULL,
	ClothingDescription	NVARCHAR(50) CONSTRAINT nn_description NOT NULL,
	ClothingBrand		NVARCHAR(15) CONSTRAINT nn_brand NOT NULL,
	ClothingSize		NVARCHAR(5) CONSTRAINT nn_size NOT NULL,
	ClothingColor		NVARCHAR(10) CONSTRAINT nn_color NOT NULL,
	ClothingGender		NVARCHAR(6) CONSTRAINT nn_gender NOT NULL CONSTRAINT ck_gender CHECK ((ClothingGender = 'Female') OR (ClothingGender = 'Male') OR (ClothingGender = 'Unisex')),
	ClothingCondition	NVARCHAR(5) CONSTRAINT nn_condition NOT NULL CONSTRAINT ck_category CHECK ((ClothingCondition = 'Great') OR (ClothingCondition = 'Good') OR (ClothingCondition = 'Fair') OR (ClothingCondition = 'Poor'))
);
--
CREATE TABLE Employee (
	EmployeeID			NVARCHAR(11) CONSTRAINT pk_employee PRIMARY KEY, 
	EmployeeLName		NVARCHAR(25) CONSTRAINT nn_employee_first_name NOT NULL,		
	EmployeeFName		NVARCHAR(15) CONSTRAINT nn_employee_last_name NOT NULL,
	EmployeeDOB			DATE CONSTRAINT nn_employee_DOB NOT NULL CONSTRAINT ch_proper_date CHECK (EmployeeDOB <= getDate()), 
	EmployeeEmail		NVARCHAR(35) CONSTRAINT nn_employee_email NOT NULL,
	EmployeePhone		NVARCHAR(20) CONSTRAINT nn_employee_phone NOT NULL,
	EmployeePosition	NVARCHAR(15) CONSTRAINT nn_position NOT NULL
);
--
CREATE TABLE CustomerCategory (
	CustomerCategoryID	INT CONSTRAINT pk_customer_category PRIMARY KEY,
	CustomerCategory	NVARCHAR(20) CONSTRAINT	nn_customer_category NOT NULL
);
--
CREATE TABLE Customer (
	CustomerID			INT CONSTRAINT pk_customer PRIMARY KEY,
	CustomerCategoryID	INT CONSTRAINT fk_customer_category FOREIGN KEY REFERENCES CustomerCategory(CustomerCategoryID),
	CustomerFName		NVARCHAR(15) CONSTRAINT nn_customer_first_name NOT NULL,
	CustomerLName		NVARCHAR(20) CONSTRAINT nn_customer_last_name NOT NULL,
	CustomerAddress		NVARCHAR(35) CONSTRAINT nn_customer_address NOT NULL,
	CustomerCity		NVARCHAR(20) CONSTRAINT nn_customer_city NOT NULL,
	CustomerState		NVARCHAR(25)  CONSTRAINT nn_customer_state NOT NULL,	
	CustomerZipcode		NVARCHAR(10) CONSTRAINT nn_customer_zip_code NOT NULL,
	CustomerDOB			DATE CONSTRAINT nn_customer_dob NOT NULL,
	CustomerPhone		NVARCHAR(14) CONSTRAINT nn_customer_phone NOT NULL,
	CustomerEmail		NVARCHAR(40) CONSTRAINT nn_customer_email NOT NULL,
	CustomerGender		NVARCHAR(10) CONSTRAINT nn_customer_gender NOT NULL
);
--
CREATE TABLE Donor (
	DonorID				INT CONSTRAINT pk_donor PRIMARY KEY,
	DonorFName			NVARCHAR(15) CONSTRAINT nn_donor_first_name NOT NULL,
	DonorLName			NVARCHAR(20) CONSTRAINT nn_donor_last_name NOT NULL,
	DonorEmail			NVARCHAR(45) CONSTRAINT nn_donor_email NOT NULL
);
--
CREATE TABLE [Order] (
	OrderID				INT CONSTRAINT pk_order PRIMARY KEY,
	CustomerID			INT CONSTRAINT fk_customer FOREIGN KEY REFERENCES Customer(CustomerID),
	LocationID			INT CONSTRAINT	fk_location_order FOREIGN KEY REFERENCES [Location](LocationID),
	SaleDate			DATE CONSTRAINT nn_sale_date NOT NULL
);
--
CREATE TABLE Fabric (
	FabricID			INT CONSTRAINT pk_fabric PRIMARY KEY,
	FabricType			NVARCHAR(15) CONSTRAINT nn_fabric_type NOT NULL,
	FabricWeight		DECIMAL(6,2) CONSTRAINT nn_weight NOT NULL,
	FabricStitchType	NVARCHAR(20) CONSTRAINT nn_stitch_type NOT NULL,
	FabricNumLayers		SMALLINT CONSTRAINT nn_num_layers NOT NULL,
	FabricNumThreads	SMALLINT CONSTRAINT nn_num_threads NOT NULL,
	FabricThickness		DECIMAL(5,5) CONSTRAINT nn_thickness NOT NULL
);
--
-- Moving on to Associative Entities
--
CREATE TABLE Accepted (
	CONSTRAINT			pk_accepted PRIMARY KEY (ClothingID, EmployeeID),
	ClothingID			INT CONSTRAINT fk_clothing_accepted FOREIGN KEY REFERENCES Clothing(ClothingID),
	EmployeeID			NVARCHAR(11) CONSTRAINT fk__employee_accepted FOREIGN KEY REFERENCES Employee(EmployeeID),
	DayAccepted			DATE CONSTRAINT nn_day_accepted NOT NULL,
	BuyingPrice			MONEY CONSTRAINT nn_buying_price_accpeted NOT NULL CONSTRAINT ck_not_negative_buying_price CHECK(BuyingPrice >= 0)
);
--
CREATE TABLE Donation (
	CONSTRAINT			pk_donation PRIMARY KEY (DonorID, ClothingID),
	DonorID				INT CONSTRAINT fk_donor_donation FOREIGN KEY REFERENCES Donor(DonorID),
	ClothingID			INT CONSTRAINT fk_clothing_donation FOREIGN KEY REFERENCES Clothing(ClothingID),
	DonationaDate		DATE CONSTRAINT nn_donation_day NOT NULL,
	DonationReason		NVARCHAR(50) CONSTRAINT nn_donation_reason NOT NULL
);
--
CREATE TABLE Orderline (
	CONSTRAINT			pk_order_line PRIMARY KEY (OrderID, ClothingID),
	OrderID				INT CONSTRAINT fk_order_orderline FOREIGN KEY REFERENCES [Order](OrderID),
	ClothingID			INT CONSTRAINT fk_clothing_orderline FOREIGN KEY REFERENCES Clothing(ClothingID),
	OrderDiscount		NUMERIC(4,4) CONSTRAINT nn_order_discount NOT NULL CONSTRAINT ck_between_one_and_zero CHECK((OrderDiscount >= 0) AND (OrderDiscount <= 1))
);
--
CREATE TABLE ClothesFabric (
	CONSTRAINT			pk_clothes_fabric PRIMARY KEY (ClothingID, FabricID),
	ClothingID			INT CONSTRAINT fk_clothing_clothes_fabric FOREIGN KEY REFERENCES Clothing(ClothingID),
	FabricID			INT CONSTRAINT fk_fabric_clothes_fabric FOREIGN KEY REFERENCES Fabric(FabricID),
	MultipleFabrics		BIT CONSTRAINT nn_mutltipe_fabrics NOT NULL
);
--
-- Load table data
--
--Load in LocationCategory Data
EXECUTE (N'BULK INSERT LocationCategory FROM ''' + @data_path + N'LocationCategory.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	KEEPIDENTITY,
	FIRSTROW = 2,
	TABLOCK
	);
');
--Load in Location Data
EXECUTE (N'BULK INSERT Location FROM ''' + @data_path + N'Location.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	KEEPIDENTITY,
	FIRSTROW = 2,
	TABLOCK
	);
');
-- Loads ClothingCategory Data
EXECUTE (N'BULK INSERT ClothingCategory FROM ''' + @data_path + N'ClothingCategory.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	KEEPIDENTITY,
	FIRSTROW = 2,
	TABLOCK
	);
');
-- Loads Clothing Data
EXECUTE (N'BULK INSERT Clothing FROM ''' + @data_path + N'Clothing.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	KEEPIDENTITY,
	FIRSTROW = 2,
	TABLOCK
	);
');
-- Loads Employee Data
EXECUTE (N'BULK INSERT Employee FROM ''' + @data_path + N'Employee.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	KEEPIDENTITY,
	FIRSTROW = 2,
	TABLOCK
	);
');
-- Loads CustomerCategory Data
EXECUTE (N'BULK INSERT CustomerCategory FROM ''' + @data_path + N'CustomerCategory.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	KEEPIDENTITY,
	FIRSTROW = 2,
	TABLOCK
	);
');
-- Loads Customer Data
EXECUTE (N'BULK INSERT Customer FROM ''' + @data_path + N'Customer.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	KEEPIDENTITY,
	FIRSTROW = 2,
	TABLOCK
	);
');
-- Loads Donor Data
EXECUTE (N'BULK INSERT Donor FROM ''' + @data_path + N'Donor.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	KEEPIDENTITY,
	FIRSTROW = 2,
	TABLOCK
	);
');
-- Loads Order Data
EXECUTE (N'BULK INSERT [Order] FROM ''' + @data_path + N'Order.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	KEEPIDENTITY,
	FIRSTROW = 2,
	TABLOCK
	);
');
-- Loads Fabric Data
EXECUTE (N'BULK INSERT Fabric FROM ''' + @data_path + N'Fabric.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	KEEPIDENTITY,
	FIRSTROW = 2,
	TABLOCK
	);
');
-- Loads Accepted Data
EXECUTE (N'BULK INSERT Accepted FROM ''' + @data_path + N'Accepted.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	KEEPIDENTITY,
	FIRSTROW = 2,
	TABLOCK
	);
');
-- Loads Donation Data
EXECUTE (N'BULK INSERT Donation FROM ''' + @data_path + N'Donation.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	KEEPIDENTITY,
	FIRSTROW = 2,
	TABLOCK
	);
');
-- Loads Orderline Data
EXECUTE (N'BULK INSERT OrderLine FROM ''' + @data_path + N'OrderLine.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	KEEPIDENTITY,
	FIRSTROW = 2,
	TABLOCK
	);
');
-- Loads ClothesFabric Data
EXECUTE (N'BULK INSERT ClothesFabric FROM ''' + @data_path + N'ClothesFabric.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	KEEPIDENTITY,
	FIRSTROW = 2,
	TABLOCK
	);
');

--
--
-- List table names and row counts for confirmation
--
GO
SET NOCOUNT ON
SELECT 'Clothing' AS "Table",	COUNT(*) AS "Rows"	FROM Clothing			UNION
SELECT 'ClothingCategory',		COUNT(*)			FROM ClothingCategory   UNION
SELECT 'Employee',				COUNT(*)			FROM Employee			UNION
SELECT 'Customer',				COUNT(*)			FROM Customer			UNION
SELECT 'CustomerCategory',		COUNT(*)			FROM CustomerCategory	UNION
SELECT 'Donor',					COUNT(*)			FROM Donor				UNION
SELECT 'Fabric',				COUNT(*)			FROM Fabric				UNION
SELECT 'Order',					COUNT(*)			FROM [Order]			UNION
SELECT 'Accepted',				COUNT(*)			FROM Accepted			UNION
SELECT 'Donation',				COUNT(*)			FROM Donation			UNION
SELECT 'OrderLine',				COUNT(*)			FROM OrderLine			UNION
SELECT 'ClothesFabric',			COUNT(*)			FROM ClothesFabric		UNION
SELECT 'Location',				COUNT(*)			FROM [Location]			UNION
SELECT 'LocationCategory',		COUNT(*)			FROM LocationCategory 
ORDER BY 1;
SET NOCOUNT OFF
GO
