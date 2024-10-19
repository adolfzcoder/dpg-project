EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 1;
RECONFIGURE;

ALTER PROCEDURE SendEmailViaMailerSend
    @apiKey VARCHAR(255),
    @fromEmail VARCHAR(255),
    @fromName VARCHAR(255),
    @toEmail VARCHAR(255),
    @subject VARCHAR(255),
    @htmlContent VARCHAR(MAX)
AS
BEGIN
    -- Declare the command for xp_cmdshell
    DECLARE @cmd VARCHAR(MAX);

    -- Build the PowerShell command string with proper argument quoting
    SET @cmd = 'powershell -ExecutionPolicy Bypass -File "C:\Users\adolf\OneDrive\Documents\SendEmail.ps1" ' + 
               '"' + @apiKey + '" ' +
               '"' + @fromEmail + '" ' +
               '"' + @fromName + '" ' +
               '"' + @toEmail + '" ' +
               '"' + @subject + '" ' +
               '"' + @htmlContent + '"';

    -- Print the command for debugging purposes
    PRINT @cmd;

    -- Execute the PowerShell script via xp_cmdshell
    EXEC xp_cmdshell @cmd;
END;

-- Example execution
EXEC SendEmailViaMailerSend
    @apiKey = 'mlsn.66bb963cbabc637228d1957ec7a56fc0d2957a4f14c4bf08b061f749eeeb9ee8',
    @fromEmail = 'trial-k68zxl2yn9k4j905.mlsender.net',
    @fromName = 'Adolf',
    @toEmail = 'adolfdavid17@gmail.com',
    @subject = 'Test Email',
    @htmlContent = '<h1>Hello, this is a test email!</h1>';
