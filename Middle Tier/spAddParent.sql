CREATE PROCEDURE spAddProcedure
@parent_id_number CHAR (11),
    @first_name VARCHAR(30)
    @last_name VARCHAR(30)
   @phone_number CHAR(10)
    @email VARCHAR(45),
    @town VARCHAR (30)

   AS
   BEGIN
   IF @first_name NOT LIKE '%[^A-Za-z]%' AND LEN(@first_name) > 0
     BEGIN
       IF @last_name NOT LIKE '%[^A-Za-z]%' AND LEN(@last_name) > 0
       BEGIN
         IF LEN(@phone_number) = 10
         BEGIN
          BEGIN TRY
          BEGIN TRANSACTION
         INSERT INTO parent(parent_id_number,first_name,last_name,phone_number,email,town)
         VALUES(@parent_id_number,@first_name,@last_name,@phone_number,@email,@town)

         COMMIT TRANSACTION
         PRINT 'Parent record added successfully'
           END TRY
                     BEGIN CATCH
                       ROLLBACK TRANSACTION
                       PRINT 'There was an error inserting into system';
                     END CATCH
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