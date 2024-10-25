CREATE TRIGGER trg_qr_insert
ON qrcode
AFTER INSERT
AS
BEGIN
    DECLARE @qr_code_url VARCHAR(255);
     DECLARE @admin_id INT; -- this value is stroed in the session, which is set after the admin logs in
    DECLARE @table_name VARCHAR(255) = 'qrcode';
    DECLARE @current_timestamp DATETIME;


    SET @current_timestamp = GETDATE();


    

    -- Get the QR code URL from the inserted row
    SELECT @qr_code_url = qr_code_url
    FROM inserted;

    SET @admin_id = CAST(SESSION_CONTEXT(N'admin_id') AS INT); -- this value is stroed in the session, which is set after the admin logs in

    

    -- Insert a log entry
    INSERT INTO audit_log (action, new_values, timestamp, performed_by_admin_id, table_name)
    VALUES ('QR Code Generated', @qr_code_url, @current_timestamp, @admin_id, @table_name);
END;