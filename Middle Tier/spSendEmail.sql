CREATE PROCEDURE spSendEmail
    @recipient_email VARCHAR(100),
    @subject VARCHAR(255),
    @body NVARCHAR(MAX)
AS
BEGIN
    DECLARE @Object INT;
    DECLARE @ResponseText VARCHAR(8000);
    DECLARE @Status INT;
    DECLARE @URL NVARCHAR(1000);
    DECLARE @APIKey NVARCHAR(100) = 'your_api_key_here'; -- Replace with your actual API key

    SET @URL = 'https://api.maileroo.com/v1/send';

    BEGIN TRY
        -- Create the HTTP request object
        EXEC @Status = sp_OACreate 'MSXML2.ServerXMLHTTP', @Object OUT;
        IF @Status <> 0
        BEGIN
            PRINT 'Error: Unable to create HTTP request object';
            RETURN;
        END

        -- Open the HTTP request
        EXEC @Status = sp_OAMethod @Object, 'open', NULL, 'POST', @URL, 'false';
        IF @Status <> 0
        BEGIN
            PRINT 'Error: Unable to open HTTP request';
            RETURN;
        END

        -- Set the request headers
        EXEC @Status = sp_OAMethod @Object, 'setRequestHeader', NULL, 'Content-Type', 'application/json';
        IF @Status <> 0
        BEGIN
            PRINT 'Error: Unable to set request header';
            RETURN;
        END

        EXEC @Status = sp_OAMethod @Object, 'setRequestHeader', NULL, 'Authorization', 'Bearer ' + @APIKey;
        IF @Status <> 0
        BEGIN
            PRINT 'Error: Unable to set authorization header';
            RETURN;
        END

        -- Send the HTTP request with the email data
        DECLARE @EmailData NVARCHAR(MAX);
        SET @EmailData = '{
            "to": "' + @recipient_email + '",
            "subject": "' + @subject + '",
            "body": "' + @body + '"
        }';

        EXEC @Status = sp_OAMethod @Object, 'send', NULL, @EmailData;
        IF @Status <> 0
        BEGIN
            PRINT 'Error: Unable to send HTTP request';
            RETURN;
        END

        -- Get the response text
        EXEC @Status = sp_OAMethod @Object, 'responseText', @ResponseText OUT;
        IF @Status <> 0
        BEGIN
            PRINT 'Error: Unable to get response text';
            RETURN;
        END

        PRINT 'Email sent successfully';
        PRINT @ResponseText;

        -- Destroy the HTTP request object
        EXEC sp_OADestroy @Object;
    END TRY
    BEGIN CATCH
        PRINT 'An error occurred while sending the email';
        IF @Object IS NOT NULL
        BEGIN
            EXEC sp_OADestroy @Object;
        END
    END CATCH
END;