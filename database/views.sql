IF OBJECT_ID('vw_RaceEntryFullDetail', 'V') IS NOT NULL DROP VIEW vw_RaceEntryFullDetail;
IF OBJECT_ID('vw_ClassifiedResults', 'V') IS NOT NULL DROP VIEW vw_ClassifiedResults;
IF OBJECT_ID('vw_AllRacesWithTrackAndSeries', 'V') IS NOT NULL DROP VIEW vw_AllRacesWithTrackAndSeries;
IF OBJECT_ID('vw_DriversWithPoints', 'V') IS NOT NULL DROP VIEW vw_DriversWithPoints;
IF OBJECT_ID('vw_ActiveCars', 'V') IS NOT NULL DROP VIEW vw_ActiveCars;
IF OBJECT_ID('vw_AllDriversWithTeam', 'V') IS NOT NULL DROP VIEW vw_AllDriversWithTeam;
IF OBJECT_ID('vw_ActiveSponsors', 'V') IS NOT NULL DROP VIEW vw_ActiveSponsors;
IF OBJECT_ID('vw_AllTracks', 'V') IS NOT NULL DROP VIEW vw_AllTracks;
GO

USE JCF_Student15_DB;
GO
CREATE VIEW vw_RaceEntryFullDetail AS
SELECT TOP 100 PERCENT
    D.Driver_FirstName,
    D.Driver_LastName,
    D.License_Number,
    C.Car_Number,
    C.Model_Name,
    R.Race_Name,
    R.Race_Date,
    RE.Starting_Position,
    RE.Qualifying_Time,
    RE.Entry_Status,
    RE.Pit_Crew_Chief
FROM RaceEntry RE
INNER JOIN Driver D ON RE.Driver_ID = D.Driver_ID
INNER JOIN Car C ON RE.Car_ID = C.Car_ID
INNER JOIN Race R ON RE.Race_ID = R.Race_ID
WHERE RE.Entry_Status = 'E'
ORDER BY R.Race_Date, RE.Starting_Position;
GO

USE JCF_Student15_DB;
GO
CREATE VIEW vw_ClassifiedResults AS
SELECT
    RR.Finish_Position,
    RR.Laps_Completed,
    RR.Points_Earned,
    RR.Prize_Won,
    RR.Fastest_Lap_Time,
    RE.Starting_Position,
    RE.Qualifying_Time,
    RE.Pit_Crew_Chief,
    R.Race_Name,
    R.Season_Year,
    R.Race_Date
FROM RaceResult RR
INNER JOIN RaceEntry RE ON RR.RaceEntry_ID = RE.RaceEntry_ID
INNER JOIN Race R ON RE.Race_ID = R.Race_ID
WHERE RR.Finish_Status = 'Classified';
GO

USE JCF_Student15_DB;
GO
CREATE VIEW vw_AllRacesWithTrackAndSeries AS
SELECT
    R.Race_Name,
    R.Season_Year,
    R.Race_Date,
    R.Scheduled_Laps,
    R.Weather_Summary,
    R.Purse_Amount,
    T.Track_Name,
    T.Country_Name,
    T.City_Name,
    T.Track_Type,
    T.Length_Miles,
    S.Series_Description
FROM Race R
INNER JOIN Track T ON R.Track_ID = T.Track_ID
INNER JOIN Series_Lookup S ON R.Series_Code = S.Series_Code;
GO

USE JCF_Student15_DB;
GO
CREATE VIEW vw_DriversWithPoints AS
SELECT
    D.Driver_FirstName,
    D.Driver_LastName,
    D.Nationality,
    D.License_Number,
    D.Experience_Years
FROM Driver D
WHERE D.Driver_ID IN (
    SELECT RE.Driver_ID
    FROM RaceEntry RE
    INNER JOIN RaceResult RR ON RE.RaceEntry_ID = RR.RaceEntry_ID
    WHERE RR.Points_Earned > 0
);
GO

USE JCF_Student15_DB;
GO
CREATE VIEW vw_ActiveCars AS
SELECT
    C.Car_Number,
    C.Chassis_Number,
    C.Engine_Supplier,
    C.Model_Name,
    C.Model_Year,
    C.Last_Service_Date,
    CS.CarStatus_Description
FROM Car C
INNER JOIN CarStatus_Lookup CS ON C.CarStatus_Code = CS.CarStatus_Code
WHERE C.CarStatus_Code = 'AC';
GO

USE JCF_Student15_DB;
GO
CREATE VIEW vw_AllDriversWithTeam AS
SELECT
    T.Team_Name,
    T.Team_BaseCity,
    D.Driver_FirstName,
    D.Driver_LastName,
    D.Nationality,
    D.License_Number,
    D.Experience_Years,
    D.Active_Flag
FROM Team T
LEFT OUTER JOIN Driver D ON T.Team_ID = D.Team_ID;
GO

USE JCF_Student15_DB;
GO
CREATE VIEW vw_ActiveSponsors AS
SELECT
    Sponsor_Name,
    Industry_Type,
    Contact_Name,
    Contact_Email,
    Contact_Phone,
    Sponsor_Tier
FROM Sponsor
WHERE Active_Flag = 1;
GO

USE JCF_Student15_DB;
GO
CREATE VIEW vw_AllTracks AS
SELECT *
FROM Track;
GO
