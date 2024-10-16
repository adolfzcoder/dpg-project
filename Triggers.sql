CREATE TRIGGER trgAfterInsertQrCode
ON qrcode
AFTER INSERT
AS
BEGIN
    DECLARE @qr_code_url VARCHAR(255);
    DECLARE @admin_id INT = 1; -- Assuming admin_id is 1 for this example

    -- Get the QR code URL from the inserted row
    SELECT @qr_code_url = qr_code_url
    FROM inserted;

    -- Insert a log entry
    INSERT INTO log (action, qr_code_url, admin_id)
    VALUES ('QR Code Generated', @qr_code_url, @admin_id);
END;