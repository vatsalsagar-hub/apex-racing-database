USE JCF_Student15_DB;
GO
-- drop tables first so we can rerun the script without errors
-- has to be in reverse order or the foreign keys will complain
IF OBJECT_ID('RaceResult', 'U') IS NOT NULL DROP TABLE RaceResult;
IF OBJECT_ID('RaceEntry', 'U') IS NOT NULL DROP TABLE RaceEntry;
IF OBJECT_ID('Race', 'U') IS NOT NULL DROP TABLE Race;
IF OBJECT_ID('Join_Team_Sponsor', 'U') IS NOT NULL DROP TABLE Join_Team_Sponsor;
IF OBJECT_ID('Sponsor', 'U') IS NOT NULL DROP TABLE Sponsor;
IF OBJECT_ID('Car', 'U') IS NOT NULL DROP TABLE Car;
IF OBJECT_ID('CarStatus_Lookup', 'U') IS NOT NULL DROP TABLE CarStatus_Lookup;
IF OBJECT_ID('CrewMember', 'U') IS NOT NULL DROP TABLE CrewMember;
IF OBJECT_ID('CrewRole_Lookup', 'U') IS NOT NULL DROP TABLE CrewRole_Lookup;
IF OBJECT_ID('Driver', 'U') IS NOT NULL DROP TABLE Driver;
IF OBJECT_ID('Track', 'U') IS NOT NULL DROP TABLE Track;
IF OBJECT_ID('Series_Lookup', 'U') IS NOT NULL DROP TABLE Series_Lookup;
IF OBJECT_ID('Team', 'U') IS NOT NULL DROP TABLE Team;
GO

CREATE TABLE Team (
    Team_ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    Team_Name VARCHAR(60) NOT NULL,
    Team_BaseCity VARCHAR(40) NOT NULL,
    Team_BaseState VARCHAR(30) NOT NULL,
    Team_PrincipalName VARCHAR(60) NOT NULL,
    Team_Phone VARCHAR(20) NULL,
    Team_Email VARCHAR(80) NULL,
    Team_FoundedYear SMALLINT NOT NULL,
    Team_Status CHAR(1) NOT NULL DEFAULT 'A',
    CONSTRAINT PK_Team PRIMARY KEY (Team_ID)
);
GO

CREATE TABLE Driver (
    Driver_ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    Team_ID UNIQUEIDENTIFIER NOT NULL,
    Driver_FirstName VARCHAR(30) NOT NULL,
    Driver_LastName VARCHAR(30) NOT NULL,
    License_Number VARCHAR(25) NOT NULL,
    DOB DATE NOT NULL,
    Nationality VARCHAR(40) NOT NULL,
    Experience_Years SMALLINT NULL DEFAULT 0,
    Active_Flag BIT NOT NULL DEFAULT 1,
    CONSTRAINT PK_Driver PRIMARY KEY (Driver_ID),
    CONSTRAINT FK_Driver_Team FOREIGN KEY (Team_ID) REFERENCES Team(Team_ID)
);
GO

CREATE TABLE CrewRole_Lookup (
    CrewRole_Code CHAR(3) NOT NULL,
    CrewRole_Description VARCHAR(40) NOT NULL,
    CONSTRAINT PK_CrewRole_Lookup PRIMARY KEY (CrewRole_Code)
);
GO

CREATE TABLE CrewMember (
    CrewMember_ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    Team_ID UNIQUEIDENTIFIER NOT NULL,
    CrewRole_Code CHAR(3) NOT NULL,
    Crew_FirstName VARCHAR(30) NOT NULL,
    Crew_LastName VARCHAR(30) NOT NULL,
    Crew_Phone VARCHAR(20) NULL,
    Crew_Email VARCHAR(80) NULL,
    Hire_Date DATETIME NOT NULL,
    Active_Flag BIT NOT NULL DEFAULT 1,
    CONSTRAINT PK_CrewMember PRIMARY KEY (CrewMember_ID),
    CONSTRAINT FK_CrewMember_Team FOREIGN KEY (Team_ID) REFERENCES Team(Team_ID),
    CONSTRAINT FK_CrewMember_CrewRole FOREIGN KEY (CrewRole_Code) REFERENCES CrewRole_Lookup(CrewRole_Code)
);
GO

