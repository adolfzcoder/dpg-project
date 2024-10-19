-- these procedures can be used to quickly view the stored data instead of using longer select statement
USE childChurchQrSystem
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

CREATE PROC viewTeacher
AS
BEGIN

SELECT * FROM teacher

END


-- EXEC viewTeacher


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
                    PRINT 'There was an error inserting into system';
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


EXEC spAdminLoginVerification 'adolfdavid17@gmail.com', 'Pass@123'
-- to keep track of the logged in admin, we use sessions, and we set the session context values for the logged in admin
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
    DECLARE @admin_id INT;

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
    END CATCH
END;



EXEC viewChild;
EXEC viewClass
EXEC viewTeacher
DELETE FROM teacher
INSERT INTO teacher (teacher_id_number, first_name, last_name, phone_number, email, town, office_room_number)
VALUES 
('98031712345', 'Petrus', 'Nangolo', '0812345678', 'petrusnangolo@example.com', 'Windhoek', 101),
('85020256789', 'Maria', 'Kandjii', '0818765432', 'mariakandjii@example.com', 'Swakopmund', 102),
('90030391012', 'Johannes', 'Shilongo', '0811122334', 'johannesshilongo@example.com', 'Walvis Bay', 103),
('87040411223', 'Elina', 'Amutenya', '0812233445', 'elinaamutenya@example.com', 'Oshakati', 104),
('95050533444', 'Samuel', 'Kaunda', '0813344556', 'samuelkaunda@example.com', 'Rundu', 105);


INSERT INTO class (class_name, start_time, venue, has_projector, end_time, teacher_id_number)
VALUES 
('Math 101', '08:00:00', 'Room 201', 1, '09:30:00', '98031712345'),
('Science 101', '09:45:00', 'Room 202', 0, '11:15:00', '85020256789'),
('History 101', '11:30:00', 'Room 203', 1, '13:00:00', '90030391012'),
('Art 101', '13:15:00', 'Room 204', 0, '14:45:00', '87040411223'),
('Music 101', '15:00:00', 'Room 205', 1, '16:30:00', '95050533444');

INSERT INTO parent (parent_id_number, first_name, last_name, phone_number, email, town)
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
    END CATCH
END;
-- INSERT INTO parent (parent_id_number, first_name, last_name, phone_number, email, town)
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
CREATE PROC spAddChild
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
    -- name should not be empty and should not contain special character
    IF @child_first_name NOT LIKE '%[^A-Za-z]%' AND LEN(@child_first_name) > 0
    BEGIN
    -- name should not be empty and should not contain special character
        IF @child_last_name NOT LIKE '%[^A-Za-z]%' AND LEN(@child_last_name) > 0
        BEGIN
        --name should not be empty and should not contain special character
            IF @emergency_contact_first_name NOT LIKE '%[^A-Za-z]%' AND LEN(@emergency_contact_first_name) > 0
            BEGIN
            -- name should not be empty and should not contain special character
                IF @emergency_contact_last_name NOT LIKE '%[^A-Za-z]%' AND LEN(@emergency_contact_last_name) > 0
                BEGIN
                    -- phone number should not contian special characters na donly 10 characters
                    IF @emergency_contact_number NOT LIKE '%[^0-9]%' AND LEN(@emergency_contact_number) = 10
                    BEGIN
                        --Namibian id numbers are only 11 digits long. if its longer than that or has special characters, throw error
                        IF @parent_id_number NOT LIKE '%[^0-9]%' AND LEN(@parent_id_number) = 11
                        BEGIN
                            
                            IF @date_of_birth <= GETDATE()
                            BEGIN
                                BEGIN TRY
                                    BEGIN TRANSACTION;

                                    -- make sure parent exists befor einsert
                                    IF EXISTS (SELECT 1 FROM parent WHERE parent_id_number = @parent_id_number)
                                    BEGIN
                                    -- make sure child exists befor einsert
                                        IF NOT EXISTS (SELECT 1 FROM child WHERE parent_id_number = @parent_id_number)
                                        BEGIN
                                            INSERT INTO child (child_first_name, child_last_name, date_of_birth, emergency_contact_number, emergency_contact_first_name, emergency_contact_last_name, class_name, parent_id_number)
                                            VALUES (@child_first_name, @child_last_name, @date_of_birth, @emergency_contact_number, @emergency_contact_first_name, @emergency_contact_last_name, @class_name, @parent_id_number);

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
                                    PRINT 'There was an error inserting into system';
                                END CATCH
                            END
                            ELSE
                            BEGIN
                                PRINT 'Error: Date of birth cannot be greater than the current date.';
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








EXEC spAddTeacher '0008178803', 'Joana', 'Lojiko', '0817194729', 'jlojiko@yahoo.com', 'Omangongatti', '404'
EXEC viewTeacher

ALTER PROCEDURE spAddTeacher
@teacher_id_number CHAR(11),
@first_name VARCHAR(30),
@last_name VARCHAR(30),
@phone_number CHAR(10),
@email VARCHAR(45),
@town VARCHAR(30),  
@office_room_number INT
AS
BEGIN
  IF @first_name NOT LIKE '%[^A-Za-z]%' AND LEN(@first_name) > 0
  BEGIN
    IF @last_name NOT LIKE '%[^A-Za-z]%' AND LEN(@last_name) > 0
    BEGIN
      IF LEN(@phone_number) = 10
      BEGIN
        IF @town NOT LIKE '%[^A-Za-z]%' AND LEN(@town) > 0
        BEGIN
          IF ISNUMERIC(@office_room_number) = 1
          BEGIN
            BEGIN TRY
              BEGIN TRANSACTION
              
              INSERT INTO teacher(teacher_id_number, first_name, last_name, phone_number, email, town, office_room_number)
              VALUES(@teacher_id_number , @first_name, @last_name, @phone_number, @email, @town, @office_room_number);

              COMMIT TRANSACTION
              PRINT 'Teacher record added successfully.';
            END TRY
            BEGIN CATCH
              ROLLBACK TRANSACTION
              PRINT 'There was an error inserting into system';
            END CATCH
          END
          ELSE
          BEGIN
            PRINT 'Error: Office room number should be a valid number.';
          END
        END
        ELSE
        BEGIN
          PRINT 'Error: Town should contain only letters.';
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