-- EXEC addAdmin 'Adolf', 'Pass@123', 'adolfdavid17@gmail.com', '0816166875'
-- Use this to test and see the values needed for this procedure
--EXEC viewAdmin

-- DELETE FROM adminTable
-- CREATE TABLE adminTable (
--     admin_id INT PRIMARY KEY IDENTITY,
--     username VARCHAR(30) NOT NULL UNIQUE,
--     password VARCHAR(255) NOT NULL,
--     email VARCHAR(45) NOT NULL UNIQUE,
--     role VARCHAR(20) DEFAULT 'admin',  -- 'admin' or 'superadmin', superadmins can add other admins
--     phone_number CHAR(10) UNIQUE,
--     created_at DATETIME DEFAULT GETDATE()
-- );


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