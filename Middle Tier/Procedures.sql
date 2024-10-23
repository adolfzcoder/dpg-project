CREATE DATABASE qrSystemDPG
USE qrSystemDPG
DROP DATABASE qrSystemDPG


-- these procedures can be used to quickly view the stored data instead of using longer select statement



CREATE PROC viewAdmin
AS
BEGIN

SELECT * FROM adminTable

END
-- EXEC viewAdmin


CREATE PROC viewChild
AS
BEGIN

SELECT * FROM child

END

CREATE PROC viewClass
AS
BEGIN
	SELECT * FROM class
END
-- EXEC viewClass
-- EXEC viewChild







CREATE PROC viewParent
AS
BEGIN

SELECT * FROM parent

END

CREATE PROC viewQr
AS
BEGIN

SELECT * FROM qrCode

END

-- EXEC addAdmin 'Adolf', 'Pass@123', 'adolfdavid17@gmail.com', '0816166875'
-- Use this to test and see the values needed for this procedure
--EXEC viewAdmin


CREATE PROCEDURE spHandleError
AS
BEGIN
    DECLARE @ErrorNumber INT,
            @ErrorSeverity INT,
            @ErrorProcedure NVARCHAR(128),
            @ErrorMessage NVARCHAR(4000);

    -- Retrieve error details
    SET @ErrorNumber = ERROR_NUMBER();
    SET @ErrorSeverity = ERROR_SEVERITY();
    SET @ErrorProcedure = ERROR_PROCEDURE();
    SET @ErrorMessage = ERROR_MESSAGE();

    PRINT 'Error Number: ' + CAST(@ErrorNumber AS VARCHAR(10));
    PRINT 'Error Severity: ' + CAST(@ErrorSeverity AS VARCHAR(10));
    PRINT 'Error Procedure: ' + ISNULL(@ErrorProcedure, 'N/A');
    PRINT 'Error Message: ' + @ErrorMessage;


END;



-- In order to allow adding a new admin, we have to make sure that the user that is trying to add a new admin has a role of superadmin. Their role is set when they login, using the spAdminLoginVerification procedure. We store the information about logged in user in session context values, which we can later use. We can then compare the role of the currently logged to check if its a regular admin or superadmin.


-- Use this to test and see the values needed for this procedure
--EXEC viewAdmin



INSERT INTO adminTable(username, password, email, role, phone_number) 
VALUES ('Adolf', 'Pass@123', 'adolfdavid17@gmail.com', '0816166875', 'superadmin')

EXEC spAddAdmin 'Adolf', 'Pass@123', 'adolfdavid17@gmail.com', '0816166875', 'superadmin'
EXEC spAddAdmin 'Jimmy', 'Pass@123', 'jummy@gmail.com', '08162781234', 'admin'
EXEC spAddAdmin 'Linda', 'Pass@123', 'linda@gmail.com', '0817958678', 'admin'

EXEC viewAdmin 

ALTER PROCEDURE spAddAdmin
    @username VARCHAR(30),
    @password VARCHAR(50),
    @email VARCHAR(45),
    @phone_number CHAR(10),
	@role VARCHAR(10)
