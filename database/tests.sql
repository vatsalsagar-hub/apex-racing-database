USE JCF_Student15_DB;
GO

EXEC sp_GetDriverRaceHistory @LicenseNumber = 'LIC-001';
GO

EXEC sp_UpdateCarStatus @CarNumber = '9', @NewStatus = 'AC';
GO

EXEC sp_RefreshRaceReport;
GO

EXEC sp_DeactivateExpiredSponsors;
GO

EXEC sp_DeleteDriverEntries @LicenseNumber = 'LIC-020';
GO

PRINT 'All stored procedure tests executed.';
GO
