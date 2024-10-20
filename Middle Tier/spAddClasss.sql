CREATE PROCEDURE spAddClass
    @class_name VARCHAR(30),
    @start_time TIME,
    @venue VARCHAR(30),
    @has_projector BIT,
    @end_time TIME,
    @age_range_start INT,
    @age_range_end INT
AS
BEGIN
    -- Validate class name for special characters
    IF @class_name LIKE '%[^a-zA-Z0-9 ]%'
    BEGIN
        RAISERROR('Class name contains special characters.', 16, 1);
        RETURN;
    END

    IF LEN(@class_name) = 0
    BEGIN
        RAISERROR('Class name cannot be empty.', 16, 1);
        RETURN;
    END 

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Insert class details
        INSERT INTO class (class_name, start_time, venue, has_projector, end_time, age_range_start, age_range_end)
        VALUES (@class_name, @start_time, @venue, @has_projector, @end_time, @age_range_start, @age_range_end);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Rollback transaction in case of error
        ROLLBACK TRANSACTION;

        -- Call the error handling procedure
        EXEC spHandleError;
    END CATCH
END;

-- Insert dummy data into the class table
INSERT INTO class (class_name, start_time, venue, has_projector, end_time, age_range_start, age_range_end)
VALUES 
('Nursery', '08:00:00', 'Room 101', 1, '12:00:00', 1, 3),
('Day Care', '09:00:00', 'Room 102', 0, '13:00:00', 1, 5),
('Kindergarten', '08:30:00', 'Room 103', 1, '12:30:00', 3, 6),
('Grade 1', '09:00:00', 'Room 104', 1, '14:00:00', 6, 9),
('Grade 2', '09:00:00', 'Room 105', 1, '14:00:00', 10, 13),
('Grade 3', '09:00:00', 'Room 106', 1, '14:00:00', 14, 17);

-- Verify the inserted data
SELECT * FROM class;
