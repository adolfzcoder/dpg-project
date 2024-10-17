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

BEGIN TRY
INSERT INTO teacher(teacher_id_number, first_name, last_name, phone_number, email, town, office_room_number)
VALUES(@teacher_id_number , @first_name, @last_name, @phone_number, @email, @town, @office_room_number);

PRINT 'Teacher record added successfully.';

END TRY
BEGIN CATCH

PRINT 'There was an error inserting into system';

END CATCH

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