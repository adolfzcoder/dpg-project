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

-- In order to allow adding a new admin, we have to make sure that the user that is trying to add a new admin has a role of superadmin. Their role is set when they login, using the spAdminLoginVerification procedure. We store the information about logged in user in session context values, which we can later use. We can then compare the role of the currently logged to check if its a regular admin or superadmin.
CREATE PROCEDURE spAddAdmin
@username VARCHAR(30),
@password VARCHAR(50),
@email VARCHAR(45),
@phone_number CHAR(10)
AS
BEGIN
    DECLARE @admin_role VARCHAR(20);

    SELECT @admin_role = SESSION_CONTEXT(N'admin_role');

    -- Check if the admin role is 'superadmin'
    IF @admin_role <> 'superadmin'
    BEGIN
        PRINT 'Error: Only superadmins can add new admins.';
        RETURN;
    END

    DECLARE @email_exists INT;

    -- Make sure username is not empty and contains only letters
    IF @username NOT LIKE '%[^A-Za-z]%' AND LEN(@username) > 0
    BEGIN
        -- Same with phone number, only containing numbers and not empty
        IF @phone_number NOT LIKE '%[^0-9]%' AND LEN(@phone_number) = 10
        BEGIN
            -- Email should be in valid email format
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