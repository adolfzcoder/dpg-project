
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




	-- Check if the email already exists
    SELECT @email_exists = COUNT(*)
    FROM adminTable
    WHERE email = @email;

    IF @email_exists > 0
		BEGIN
			-- get stored password
			SELECT @stored_password = password,
			@admin_username = username,
			@admin_role = role,
			@admin_email = email
			FROM adminTable
			WHERE email = @email;


			-- Compare the passwords
			IF @stored_password = @password
			BEGIN
				PRINT 'Succesfully logged in';
				 -- Set session context values

				EXEC sp_set_session_context @key = N'admin_username', @value = @admin_username;
				EXEC sp_set_session_context @key = N'admin_role', @value = @admin_role;
				EXEC sp_set_session_context @key = N'admin_email', @value = @email;

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
			PRINT 'Email Does not Exist';
		END
    
END;

