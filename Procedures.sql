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


ALTER PROCEDURE addAdmin
@username VARCHAR(30),
@password VARCHAR(50),
@email VARCHAR(45),
@phone_number CHAR(10)
AS
BEGIN
    DECLARE @email_exists INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        --check if the email already exists
        SELECT @email_exists = COUNT(*)
        FROM adminTable
        WHERE email = @email;

        IF @email_exists > 0
        BEGIN
            PRINT 'Email already exists';
            ROLLBACK TRANSACTION;
            RETURN;
        END

       
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




EXEC adminLoginVerification 'adolfdavid17@gmail.com', 'Pass@123'


ALTER PROCEDURE adminLoginVerification
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