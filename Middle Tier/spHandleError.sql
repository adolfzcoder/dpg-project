CREATE PROCEDURE spHandleError
AS
BEGIN
    DECLARE @ErrorNumber INT,
            @ErrorSeverity INT,
            @ErrorProcedure NVARCHAR(128),
            @ErrorMessage NVARCHAR(4000);

    -- Retrieve error details
    SET @ErrorNumber = ERROR_NUMBER();
    SET @ErrorSeverity = ERROR_SEVERITY();
    SET @ErrorProcedure = ERROR_PROCEDURE();
    SET @ErrorMessage = ERROR_MESSAGE();

    PRINT 'Error Number: ' + CAST(@ErrorNumber AS VARCHAR(10));
    PRINT 'Error Severity: ' + CAST(@ErrorSeverity AS VARCHAR(10));
    PRINT 'Error Procedure: ' + ISNULL(@ErrorProcedure, 'N/A');
    PRINT 'Error Message: ' + @ErrorMessage;


END;
