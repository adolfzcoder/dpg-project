-- these procedures can be used to quickly view the stored data instead of using longer select statement

CREATE PROC viewAdmin
AS
BEGIN
SELECT * FROM adminTable
END;

-- EXEC viewAdmin

CREATE PROC viewTeacher
AS
BEGIN

SELECT * FROM teacher

END;

-- EXEC viewTeacher


EXEC addAdmin 'Adolf', 'Pass@123', 'adolfdavid17@gmail.com', '0816166875'
EXEC viewAdmin

-- DELETE FROM adminTable


CREATE PROCEDURE spAddAdmin
@username VARCHAR(30),
@password VARCHAR(50),
@email VARCHAR(45),
@phone_number CHAR(10)
AS
BEGIN
    DECLARE @email_exists INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Check if the email already exists
        SELECT @email_exists = COUNT(*)
        FROM adminTable
        WHERE email = @email;

        IF @email_exists > 0
        BEGIN
            PRINT 'Email already exists';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Insert into adminTable
        INSERT INTO adminTable (username, password, email, phone_number)
        VALUES (@username, @password, @email, @phone_number);

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        PRINT 'Could not insert data, please try again';
        PRINT ERROR_MESSAGE();  
    END CATCH;
END



-- EXEC adminLoginVerification 'adolfdavid17@gmail.com', 'Pass@123'

ALTER PROCEDURE adminLoginVerification
@email VARCHAR(45),
@password VARCHAR(255)
AS
BEGIN
    DECLARE @stored_password VARCHAR(50);
	DECLARE @email_exists INT;


	-- Check if the email already exists
    SELECT @email_exists = COUNT(*)
    FROM adminTable
    WHERE email = @email;

    IF @email_exists > 0
		BEGIN
			-- get stored password
			SELECT @stored_password = password
			FROM adminTable
			WHERE email = @email;


			-- Compare the passwords
			IF @stored_password = @password
			BEGIN
				PRINT 'Succesfully logged in';
			END
			ELSE
			BEGIN
				PRINT 'Password is incorrect';
			END
		END
		ELSE
		BEGIN
			PRINT 'Email Does not Exist';
		END
    
END;


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


CREATE PROCEDURE spAddChild
    @child_first_name VARCHAR(30),
    @child_last_name VARCHAR(30),
    @date_of_birth DATE,
    @emergency_contact_number CHAR(10),
    @emergency_contact_first_name VARCHAR(30),
    @emergency_contact_last_name VARCHAR(30),
    @class_name VARCHAR(30),
    @parent_id_number CHAR(11)
AS
BEGIN
    BEGIN TRY
        -- check if the parent exists
        IF EXISTS (SELECT 1 FROM parent WHERE parent_id_number = @parent_id_number)
        BEGIN
            -- Check if the parent already has a child
            IF NOT EXISTS (SELECT 1 FROM child WHERE parent_id_number = @parent_id_number)
            BEGIN
                -- Insert the child
                INSERT INTO child (first_name, last_name, date_of_birth, emergency_contact_number, emergency_contact_first_name, emergency_contact_last_name, class_id, parent_id_number)
                VALUES (@child_first_name, @child_last_name, @date_of_birth, @emergency_contact_number, @emergency_contact_first_name, @emergency_contact_last_name, (SELECT class_id FROM class WHERE class_name = @class_name), @parent_id_number);

                PRINT 'Child has been successfully entered into the system.';
            END
            ELSE
            BEGIN
                PRINT 'This parent already has a child in the system.';
            END
        END
        ELSE
        BEGIN
            PRINT 'Parent does not exist in the system. Please add parent first.';
        END
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        PRINT 'Error: Unable to insert child or parent into the system.';
        PRINT 'Error Message: ' + @ErrorMessage;
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;