EXEC spAddTeacher '0008178803', 'Joana', 'Lojiko', '0817194729', 'jlojiko@yahoo.com', 'Omangongatti', '404'
EXEC viewTeacher

ALTER PROCEDURE spAddTeacher
@teacher_id_number CHAR(11),
@first_name VARCHAR(30),
@last_name VARCHAR(30),
@phone_number CHAR(10),
@email VARCHAR(45),
@town VARCHAR(30),  
@office_room_number INT
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
            BEGIN TRY
              BEGIN TRANSACTION
              
              INSERT INTO teacher(teacher_id_number, first_name, last_name, phone_number, email, town, office_room_number)
              VALUES(@teacher_id_number , @first_name, @last_name, @phone_number, @email, @town, @office_room_number);

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