AS
BEGIN
    DECLARE @admin_role VARCHAR(20);
    DECLARE @existing_email VARCHAR(45);
    DECLARE @email_exists INT = 0;

    -- Retrieve the admin role from the session context and convert it to varchar
    SELECT @admin_role = CONVERT(VARCHAR(20), SESSION_CONTEXT(N'admin_role'));

    -- Check if the admin role is 'superadmin'
    IF @admin_role <> 'superadmin'
    BEGIN
        PRINT 'Error: Only superadmins can add new admins.';
        RETURN;
    END
	PRINT @role;
	IF LOWER(@role) NOT IN ('superadmin', 'admin')
	BEGIN
		PRINT 'Error: Role should be Superadmin or Admin';
		RETURN;
	END
    -- Make sure the username is not empty and contains only letters
    IF @username NOT LIKE '%[^A-Za-z]%' AND LEN(@username) > 0
    BEGIN
        -- Check if the phone number contains only numbers and is exactly 10 characters long
        IF @phone_number NOT LIKE '%[^0-9]%' AND LEN(@phone_number) = 10
        BEGIN
            -- Validate email format
            IF @email LIKE '%_@__%.__%'
            BEGIN
                BEGIN TRY
                    BEGIN TRANSACTION;

                    -- Declare and open the cursor to check for email existence
                    DECLARE emailCursor CURSOR FOR 
                    SELECT email FROM adminTable WHERE email = @email;

                    OPEN emailCursor;
                    FETCH NEXT FROM emailCursor INTO @existing_email;

                    -- Check if any email is fetched
                    IF @@FETCH_STATUS = 0
                    BEGIN
                        SET @email_exists = 1; -- Email exists
                    END

                    CLOSE emailCursor;
                    DEALLOCATE emailCursor;

                    -- If email already exists, rollback and return an error
                    IF @email_exists = 1
                    BEGIN
                        PRINT 'Error: Email already exists';
                        ROLLBACK TRANSACTION;
                        RETURN;
                    END

                    -- Insert the new admin into the adminTable
                    INSERT INTO adminTable (username, password, email, phone_number)
                    VALUES (@username, @password, @email, @phone_number);

                    COMMIT TRANSACTION;
                    PRINT 'Admin record added successfully.';
                END TRY
                BEGIN CATCH
                    ROLLBACK TRANSACTION;
                    PRINT 'There was an error inserting into the system, please try again.';

                    -- Handle specific errors
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
            END
            ELSE
            BEGIN
                PRINT 'Error: Invalid email format.';
            END
        END
        ELSE
        BEGIN
            PRINT 'Error: Phone number should contain only numbers and be exactly 10 characters long.';
        END
    END
    ELSE
    BEGIN
        PRINT 'Error: Username should contain only letters.';
    END
END;


EXEC spAdminLoginVerification 'adolfdavid17@gmail.com', 'Pass@123'
-- DELETE  FROM adminTable

-- to keep track of the logged in admin, we use sessions, and we set the session context values for the logged in admin. That way we store, the admin username, the admin id, the admin role and the admin email, anywhere in the system, just by accessing the session variable



EXEC spAdminLoginVerification 'jummy@gmail.com', 'Pass@123'
EXEC spAdminLoginVerification 'adolfdavid17@gmail.com', 'Pass@123'

CREATE PROCEDURE spAdminLoginVerification
@email VARCHAR(45),
@password VARCHAR(255)
AS
BEGIN
    DECLARE @stored_password VARCHAR(50);
    DECLARE @email_exists INT;
    DECLARE @admin_username VARCHAR(30);
    DECLARE @admin_role VARCHAR(20);
    DECLARE @admin_email VARCHAR(45);
     DECLARE @admin_id INT; -- this value is stroed in the session, which is set after the admin logs in

    BEGIN TRY
                    --email should be in valid email format

        IF @email LIKE '%_@__%.__%'
        BEGIN
            -- Check if the email already exists
            SELECT @email_exists = COUNT(*)
            FROM adminTable
            WHERE email = @email;

            IF @email_exists > 0
            BEGIN


            
                -- Get stored password
                SELECT @stored_password = password,
                       @admin_username = username,
                       @admin_role = role,
                       @admin_email = email,
                       @admin_id = admin_id
                FROM adminTable
                WHERE email = @email;

                -- Compare the passwords
                IF @stored_password = @password
                BEGIN
                    PRINT 'Successfully logged in';
                    -- Set session context values
                    EXEC sp_set_session_context @key = N'admin_username', @value = @admin_username;
                    EXEC sp_set_session_context @key = N'admin_role', @value = @admin_role;
                    EXEC sp_set_session_context @key = N'admin_email', @value = @admin_email;
                    EXEC sp_set_session_context @key = N'admin_id', @value = @admin_id;

                    -- SELECT -- outputting for testing the logged in admin
                    -- SESSION_CONTEXT(N'admin_username') AS AdminUsername,
                    -- SESSION_CONTEXT(N'admin_role') AS AdminRole,
                    -- SESSION_CONTEXT(N'admin_email') AS AdminEmail;
                END
                ELSE
                BEGIN
                    PRINT 'Password is incorrect';
                END
            END
            ELSE
            BEGIN
                PRINT 'Email does not exist';
            END
        END
        ELSE
        BEGIN
            PRINT 'Error: Invalid email format';
        END
    END TRY
    BEGIN CATCH
        PRINT 'An error occurred during login verification';

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




