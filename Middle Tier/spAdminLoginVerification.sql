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
        -- Email should be in valid email format
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
                    DECLARE @sessionStartTime DATETIME;
                    DECLARE @timeoutInMinutes INT = 30;

                    -- Get the session start time from the session context
                    SET @sessionStartTime = CONVERT(DATETIME, SESSION_CONTEXT(N'session_start_time'));

                    -- Compare the current time with the session start time
                    IF DATEDIFF(MINUTE, @sessionStartTime, GETDATE()) > @timeoutInMinutes
                    BEGIN
                        -- Session has timed out, take appropriate action (e.g., clear session context)
                        EXEC sp_set_session_context @key = N'admin_username', @value = NULL;
                        EXEC sp_set_session_context @key = N'admin_role', @value = NULL;
                        EXEC sp_set_session_context @key = N'admin_email', @value = NULL;
                        EXEC sp_set_session_context @key = N'admin_id', @value = NULL;
                        EXEC sp_set_session_context @key = N'session_start_time', @value = NULL;

                        PRINT 'Session has timed out.';
                    END
                    ELSE
                    BEGIN
                        PRINT 'Session is still active.';
                    END

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
