-- CREATE TABLE parent (
--     parent_id_number CHAR(11) PRIMARY KEY,
--     first_name VARCHAR(30) NOT NULL,
--     last_name VARCHAR(30) NOT NULL,
--     phone_number CHAR(10) NOT NULL UNIQUE,
--     email VARCHAR(45) NOT NULL UNIQUE,
--     home_address VARCHAR(30),
--     gender CHAR(1) NOT NULL
-- );




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
