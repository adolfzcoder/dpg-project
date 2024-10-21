
CREATE PROCEDURE spPickupVerification
    @child_first_name VARCHAR(30),
    @child_last_name VARCHAR(30),
    @parent_id_number CHAR(11),
    @child_verification_code VARCHAR(16),
    @parent_verification_code VARCHAR(16)
AS
BEGIN
    DECLARE @child_id INT;
    DECLARE @first_name_from_db VARCHAR(30);
    DECLARE @last_name_from_db VARCHAR(30);
    DECLARE @parent_id_number_from_db CHAR(11);
    DECLARE @child_verification_code_from_db VARCHAR(16); -- UUID is 16 characters long
    DECLARE @verification_from_db VARCHAR(255);
    DECLARE @qr_code_url VARCHAR(255);

    -- Retrieve child and parent details
    SELECT  @first_name_from_db = first_name, 
            @last_name_from_db = last_name,
            @parent_id_number_from_db = parent_id_number,
            @child_id = child_id
    FROM child
    WHERE first_name = @child_first_name AND 
          last_name = @child_last_name AND 
          parent_id_number = @parent_id_number;

    -- Retrieve the qr_code_url from the qrcode table where picked_up is 0
    SELECT @qr_code_url = qr_code_url
    FROM qrcode
    WHERE child_id = @child_id AND picked_up = 0;

    -- Check if qr_code_url was found
    IF @qr_code_url IS NOT NULL
    BEGIN
        -- Find the position of the UUID in the URL
        DECLARE @start_pos INT = CHARINDEX('data=', @qr_code_url) + 5;
        DECLARE @end_pos INT = CHARINDEX('&qzone=4', @qr_code_url);

        -- Check if the positions are valid
        IF @start_pos > 5 AND @end_pos > @start_pos
        BEGIN
            -- Extract the substring that represents the UUID
            SET @child_verification_code_from_db = SUBSTRING(@qr_code_url, @start_pos, 16);

            PRINT @child_verification_code_from_db;

            -- Compare the extracted UUID with the provided verification codes
            IF @child_verification_code_from_db = @child_verification_code AND @child_verification_code_from_db = @parent_verification_code
            BEGIN
                -- Update the picked_up status to 1
                UPDATE qrcode
                SET picked_up = 1
                WHERE child_id = @child_id AND picked_up = 0;

                PRINT 'Pickup verification successful.';
            END
            ELSE
            BEGIN
                PRINT 'Error: Verification codes do not match.';
            END
        END
        ELSE
        BEGIN
            PRINT 'Error: Invalid QR code URL format.';
        END
    END
    ELSE
    BEGIN
        PRINT 'Error: No QR code found for the child with status picked up. Child is already picked up';
    END;
END;