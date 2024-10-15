-- EXEC addAdmin 'Adolf', 'Pass@123', 'adolfdavid17@gmail.com', '0816166875'
-- Use this to test and see the values needed for this procedure
--EXEC viewAdmin

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