-- 1. parent Id Number 11 digits long (for namibian id numbers)
-- 2. First name
-- 3. Last name
-- 4. Phone number 10 digits long (for namibian numbers)
-- 5. Email 
-- 
EXEC spAddParent '82010154321', 'Anna', 'Kavango', '0819876543', 'annakavango@example.com', 'Windhoek', 'F'
EXEC spAddParent '99051790321', 'Adolf', 'Chikombo', '0816166785', 'adavid@muhoko.org', 'Otjiarare', 'M'
CREATE PROCEDURE spAddParent
    @parent_id_number CHAR (11),
    @first_name VARCHAR(30),
    @last_name VARCHAR(30),
    @phone_number CHAR(10),
    @email VARCHAR(45),
    @home_address VARCHAR (30),
    @gender CHAR(1)
AS
BEGIN
    IF @first_name NOT LIKE '%[^A-Za-z]%' AND LEN(@first_name) > 0
    BEGIN
        IF @last_name NOT LIKE '%[^A-Za-z]%' AND LEN(@last_name) > 0
        BEGIN
            IF LEN(@phone_number) = 10
            BEGIN
                IF LOWER(@gender) LIKE 'm' OR LOWER(@gender) LIKE 'f'
                BEGIN
                    IF @gender LIKE 'm'
                    BEGIN
                        SET @gender = 'M';
                    END
                    ELSE
                    BEGIN
                        SET @gender = 'F';
                    END

                    IF @home_address NOT LIKE '%[^A-Za-z]%' AND LEN(@home_address) > 0
                    BEGIN
                        BEGIN TRY
                            BEGIN TRANSACTION
                                INSERT INTO parent(parent_id_number, first_name, last_name, phone_number, email, home_address, gender)
                                VALUES(@parent_id_number, @first_name, @last_name, @phone_number, @email, @home_address, @gender)
                            COMMIT TRANSACTION
                            PRINT 'Parent record added successfully'
                        END TRY
                        BEGIN CATCH
                            ROLLBACK TRANSACTION
                            PRINT 'There was an error inserting into system, please try again';
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
                    END
                    ELSE
                    BEGIN
                        PRINT 'Error: Town should only have letters, not special characters.';
                    END
                END
                ELSE
                BEGIN
                    PRINT 'Please enter a valid gender, either male or female';
                END
            END
            ELSE
            BEGIN
                PRINT 'Error: Phone number should be exactly 10 characters long.';
            END
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
END;
-- 




EXEC spAddClass 'Nursery', '08:00:00', 'Room 101', 'yes', '12:00:00', 1, 2
EXEC spAddClass 'Day Care', '09:00:00', 'Room 102', 'no', '13:00:00', 3, 5
EXEC spAddClass 'Kindergarten', '08:30:00', 'Room 103', 'yes', '12:30:00', 6, 8
EXEC spAddClass 'Grade 1', '09:00:00', 'Room 104', 'yes', '14:00:00', 7 ,9
EXEC spAddClass 'Grade 2', '09:00:00', 'Room 105', 'yes', '14:00:00', 10, 12
EXEC spAddClass 'Grade 3', '09:00:00', 'Room 106', 'yes', '14:00:00', 13, 17

