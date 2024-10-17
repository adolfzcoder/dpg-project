DECLARE @email_body nvachar(max)

SELECT @email_body = N'<br/><br>' + 'Here is your QR code: ' + @qr_code_url + '<br/><br>' + 'Thank you for using our service!'


EXEC msdo.dbo.sp_send_dbmail
@profile_name = 'Gmail',    
@recipients = 'adolfdavid17@gmail.com',
@copy_recepients = Null,
@blind_copy_recepients = Null,
@subject = 'QR Code',
@body = @email_body,
@body_format = 'HTML',
@importance = 'High',
@sensitivity = 'Normal',
@file_attachments = @qr_code_url,
@query = 'SELECT * FROM qrcode WHERE qr_code_url = @qr_code_url'


