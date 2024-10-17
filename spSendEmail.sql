CREATE PROCEDURE spSendEmail
    @to_email VARCHAR(255),
    @subject VARCHAR(255),
    @body VARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @api_key VARCHAR(255) = 'YOUR_SENDGRID_API_KEY'; -- Replace with your actual API key
    DECLARE @url VARCHAR(255) = 'https://api.sendgrid.com/v3/mail/send';
    DECLARE @cmd VARCHAR(1000);

    SET @cmd = 'curl -X POST ' + @url +
               ' -H "Authorization: Bearer ' + @api_key + '"' +
               ' -H "Content-Type: application/json"' +
               ' -d "{ \"personalizations\": [ { \"to\": [ { \"email\": \"' + @to_email + '\" } ] } ], \"subject\": \"' + @subject + '\" }, \"content\": [ { \"type\": \"text/plain\", \"value\": \"' + @body + '\" } ] }"';

    EXEC xp_cmdshell @cmd;

    PRINT 'Email sent successfully';
END;