CREATE TABLE CarStatus_Lookup (
    CarStatus_Code CHAR(2) NOT NULL,
    CarStatus_Description VARCHAR(30) NOT NULL,
    CONSTRAINT PK_CarStatus_Lookup PRIMARY KEY (CarStatus_Code)
);
GO

CREATE TABLE Car (
    Car_ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    Team_ID UNIQUEIDENTIFIER NOT NULL,
    CarStatus_Code CHAR(2) NOT NULL,
    Car_Number VARCHAR(10) NOT NULL,
    Chassis_Number VARCHAR(30) NOT NULL,
    Engine_Supplier VARCHAR(40) NOT NULL,
    Model_Name VARCHAR(40) NOT NULL,
    Model_Year SMALLINT NOT NULL,
    Last_Service_Date DATETIME NULL,
    CONSTRAINT PK_Car PRIMARY KEY (Car_ID),
    CONSTRAINT FK_Car_Team FOREIGN KEY (Team_ID) REFERENCES Team(Team_ID),
    CONSTRAINT FK_Car_CarStatus FOREIGN KEY (CarStatus_Code) REFERENCES CarStatus_Lookup(CarStatus_Code)
);
GO

CREATE TABLE Sponsor (
    Sponsor_ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    Sponsor_Name VARCHAR(80) NOT NULL,
    Industry_Type VARCHAR(40) NOT NULL,
    Contact_Name VARCHAR(30) NULL,
    Contact_Email VARCHAR(80) NULL,
    Contact_Phone VARCHAR(20) NULL,
    Sponsor_Tier VARCHAR(20) NOT NULL,
    Active_Flag BIT NOT NULL DEFAULT 1,
    CONSTRAINT PK_Sponsor PRIMARY KEY (Sponsor_ID)
);
GO

CREATE TABLE Join_Team_Sponsor (
    Team_ID UNIQUEIDENTIFIER NOT NULL,
    Sponsor_ID UNIQUEIDENTIFIER NOT NULL,
    Contract_StartDate DATETIME NOT NULL,
    Contract_EndDate DATETIME NOT NULL,
    Contribution_Amount NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    Primary_Sponsor_Flag BIT NOT NULL DEFAULT 0,
    CONSTRAINT PK_Join_Team_Sponsor PRIMARY KEY (Team_ID, Sponsor_ID),
    CONSTRAINT FK_JTS_Team FOREIGN KEY (Team_ID) REFERENCES Team(Team_ID),
    CONSTRAINT FK_JTS_Sponsor FOREIGN KEY (Sponsor_ID) REFERENCES Sponsor(Sponsor_ID)
);
GO

CREATE TABLE Track (
    Track_ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    Track_Name VARCHAR(80) NOT NULL,
    Country_Name VARCHAR(40) NOT NULL,
    City_Name VARCHAR(40) NOT NULL,
    Track_Type VARCHAR(20) NOT NULL,
    Length_Miles NUMERIC(5,2) NOT NULL,
    Turns_Count SMALLINT NOT NULL,
    FIA_Grade VARCHAR(10) NULL,
    Active_Flag BIT NOT NULL DEFAULT 1,
    CONSTRAINT PK_Track PRIMARY KEY (Track_ID)
);
GO

CREATE TABLE Series_Lookup (
    Series_Code CHAR(4) NOT NULL,
    Series_Description VARCHAR(40) NOT NULL,
    CONSTRAINT PK_Series_Lookup PRIMARY KEY (Series_Code)
);
GO

