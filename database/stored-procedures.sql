IF OBJECT_ID('sp_GetDriverRaceHistory', 'P') IS NOT NULL DROP PROCEDURE sp_GetDriverRaceHistory;
IF OBJECT_ID('sp_UpdateCarStatus', 'P') IS NOT NULL DROP PROCEDURE sp_UpdateCarStatus;
IF OBJECT_ID('sp_RefreshRaceReport', 'P') IS NOT NULL DROP PROCEDURE sp_RefreshRaceReport;
IF OBJECT_ID('sp_DeactivateExpiredSponsors', 'P') IS NOT NULL DROP PROCEDURE sp_DeactivateExpiredSponsors;
IF OBJECT_ID('sp_DeleteDriverEntries', 'P') IS NOT NULL DROP PROCEDURE sp_DeleteDriverEntries;
GO

USE JCF_Student15_DB;
GO
CREATE PROCEDURE sp_GetDriverRaceHistory
    @LicenseNumber VARCHAR(25)
AS
BEGIN
    SELECT
        D.Driver_FirstName,
        D.Driver_LastName,
        R.Race_Name,
        R.Race_Date,
        RE.Starting_Position,
        RE.Qualifying_Time,
        RR.Finish_Position,
        RR.Points_Earned,
        RR.Finish_Status,
        RR.Prize_Won
    FROM Driver D
    INNER JOIN RaceEntry RE ON D.Driver_ID = RE.Driver_ID
    INNER JOIN Race R ON RE.Race_ID = R.Race_ID
    LEFT JOIN RaceResult RR ON RE.RaceEntry_ID = RR.RaceEntry_ID
    WHERE D.License_Number = @LicenseNumber
    ORDER BY R.Race_Date;
END
GO

USE JCF_Student15_DB;
GO
CREATE PROCEDURE sp_UpdateCarStatus
    @CarNumber VARCHAR(10),
    @NewStatus CHAR(2)
AS
BEGIN
    UPDATE Car
    SET CarStatus_Code = @NewStatus
    WHERE Car_Number = @CarNumber;
END
GO

USE JCF_Student15_DB;
GO
CREATE PROCEDURE sp_RefreshRaceReport
AS
BEGIN
    IF OBJECT_ID('RaceReportSummary', 'U') IS NOT NULL
        DROP TABLE RaceReportSummary;

    SELECT
        R.Race_Name,
        R.Season_Year,
        R.Race_Date,
        R.Weather_Summary,
        T.Track_Name,
        T.Country_Name,
        D.Driver_FirstName,
        D.Driver_LastName,
        C.Car_Number,
        RE.Starting_Position,
        RR.Finish_Position,
        RR.Points_Earned,
        RR.Finish_Status,
        RR.Prize_Won
    INTO RaceReportSummary
    FROM Race R
    INNER JOIN Track T ON R.Track_ID = T.Track_ID
    INNER JOIN RaceEntry RE ON R.Race_ID = RE.Race_ID
    INNER JOIN Driver D ON RE.Driver_ID = D.Driver_ID
    INNER JOIN Car C ON RE.Car_ID = C.Car_ID
    LEFT JOIN RaceResult RR ON RE.RaceEntry_ID = RR.RaceEntry_ID;
END
GO

USE JCF_Student15_DB;
GO
CREATE PROCEDURE sp_DeactivateExpiredSponsors
AS
BEGIN
    UPDATE Sponsor
    SET Active_Flag = 0
    WHERE Sponsor_ID IN (
        SELECT Sponsor_ID
        FROM Join_Team_Sponsor
        WHERE Contract_EndDate < GETDATE()
    )
    AND Active_Flag = 1;
END
GO

USE JCF_Student15_DB;
GO
CREATE PROCEDURE sp_DeleteDriverEntries
    @LicenseNumber VARCHAR(25)
AS
BEGIN
    DECLARE @DriverID UNIQUEIDENTIFIER;
    SET @DriverID = (SELECT Driver_ID FROM Driver WHERE License_Number = @LicenseNumber);

    DELETE FROM RaceResult
    WHERE RaceEntry_ID IN (
        SELECT RaceEntry_ID FROM RaceEntry WHERE Driver_ID = @DriverID
    );

    DELETE FROM RaceEntry
    WHERE Driver_ID = @DriverID;
END
GO
