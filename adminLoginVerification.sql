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