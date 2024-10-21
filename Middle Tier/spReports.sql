CREATE PROCEDURE spGenerateDailyReport
    @reportDate DATE
AS
BEGIN
    DECLARE @reportContent VARCHAR(MAX);

    -- Generate report content based on the provided date
    SET @reportContent = (
        SELECT 
            'Class Report: ' + CHAR(13) + CHAR(10) +
            'Total Classes: ' + CAST(COUNT(*) AS VARCHAR) + CHAR(13) + CHAR(10) +
            'Total Students: ' + CAST((SELECT COUNT(*) FROM child) AS VARCHAR) + CHAR(13) + CHAR(10) +
            'Total Parents: ' + CAST((SELECT COUNT(*) FROM parent) AS VARCHAR) + CHAR(13) + CHAR(10) +
            'Total QR Codes: ' + CAST((SELECT COUNT(*) FROM qrcode WHERE drop_off_date = @reportDate) AS VARCHAR) + CHAR(13) + CHAR(10) +
            'Total Pickups: ' + CAST((SELECT COUNT(*) FROM pickup WHERE pickup_date = @reportDate) AS VARCHAR) + CHAR(13) + CHAR(10)
        FROM class
    );

    -- Insert the generated report into the reports table
    INSERT INTO reports (report_date, report_content)
    VALUES (@reportDate, @reportContent);

    PRINT 'Daily report generated and inserted successfully.';

    -- Select and return the inserted report
    SELECT * FROM reports WHERE report_date = @reportDate;
END;