-- Verify the inserted data
SELECT * FROM class;

CREATE PROCEDURE spAddClass
    @class_name VARCHAR(30),
    @start_time TIME,
    @venue VARCHAR(30),
    @has_projector VARCHAR(3),
    @end_time TIME,
    @age_range_start INT,
    @age_range_end INT
AS
BEGIN
    -- Validate class name for special characters
    IF @class_name LIKE '%[^a-zA-Z0-9 ]%'
    BEGIN
        RAISERROR('Class name contains special characters.', 16, 1);
        RETURN;
    END

    IF LEN(@class_name) = 0
    BEGIN
        RAISERROR('Class name cannot be empty.', 16, 1);
        RETURN;
    END 

    IF LOWER(@has_projector) NOT IN ('yes', 'no')
    BEGIN
        RAISERROR('Invalid value for has_projector. It must be either "yes" or "no".', 16, 1);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO class (class_name, start_time, venue, has_projector, end_time, age_range_start, age_range_end)
        VALUES (@class_name, @start_time, @venue, @has_projector, @end_time, @age_range_start, @age_range_end);

        COMMIT TRANSACTION;
        PRINT 'Class added successfully.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'An error occurred while adding the class.';
    END CATCH
END;


-- How to use this procedure

-- EXEC spAddChild 'John', 'Kavango', '2010-05-15', '0811234567', 'Peter', 'Kavango', 'Math 101', '82010154321'





CREATE PROCEDURE spAddChild
    @child_first_name VARCHAR(30),
    @child_last_name VARCHAR(30),
    @date_of_birth DATE,
    @emergency_contact_number CHAR(10),
    @emergency_contact_first_name VARCHAR(30),
    @emergency_contact_last_name VARCHAR(30),
    @gender CHAR(1),
    @parent_id_number CHAR(11)