CREATE TABLE Race (
    Race_ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    Track_ID UNIQUEIDENTIFIER NOT NULL,
    Series_Code CHAR(4) NOT NULL,
    Race_Name VARCHAR(80) NOT NULL,
    Season_Year SMALLINT NOT NULL,
    Race_Date DATETIME NOT NULL,
    Scheduled_Laps SMALLINT NOT NULL,
    Weather_Summary VARCHAR(30) NULL,
    Purse_Amount NUMERIC(12,2) NULL DEFAULT 0.00,
    CONSTRAINT PK_Race PRIMARY KEY (Race_ID),
    CONSTRAINT FK_Race_Track FOREIGN KEY (Track_ID) REFERENCES Track(Track_ID),
    CONSTRAINT FK_Race_Series FOREIGN KEY (Series_Code) REFERENCES Series_Lookup(Series_Code)
);
GO

CREATE TABLE RaceEntry (
    RaceEntry_ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    Race_ID UNIQUEIDENTIFIER NOT NULL,
    Car_ID UNIQUEIDENTIFIER NOT NULL,
    Driver_ID UNIQUEIDENTIFIER NOT NULL,
    Starting_Position SMALLINT NOT NULL,
    Qualifying_Time NUMERIC(8,3) NULL,
    Entry_Status CHAR(1) NOT NULL DEFAULT 'E',
    Pit_Crew_Chief VARCHAR(60) NULL,
    CONSTRAINT PK_RaceEntry PRIMARY KEY (RaceEntry_ID),
    CONSTRAINT FK_RaceEntry_Race FOREIGN KEY (Race_ID) REFERENCES Race(Race_ID),
    CONSTRAINT FK_RaceEntry_Car FOREIGN KEY (Car_ID) REFERENCES Car(Car_ID),
    CONSTRAINT FK_RaceEntry_Driver FOREIGN KEY (Driver_ID) REFERENCES Driver(Driver_ID)
);
GO

CREATE TABLE RaceResult (
    RaceEntry_ID UNIQUEIDENTIFIER NOT NULL,
    Finish_Position SMALLINT NULL,
    Laps_Completed SMALLINT NOT NULL DEFAULT 0,
    Points_Earned NUMERIC(6,2) NOT NULL DEFAULT 0.00,
    Finish_Status VARCHAR(20) NOT NULL,
    Prize_Won NUMERIC(12,2) NULL DEFAULT 0.00,
    Fastest_Lap_Time NUMERIC(8,3) NULL,
    CONSTRAINT PK_RaceResult PRIMARY KEY (RaceEntry_ID),
    CONSTRAINT FK_RaceResult_RaceEntry FOREIGN KEY (RaceEntry_ID) REFERENCES RaceEntry(RaceEntry_ID)
);
GO

-- Sample lookup/team/driver data from the original project
INSERT INTO CrewRole_Lookup (CrewRole_Code, CrewRole_Description) VALUES
('ENG', 'Race Engineer'),
('MEC', 'Mechanic'),
('CHF', 'Chief Mechanic'),
('STR', 'Strategist'),
('DAT', 'Data Analyst'),
('PHY', 'Physiotherapist'),
('NUT', 'Nutritionist'),
('PRE', 'Press Officer'),
('LOG', 'Logistics Manager'),
('QUA', 'Quality Control');
GO

INSERT INTO CarStatus_Lookup (CarStatus_Code, CarStatus_Description) VALUES
('AC', 'Active'),
('SP', 'Spare'),
('DC', 'Decommissioned'),
('RP', 'Under Repair');
GO

INSERT INTO Series_Lookup (Series_Code, Series_Description) VALUES
('F1  ', 'Formula 1 World Championship'),
('F2  ', 'Formula 2 Championship'),
('F3  ', 'Formula 3 Championship'),
('FE  ', 'Formula E World Championship');
GO

INSERT INTO Team (Team_Name, Team_BaseCity, Team_BaseState, Team_PrincipalName, Team_Phone, Team_Email, Team_FoundedYear, Team_Status)
VALUES ('Apex Racing', 'Silverstone', 'Northamptonshire', 'James Whitfield', '+44-1234-567890', 'info@apexracing.com', 2010, 'A');
GO
