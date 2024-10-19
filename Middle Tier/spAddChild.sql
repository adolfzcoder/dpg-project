-- CREATE TABLE child (
--     child_id INT PRIMARY KEY IDENTITY,
--     first_name VARCHAR(30) NOT NULL,
--     last_name VARCHAR(30) NOT NULL,
--     date_of_birth DATE,
--     emergency_contact_number CHAR(10) NOT NULL UNIQUE,
--     emergency_contact_firsst_name VARCHAR(30),
--     emergency_contact_last_name VARCHAR(30),
--     gender CHAR(1) NOT NULL,
--     class_id INT,
--     parent_id_number CHAR(11) NOT NULL UNIQUE,  -- Enforce one-to-one relationship
--     FOREIGN KEY (parent_id_number) REFERENCES parent(parent_id_number),
--     FOREIGN KEY (class_id) REFERENCES class(class_id)
-- );






CREATE PROCEDURE spAddChild
    @child_first_name VARCHAR(30),
    @child_last_name VARCHAR(30),
    @date_of_birth DATE,
    @emergency_contact_number CHAR(10),
    @emergency_contact_first_name VARCHAR(30),
    @emergency_contact_last_name VARCHAR(30),
    @gender CHAR(1),
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
                            IF LOWER(@gender) LIKE 'male' OR LOWER(@gender) LIKE 'female'
                            BEGIN
                                IF @gender LIKE 'male'
                                BEGIN
                                    SET @gender = 'M';
                                END
                                ELSE
                                BEGIN
                                    SET @gender = 'F';
                                END

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
                                                INSERT INTO child (first_name, last_name, date_of_birth, emergency_contact_number, emergency_contact_first_name, emergency_contact_last_name, gender, parent_id_number)
                                                VALUES (@child_first_name, @child_last_name, @date_of_birth, @emergency_contact_number, @emergency_contact_first_name, @emergency_contact_last_name, @gender, @parent_id_number);

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
                                PRINT 'Error: Gender should be either male or female.';
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