AS
BEGIN
        -- names do not contain special characters (!@#$%^&*()) and shouldnt be empyt
    IF @child_first_name NOT LIKE '%[^A-Za-z]%' AND LEN(@child_first_name) > 0
    BEGIN
        -- names do not contain special characters (!@#$%^&*()) and shouldnt be empyt
        IF @child_last_name NOT LIKE '%[^A-Za-z]%' AND LEN(@child_last_name) > 0
        BEGIN
        -- names do not contain special characters (!@#$%^&*()) and shouldnt be empyt
            IF @emergency_contact_first_name NOT LIKE '%[^A-Za-z]%' AND LEN(@emergency_contact_first_name) > 0
            BEGIN
        -- names do not contain special characters (!@#$%^&*()) and shouldnt be empyt
                IF @emergency_contact_last_name NOT LIKE '%[^A-Za-z]%' AND LEN(@emergency_contact_last_name) > 0
                BEGIN
                    -- phone number should not contain special characters and only 10 characters
                    IF @emergency_contact_number NOT LIKE '%[^0-9]%' AND LEN(@emergency_contact_number) = 10
                    BEGIN
                        -- Namibian id numbers are only 11 digits long. if it's longer than that or has special characters, throw error
                        IF @parent_id_number NOT LIKE '%[^0-9]%' AND LEN(@parent_id_number) = 11
                        BEGIN
                            IF LOWER(@gender) LIKE 'm' OR LOWER(@gender) LIKE 'f'
                            BEGIN
                                IF @gender LIKE 'm'
                                BEGIN
                                    SET @gender = 'M';
                                END
                                ELSE
                                BEGIN
                                    SET @gender = 'F';
                                END

                                IF @date_of_birth <= GETDATE()
                                BEGIN
                                    -- Calculate the child's age
                                    DECLARE @child_age INT;
                                    SET @child_age = DATEDIFF(YEAR, @date_of_birth, GETDATE());

                                    -- Check if the child's age is greater than 17
                                    IF @child_age > 17 
                                    BEGIN
                                        PRINT 'Error: Age should be 17 years or less.';
                                        RETURN;
                                    END

                                    IF @child_age < 0 
                                    BEGIN
                                        PRINT 'Error: Age should be more than 1 or more years';
                                        RETURN;
                                    END

                                    -- Find the appropriate class for the child's age
                                    DECLARE @class_id INT;
                                    SELECT TOP 1 @class_id = class_id
                                    FROM class
                                    WHERE @child_age BETWEEN age_range_start AND age_range_end;

                                    IF @class_id IS NOT NULL
                                    BEGIN
                                        BEGIN TRY
                                            BEGIN TRANSACTION;

                                            -- make sure parent exists before insert
                                            IF EXISTS (SELECT 1 FROM parent WHERE parent_id_number = @parent_id_number)
                                            BEGIN
                                                -- make sure child does not already exist before insert
                                                IF NOT EXISTS (SELECT 1 FROM child WHERE parent_id_number = @parent_id_number)
                                                BEGIN
                                                    INSERT INTO child (first_name, last_name, date_of_birth, emergency_contact_number, emergency_contact_first_name, emergency_contact_last_name, gender, class_id, parent_id_number)
                                                    VALUES (@child_first_name, @child_last_name, @date_of_birth, @emergency_contact_number, @emergency_contact_first_name, @emergency_contact_last_name, @gender, @class_id, @parent_id_number);

                                                    COMMIT TRANSACTION;
                                                    PRINT 'Child record added successfully.';
                                                END
                                                ELSE
                                                BEGIN
                                                    PRINT 'Error: Parent already has a child.';
                                                    ROLLBACK TRANSACTION;
                                                END
                                            END
                                            ELSE
                                            BEGIN
                                                PRINT 'Error: Parent does not exist.';
                                                ROLLBACK TRANSACTION;
                                            END
                                        END TRY
                                        BEGIN CATCH
                                            ROLLBACK TRANSACTION;
                                            PRINT 'There was an error inserting into system, please try again';
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
                                    END
                                    ELSE
                                    BEGIN
                                        PRINT 'Error: No appropriate class found for the child s age.';
                                    END
                                END
                                ELSE
                                BEGIN
                                    PRINT 'Error: Date of birth cannot be greater than the current date.';
                                END
                            END
                            ELSE
                            BEGIN
                                PRINT 'Error: Gender should be either male or female.';
                            END
                        END
                        ELSE
                        BEGIN
                            PRINT 'Error: Parent ID number should contain only numbers and be exactly 11 characters long.';
                        END
                    END
                    ELSE
                    BEGIN
                        PRINT 'Error: Emergency contact number should contain only numbers and be exactly 10 characters long.';
                    END
                END
                ELSE
                BEGIN
                    PRINT 'Error: Emergency contact last name should contain only letters.';
                END
            END
            ELSE
            BEGIN
                PRINT 'Error: Emergency contact first name should contain only letters.';
            END
        END
        ELSE
        BEGIN
            PRINT 'Error: Child last name should contain only letters.';
        END
    END
    ELSE
    BEGIN
        PRINT 'Error: Child first name should contain only letters.';
    END
END;






INSERT INTO child (child_id, first_name, last_name, date_of_birth, parent_id_number)
VALUES 
('John', 'Kavango', '2010-05-15', '82010154321');


EXEC viewQr
-- 1. Child First Name
-- 2. Child last Name
-- 3. Parent Id Number (get this from the parent table, use 'SELECT * FROM parent' to find the id number for that parent
-- 4. UUID code from child
-- 5. UUID code from Parent

EXEC spPickupVerification 'John', 'Kavango', '82010154321', 'BA9A2F9C-DA3F-41', 'BA9A2F9C-DA3F-41'

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
        DECLARE @end_pos INT = CHARINDEX('&qzone=', @qr_code_url);

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







EXEC spPickupVerification 'John', 'Kavango', '82010154321', 'BA9A2F9C-DA3F-41', 'BA9A2F9C-DA3F-41'

EXEC viewChild

SELECT * FROM qrcode 
EXEC viewQr

DELETE FROM qrcode -- Delete all data from qr code atable

EXEC spGenerateQrCode 'John', 'Kavango'
-- 1. First Name
-- 2. last Name

ALTER PROCEDURE spGenerateQrCode
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
    DECLARE @uuid UNIQUEIDENTIFIER = NEWID();
    DECLARE @short_uuid VARCHAR(16);

    BEGIN TRY
        -- names do not contain special characters (!@#$%^&*()) and shouldnt be empyt
        IF @first_name NOT LIKE '%[^A-Za-z]%' AND LEN(@first_name) > 0
        BEGIN
            -- names do not contain special characters (!@#$%^&*()) and shouldnt be empyt
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

                -- qr code url generation. Girst uuid(Universally unique identifier ) is created, then it is converted to varchar of 16, it is typically 36, so need to ocnvert it to 16. Then truncate or Concatenate it to the url, where data= and until &qzone=4
                SET @short_uuid = LEFT(CONVERT(VARCHAR(36), @uuid), 16);
                SET @qr_code_url = 'https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=' + @short_uuid + '&qzone=4';

                INSERT INTO qrcode (qr_code_url, drop_off_time, drop_off_date, parent_id_number, child_id, picked_up)
                VALUES (@qr_code_url, @drop_off_time, @drop_off_date, @parent_id_number, @child_id, 0);


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

DECLARE @qr_code_url VARCHAR(255);

EXEC spGenerateQrCode 
    @first_name = 'John', 
    @last_name = 'Kavango', 
    @qr_code_url_out = @qr_code_url OUTPUT;

PRINT 'Generated QR Code URL: ' + @qr_code_url;




EXEC spAddChild 'John', 'Kavango', '2018-05-15', '0811234567', 'Peter', 'Kavango', 'Male', '82010154321'

EXEC viewParent
EXEC viewChild









-- CREATE TABLE reports (
--     report_id INT PRIMARY KEY IDENTITY,
--     report_date DATE NOT NULL,
--     report_content VARCHAR(MAX) NOT NULL,
--     generated_at DATETIME DEFAULT GETDATE()
-- );

CREATE PROCEDURE spGenerateDailyReport
    @reportDate DATE
AS
BEGIN
    DECLARE @reportContent VARCHAR(MAX);

    -- Generate report content based on the provided date
    SET @reportContent = (
        SELECT 
            'Class Report: ' + CHAR(13) + CHAR(10) +
            'Total Classes: ' + CAST(COUNT(*) AS VARCHAR) + CHAR(13) + CHAR(10) +
            'Total Students: ' + CAST((SELECT COUNT(*) FROM child) AS VARCHAR) + CHAR(13) + CHAR(10) +
            'Total Parents: ' + CAST((SELECT COUNT(*) FROM parent) AS VARCHAR) + CHAR(13) + CHAR(10) +
            'Total QR Codes: ' + CAST((SELECT COUNT(*) FROM qrcode WHERE drop_off_date = @reportDate) AS VARCHAR) + CHAR(13) + CHAR(10) +
            'Total Pickups: ' + CAST((SELECT COUNT(*) FROM pickup WHERE pickup_date = @reportDate) AS VARCHAR) + CHAR(13) + CHAR(10)
        FROM class
    );

    -- Insert the generated report into the reports table
    INSERT INTO reports (report_date, report_content)
    VALUES (@reportDate, @reportContent);

    PRINT 'Daily report generated and inserted successfully.';

    -- Select and return the inserted report
    SELECT * FROM reports WHERE report_date = @reportDate;
END;


