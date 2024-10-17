-- How to use this procedure

-- EXEC spAddChild 'John', 'Kavango', '2010-05-15', '0811234567', 'Peter', 'Kavango', 'Math 101', '82010154321'





-- EXEC viewParent
-- EXEC viewChild
CREATE PROC spAddChild
    @child_first_name VARCHAR(30),
    @child_last_name VARCHAR(30),
    @date_of_birth DATE,
    @emergency_contact_number CHAR(10),
    @emergency_contact_first_name VARCHAR(30),
    @emergency_contact_last_name VARCHAR(30),
    @class_name VARCHAR(30),
    @parent_id_number CHAR(11)
AS
BEGIN
  
  IF @child_first_name NOT LIKE '%[^A-Za-z]%' AND LEN(@child_first_name) > 0
    BEGIN
	
	IF @Child_last_name NOT LIKE '%[^A-Za-z]%' AND LEN(@child_last_name) > 0
        BEGIN 
   
   
   
   BEGIN TRY
        -- Check if the parent exists
        IF EXISTS (SELECT 1 FROM parent WHERE parent_id_number = @parent_id_number)
        BEGIN
            -- Check if the parent already has a child
            IF NOT EXISTS (SELECT 1 FROM child WHERE parent_id_number = @parent_id_number)
            BEGIN
                -- Insert the child
                INSERT INTO child (first_name, last_name, date_of_birth, emergency_contact_number, emergency_contact_first_name, emergency_contact_last_name, class_name, parent_id_number)
                VALUES (@child_first_name, @child_last_name, @date_of_birth, @emergency_contact_number, @emergency_contact_first_name, @emergency_contact_last_name, (SELECT class_name FROM class WHERE class_name = @class_name), @parent_id_number);

                PRINT 'Child has been successfully entered into the system.';
            END
            ELSE
            BEGIN
                PRINT 'This parent already has a child in the system.';
            END
        END
        ELSE
        BEGIN
            PRINT 'Parent does not exist in the system. Please add parent first.';
        END
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        PRINT 'Error: Unable to insert child or parent into the system.';
        PRINT 'Error Message: ' + @ErrorMessage;
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
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

