CREATE PROCEDURE spGenerateQrCode
@first_name VARCHAR(30),
@last_name VARCHAR(30),
AS
BEGIN
    DECLARE @qr_code_url VARCHAR(255);
    DECLARE @drop_off_time TIME;
    DECLARE @drop_off_date DATE;
    DECLARE @parent_id_number CHAR(11);
    DECLARE @timestamp DATETIME = GETDATE();
    DECLARE @child_id INT;

    SET @drop_off_time = CONVERT(TIME, @timestamp);
    SET @drop_off_date = CONVERT(DATE, @timestamp);

    SELECT @child_id = child_id
    FROM child
    WHERE first_name = @first_name AND last_name = @last_name;

    IF @child_id IS NULL
    BEGIN
        PRINT 'Child not found';
        RETURN;
    END

    SELECT @parent_id_number = parent_id_number
    FROM parent_child
    WHERE child_id = @child_id;

    IF @parent_id_number IS NULL
    BEGIN
        PRINT 'Parent not found';
        RETURN;
    END

    SET @qr_code_url = 'https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=' + @first_name + '_' + @last_name + '_' + CONVERT(VARCHAR, @timestamp, 120);

    INSERT INTO qrcode (qr_code_url, drop_off_time, drop_off_date, parent_id_number, child_id)
    VALUES (@qr_code_url, @drop_off_time, @drop_off_date, @parent_id_number, @child_id);

    PRINT 'QR code generated and stored successfully';
END;