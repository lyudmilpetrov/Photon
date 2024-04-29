
/****** Object:  StoredProcedure [dbo].[GetCoordinatesLocal]    Script Date: 1/17/2024 8:53:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[GetCoordinatesLocal]
    @country VARCHAR(100),
    @state VARCHAR(100),
    @city VARCHAR(100),
    @street VARCHAR(100),
    @postCode VARCHAR(100),
    @email VARCHAR(100)
AS
BEGIN
    -- Create a table to hold the output of the PowerShell script
    CREATE TABLE #PowerShellOutput (
        OutputLine NVARCHAR(MAX)
    );

    -- Prepare the command to execute the PowerShell script
    DECLARE @cmd VARCHAR(1000)
	--- C:\Scripts\GetCoordinates.ps1
    SET @cmd = 'powershell.exe -File "C:\Photon\GetCoordinatesLocal.ps1" ' +
               '-country "' + @country + '" ' +
               '-state "' + @state + '" ' +
               '-city "' + @city + '" ' +
               '-street "' + @street + '" ' +
               '-postCode "' + @postCode + '" ' +
               '-email "' + @email + '"'

    -- Execute the PowerShell script and insert the results into the table
    INSERT INTO #PowerShellOutput (OutputLine)
    EXEC xp_cmdshell @cmd

    -- Parse the results to extract latitude and longitude
    DECLARE @lat DECIMAL(8, 6)
    DECLARE @lon DECIMAL(9, 6)
    DECLARE @output NVARCHAR(MAX)

    SELECT @output = OutputLine
    FROM #PowerShellOutput
    WHERE OutputLine IS NOT NULL AND OutputLine LIKE 'Latitude:%'

    IF @output IS NOT NULL
    BEGIN
        SET @lat = CAST(SUBSTRING(@output, CHARINDEX('Latitude: ', @output) + 10, CHARINDEX(',', @output) - CHARINDEX('Latitude: ', @output) - 10) AS DECIMAL(8, 6))
        SET @lon = CAST(SUBSTRING(@output, CHARINDEX('Longitude: ', @output) + 11, LEN(@output)) AS DECIMAL(9, 6))
    END

    -- Return the latitude and longitude
    SELECT @lat AS Latitude, @lon AS Longitude

    -- Drop the temporary table
    DROP TABLE #PowerShellOutput
	------------- Test
	--EXEC dbo.GetCoordinatesLocal 
 --   @country = 'USA', 
 --   @state = 'California', 
 --   @city = 'Los Angeles', 
 --   @street = 'Sunset Blvd', 
 --   @postCode = '90026', 
 --   @email = 'ljudmilpetrov79@gmail.com'

END
