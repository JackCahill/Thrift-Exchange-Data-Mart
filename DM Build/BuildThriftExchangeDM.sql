--ThriftExchangeDM 2020
--Written by Jack Cahill
--Written for INFO3300
--Written October 10th, 2020 | Modified October 26th, 2020

--Creates the DM if it does not exist
IF NOT EXISTS (SELECT * FROM sys.databases
  WHERE NAME = N'ThriftExchangeDM')
  CREATE DATABASE ThriftExchangeDM
GO
--
USE ThriftExchangeDM
GO
--
--Drops the tables if they do exist (Fact Table First)
IF EXISTS (
  SELECT *
  FROM sys.tables
  WHERE NAME = N'FactSale'
  )
  DROP TABLE FactSale;
--
IF EXISTS (
  SELECT *
  FROM sys.tables
  WHERE NAME = N'DimLocation'
  )
  DROP TABLE DimLocation;
--
IF EXISTS (
  SELECT *
  FROM sys.tables
  WHERE NAME = N'DimCustomer'
  )
  DROP TABLE DimCustomer;
--
IF EXISTS (
  SELECT *
  FROM sys.tables
  WHERE NAME = N'DimClothing'
  )
  DROP TABLE DimClothing;
--
IF EXISTS (
  SELECT *
  FROM sys.tables
  WHERE NAME = N'DimDate'
  )
  DROP TABLE DimDate;
--
--Creates or recreates the dimension tables with appropriate constraints
--Everything must be NOT NULL except for DimDate
--
--DimDate was written by Amy Phillips
CREATE TABLE DimDate (
	DateSK			    INT CONSTRAINT pk_date_sk PRIMARY KEY,
	Date			    DATE,
	FullDate		    NCHAR(10),-- Date in MM-dd-yyyy format
	DayOfMonth			INT, -- Field will hold day number of Month
	DayName				NVARCHAR(9), -- Contains name of the day, Sunday, Monday
	DayOfWeek			INT,-- First Day Sunday=1 and Saturday=7
	DayOfWeekInMonth	INT, -- 1st Monday or 2nd Monday in Month
	DayOfWeekInYear		INT,
	DayOfQuarter		INT,
	DayOfYear			INT,
	WeekOfMonth			INT,-- Week Number of Month
	WeekOfQuarter		INT, -- Week Number of the Quarter
	WeekOfYear			INT,-- Week Number of the Year
	Month				INT, -- Number of the Month 1 to 12{}
	MonthName			NVARCHAR(9),-- January, February etc
	MonthOfQuarter		INT,-- Month Number belongs to Quarter
	Quarter				NCHAR(2),
	QuarterName			NVARCHAR(9),-- First,Second..
	Year				INT,-- Year value of Date stored in Row
	YearName			CHAR(7), -- CY 2017,CY 2018
	MonthYear			CHAR(10), -- Jan-2018,Feb-2018
	MMYYYY				INT,
	FirstDayOfMonth		DATE,
	LastDayOfMonth		DATE,
	FirstDayOfQuarter	DATE,
	LastDayOfQuarter	DATE,
	FirstDayOfYear		DATE,
	LastDayOfYear		DATE,
	IsHoliday			BIT,-- Flag 1=National Holiday, 0-No National Holiday
	IsWeekday			BIT,-- 0=Week End ,1=Week Day
	Holiday				NVARCHAR(50),-- Name of Holiday in US
	Season				NVARCHAR(10)-- Name of Season
);
--
CREATE TABLE DimClothing (
  ClothingSK        INT IDENTITY(1,1) NOT NULL CONSTRAINT pk_clothing_sk PRIMARY KEY,
  ClothingAK        INT NOT NULL,
  ClothingType      NVARCHAR(15) NOT NULL,
  ClothingBrand     NVARCHAR(15) NOT NULL,
  ClothingSize      NVARCHAR(5) NOT NULL,
  ClothingColor     NVARCHAR(10) NOT NULL,
  ClothingGender    NVARCHAR(6) NOT NULL,
  ClothingCondition NVARCHAR(5) NOT NULL,
  ClothingCategory  NVARCHAR(20) NOT NULL
);
--
CREATE TABLE DimCustomer (
  CustomerSK        INT IDENTITY(1,1) NOT NULL CONSTRAINT pk_customer_sk PRIMARY KEY,
  CustomerAK        INT NOT NULL,
  CustomerAddress   NVARCHAR(35) NOT NULL,
  CustomerCity      NVARCHAR(20) NOT NULL,
  CustomerState     NVARCHAR(12) NOT NULL,
  CustomerZipcode   NVARCHAR(10) NOT NULL,
  CustomerDOB       DATE NOT NULL,
  CustomerGender    NVARCHAR(10) NOT NULL,
  CustomerCategory  NVARCHAR(20) NOT NULL,
  CustomerStartDate DATE NOT NULL,
  CustomerEndDate   DATE NULL
);
--
CREATE TABLE DimLocation (
  LocationSK        INT IDENTITY(1,1) NOT NULL CONSTRAINT pk_location_sk PRIMARY KEY,
  LocationAK        INT NOT NULL,
  LocationAddress   NVARCHAR(35) NOT NULL,
  LocationCity      NVARCHAR(20) NOT NULL,
  LocationState     NVARCHAR(12) NOT NULL,
  LocationZip       NVARCHAR(10) NOT NULL,
  LocationCategory  NVARCHAR(20) NOT NULL,
  LocationStartDate DATE NOT NULL,
  LocationEndDate   DATE NULL
);
--Creates the fact table with a generated key (FactSaleID)
--There are two dates pointing to DimDate: SaleDateKey & DateAcceptedKey (Roll Playing Dimensions)
--The measure columns can be null, the keys cannot be null
CREATE TABLE FactSale (
  FactSaleID        INT IDENTITY(1,1) NOT NULL CONSTRAINT pk_fact_sale_id PRIMARY KEY,
  LocationSK        INT NOT NULL,
  CustomerSK        INT NOT NULL,
  ClothingSK        INT NOT NULL,
  SaleDateKey       INT NOT NULL,
  DateAcceptedKey   INT NOT NULL,
  BuyingPrice       MONEY,
  ClothingPrice     MONEY,
  OrderDiscount     NUMERIC(4,4),
  CONSTRAINT fk_sale_date_key FOREIGN KEY (SaleDateKey) REFERENCES DimDate(DateSK),
  CONSTRAINT fk_date_accepted_key FOREIGN KEY (DateAcceptedKey) REFERENCES DimDate(DateSK),
  CONSTRAINT fk_location_sk FOREIGN KEY (LocationSK) REFERENCES DimLocation(LocationSK),
  CONSTRAINT fk_customer_sk FOREIGN KEY (CustomerSK) REFERENCES DimCustomer(CustomerSK),
  CONSTRAINT fk_clothing_sk FOREIGN KEY (ClothingSK) REFERENCES DimClothing(ClothingSK)
);
