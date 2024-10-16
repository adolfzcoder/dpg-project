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

-- EXEC addAdmin 'Adolf', 'Pass@123', 'adolfdavid17@gmail.com', '0816166875'
-- EXEC viewAdmin

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


EXEC spAdminLoginVerification 'adolfdavid17@gmail.com', 'Pass@123'
-- DELETE  FROM adminTable


CREATE PROCEDURE spAdminLoginVerification
@email VARCHAR(45),
@password VARCHAR(50)
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
			-- Retrieve the stored password
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
('82010154321', 'Anna', 'Kavango', '0819876543', 'annakavango@example.com', 'Windhoek');

INSERT INTO child (child_id, first_name, last_name, date_of_birth, parent_id_number)
VALUES 
('John', 'Kavango', '2010-05-15', '82010154321');

EXEC spGenerateQrCode 'John', 'Kavango'

EXEC viewChild

SELECT qr_code_url FROM qrcode 
EXEC viewQr
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
	DECLARE @picked_up BINARY;

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
    FROM child
    WHERE child_id = @child_id;


	SELECT @picked_up = picked_up 
	FROM qrcode
	WHERE child_id = @child_id;

    IF @parent_id_number IS NULL
    BEGIN
        PRINT 'Parent not found';
        RETURN;
    END
	IF @picked_up = 1
	BEGIN
         SET @qr_code_url = 'https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=' + @first_name + '_' + @last_name + '_' + CONVERT(VARCHAR, @timestamp, 120) + '&color=f3846c';
    INSERT INTO qrcode (qr_code_url, drop_off_time, drop_off_date, parent_id_number, child_id, picked_up)
    VALUES (@qr_code_url, @drop_off_time, @drop_off_date, @parent_id_number, @child_id, 0);

    PRINT 'QR code generated and stored successfully';
	END

	ELSE
	BEGIN
	PRINT 'Cannot generate qr code. Child is not yet picked up';
	END;
END;



-- INSERT INTO parent (parent_id_number, first_name, last_name, phone_number, email, town)
-- VALUES 
-- ('82010154321', 'Anna', 'Kavango', '0819876543', 'annakavango@example.com', 'Windhoek')


-- exec viewParent
-- ('John', 'Kavango', '2010-05-15', '0811234567', 'Peter', 'Kavango', 'Math 101', '82010154321'),

EXEC spAddChild 'John', 'Kavango', '2010-05-15', '0811234567', 'Peter', 'Kavango', 'Math 101', '82010154321'

EXEC viewParent
EXEC viewChild

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
        -- Check if the parent exists
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