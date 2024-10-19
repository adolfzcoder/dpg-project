-- CREATE TABLE teacher (
--     teacher_id_number CHAR(11) PRIMARY KEY,
--     first_name VARCHAR(30) NOT NULL,
--     last_name VARCHAR(30) NOT NULL,
--     phone_number CHAR(10) NOT NULL UNIQUE,
--     email VARCHAR(45) NOT NULL UNIQUE,
--     town VARCHAR(30),  
--     office_room_number INT NOT NULL, -- could be in the same room, but sharing, so can't be unique
--     gender CHAR(1) NOT NULL
    
     
-- );


EXEC spAddTeacher '0008178803', 'Joana', 'Lojiko', '0817194729', 'jlojiko@yahoo.com', 'Omangongatti', '404'
EXEC viewTeacher
CREATE PROCEDURE spAddTeacher
@teacher_id_number CHAR(11),
@first_name VARCHAR(30),
@last_name VARCHAR(30),
@phone_number CHAR(10),
@email VARCHAR(45),
@town VARCHAR(30),  
@office_room_number INT,
@gender CHAR(1)
AS
BEGIN
  IF @first_name NOT LIKE '%[^A-Za-z]%' AND LEN(@first_name) > 0
  BEGIN
    IF @last_name NOT LIKE '%[^A-Za-z]%' AND LEN(@last_name) > 0
    BEGIN
      IF LEN(@phone_number) = 10
      BEGIN
        IF @town NOT LIKE '%[^A-Za-z]%' AND LEN(@town) > 0
        BEGIN
          IF ISNUMERIC(@office_room_number) = 1
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

              BEGIN TRY
                BEGIN TRANSACTION
                INSERT INTO teacher(teacher_id_number, first_name, last_name, phone_number, email, town, office_room_number, gender)
                VALUES(@teacher_id_number , @first_name, @last_name, @phone_number, @email, @town, @office_room_number, @gender);

                COMMIT TRANSACTION
                PRINT 'Teacher record added successfully.';
              END TRY
              BEGIN CATCH
                ROLLBACK TRANSACTION
                PRINT 'There was an error inserting into system';
              END CATCH
            END
            ELSE
            BEGIN
              PRINT 'Invalid gender. Please enter either male or female.';
            END
          END
          ELSE
          BEGIN
            PRINT 'Error: Office room number should be a valid number.';
          END
        END
        ELSE
        BEGIN
          PRINT 'Error: Town should contain only letters.';
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
