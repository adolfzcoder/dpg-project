
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
        VALUES (@class_name, @start_time, @venue, @has_projector, @endTime, @ageRangeStart, @ageRangeEnd);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Rollback transaction in case of error
        ROLLBACK TRANSACTION;

        -- Call the error handling procedure
        EXEC spHandleError;
    END CATCH
END;

