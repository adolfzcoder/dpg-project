CREATE DATABASE qrSystemDPG
USE qrSystemDPG


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


EXEC spAddAdmin 'Adolf', 'Pass@123', 'adolfdavid17@gmail.com', '0816166875'
EXEC viewAdmin

-- DELETE FROM adminTable

-- EXEC addAdmin 'Adolf', 'Pass@123', 'adolfdavid17@gmail.com', '0816166875'
-- Use this to test and see the values needed for this procedure
--EXEC viewAdmin

-- DELETE FROM adminTable
-- EXEC addAdmin 'Adolf', 'Pass@123', 'adolfdavid17@gmail.com', '0816166875'
-- Use this to test and see the values needed for this procedure
--EXEC viewAdmin

-- DELETE FROM adminTable

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


CREATE PROCEDURE spAddAdmin
@username VARCHAR(30),
@password VARCHAR(50),
@email VARCHAR(45),
@phone_number CHAR(10)
AS
BEGIN
    DECLARE @email_exists INT;

    --make sure username is not empty and contains only letters
    IF @username NOT LIKE '%[^A-Za-z]%' AND LEN(@username) > 0
    BEGIN
        -- same with phone number, only contianing number and not empty
        IF @phone_number NOT LIKE '%[^0-9]%' AND LEN(@phone_number) = 10
        BEGIN
            --email should be in valid email format
            IF @email LIKE '%_@__%.__%'
            BEGIN
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
                    PRINT 'Admin record added successfully.';
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


EXEC viewChild;
EXEC viewClass




INSERT INTO parent (parent_id_number, first_name, last_name, phone_number, email, home_address)
VALUES 
('99051790321', 'Adolf', 'Chikombo', '0816166785', 'adavid@muhoko.org', 'Otjiarare')

,
('82010154321', 'Anna', 'Kavango', '0819876543', 'annakavango@example.com', 'Windhoek');

INSERT INTO child (child_id, first_name, last_name, date_of_birth, parent_id_number)
VALUES 
('John', 'Kavango', '2010-05-15', '82010154321');


DELETE FROM qrcode
EXEC spGenerateQrCode 'John', 'Kavango'
EXEC viewQr
EXEC viewChild
SELECT qr_code_url FROM qrcode 

DELETE FROM qrcode
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

                SET @qr_code_url = 'https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=' + @first_name + '_' + @last_name + '_' + CONVERT(VARCHAR, @timestamp, 120) + '&color=f3846c&qzone=4';

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

-- INSERT INTO parent (parent_id_number, first_name, last_name, phone_number, email, home_address)
-- VALUES 
-- ('82010154321', 'Anna', 'Kavango', '0819876543', 'annakavango@example.com', 'Windhoek')


-- exec viewParent
-- ('John', 'Kavango', '2010-05-15', '0811234567', 'Peter', 'Kavango', 'Math 101', '82010154321'),

EXEC spAddChild 'John', 'Kavango', '2010-05-15', '0811234567', 'Peter', 'Kavango', 'Math 101', '82010154321'

EXEC viewParent
EXEC viewChild

-- How to use this procedure

-- EXEC spAddChild 'John', 'Kavango', '2010-05-15', '0811234567', 'Peter', 'Kavango', 'Math 101', '82010154321'

-- EXEC viewParent
-- EXEC viewChild
-- CREATE TABLE child (
--     child_id INT PRIMARY KEY IDENTITY,
--     first_name VARCHAR(30) NOT NULL,
--     last_name VARCHAR(30) NOT NULL,
--     date_of_birth DATE,
--     emergency_contact_number CHAR(10) NOT NULL UNIQUE,
--     emergency_contact_firsst_name VARCHAR(30),
--     emergency_contact_last_name VARCHAR(30),
--     gender CHAR(1) NOT NULL,
--     class_id INT,
--     parent_id_number CHAR(11) NOT NULL UNIQUE,  -- Enforce one-to-one relationship
--     FOREIGN KEY (parent_id_number) REFERENCES parent(parent_id_number),
--     FOREIGN KEY (class_id) REFERENCES class(class_id)
-- );






-- CREATE TABLE child (
--     child_id INT PRIMARY KEY IDENTITY,
--     first_name VARCHAR(30) NOT NULL,
--     last_name VARCHAR(30) NOT NULL,
--     date_of_birth DATE,
--     emergency_contact_number CHAR(10) NOT NULL UNIQUE,
--     emergency_contact_firsst_name VARCHAR(30),
--     emergency_contact_last_name VARCHAR(30),
--     gender CHAR(1) NOT NULL,
--     class_id INT,
--     parent_id_number CHAR(11) NOT NULL UNIQUE,  -- Enforce one-to-one relationship
--     FOREIGN KEY (parent_id_number) REFERENCES parent(parent_id_number),
--     FOREIGN KEY (class_id) REFERENCES class(class_id)
-- );






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
    -- name should not be empty and should not contain special character
    IF @child_first_name NOT LIKE '%[^A-Za-z]%' AND LEN(@child_first_name) > 0
    BEGIN
        -- name should not be empty and should not contain special character
        IF @child_last_name NOT LIKE '%[^A-Za-z]%' AND LEN(@child_last_name) > 0
        BEGIN
            -- name should not be empty and should not contain special character
            IF @emergency_contact_first_name NOT LIKE '%[^A-Za-z]%' AND LEN(@emergency_contact_first_name) > 0
            BEGIN
                -- name should not be empty and should not contain special character
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

























-- Insert sample data into the class table
INSERT INTO class (class_name, start_time, venue, has_projector, end_time, age_range_start, age_range_end)
VALUES 
('Nursery', '08:00', 'Room 101', 0, '12:00', 'TCH001', 3, 4),
('Pre-K', '08:00', 'Room 102', 1, '12:00', 'TCH002', 4, 5),
('Kindergarten', '08:00', 'Room 103', 1, '12:00', 'TCH003', 5, 6);




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


CREATE PROCEDURE spAddClass
    @class_name VARCHAR(30),
    @start_time TIME,
    @venue VARCHAR(30),
    @has_projector BIT,
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

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Insert class details
        INSERT INTO class (class_name, start_time, venue, has_projector, end_time, age_range_start, age_range_end)
        VALUES (@class_name, @start_time, @venue, @has_projector, @endTime, @ageRangeStart, @ageRangeEnd);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Rollback transaction in case of error
        ROLLBACK TRANSACTION;

        -- Call the error handling procedure
        EXEC spHandleError;
    END CATCH
END;

