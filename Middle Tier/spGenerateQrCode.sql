CREATE PROCEDURE spGenerateQrCode
@first_name VARCHAR(30),
@last_name VARCHAR(30)
AS
BEGIN
    DECLARE @qr_code_url VARCHAR(255);
    DECLARE @drop_off_time TIME;
    DECLARE @drop_off_date DATE;
    DECLARE @parent_id_number CHAR(11);
    DECLARE @timestamp DATETIME = GETDATE();
    DECLARE @child_id INT;
    DECLARE @picked_up BIT;

    BEGIN TRY
    --make sure username is not empty and contains only letters
        IF @first_name NOT LIKE '%[^A-Za-z]%' AND LEN(@first_name) > 0
        BEGIN
        --make sure username is not empty and contains only letters
            IF @last_name NOT LIKE '%[^A-Za-z]%' AND LEN(@last_name) > 0
            BEGIN
                BEGIN TRANSACTION;

                SET @drop_off_time = CONVERT(TIME, @timestamp);
                SET @drop_off_date = CONVERT(DATE, @timestamp);

                SELECT @child_id = child_id
                FROM child
                WHERE first_name = @first_name AND last_name = @last_name;

                IF @child_id IS NULL
                BEGIN
                    PRINT 'Child not found';
                    ROLLBACK TRANSACTION;
                    RETURN;
                END

                SELECT @parent_id_number = parent_id_number
                FROM child
                WHERE child_id = @child_id;

                IF @parent_id_number IS NULL
                BEGIN
                    PRINT 'Parent not found';
                    ROLLBACK TRANSACTION;
                    RETURN;
                END

                SET @qr_code_url = 'https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=' + @first_name + '_' + @last_name + '_' + CONVERT(VARCHAR, @timestamp, 120) +'_'+ '&color=f3846c&qzone=4';

                INSERT INTO qrcode (qr_code_url, drop_off_time, drop_off_date, parent_id_number, child_id)
                VALUES (@qr_code_url, @drop_off_time, @drop_off_date, @parent_id_number, @child_id);

                COMMIT TRANSACTION;
                PRINT 'QR code generated and stored successfully';
            END
            ELSE
            BEGIN
                PRINT 'Error: Last name should contain only letters.';
            END
        END
        ELSE
        BEGIN
            PRINT 'Error: First name should contain only letters.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'An error occurred during QR code generation';

        EXEC spHandleError;

                                        DECLARE @ErrorNumber INT = ERROR_NUMBER();
                                        IF @ErrorNumber = 2627 -- Unique constraint violation error code
                                        BEGIN
                                        PRINT 'Error: Duplicate value. Either phone number or email already exists.';
                                        END
                                        ELSE IF @ErrorNumber = 547 -- Foreign key violation error code
                                        BEGIN
                                        PRINT 'Error: Foreign key violation.';
                                        END

    END CATCH
END;