CREATE PROCEDURE spAddClass
    @className VARCHAR(30),
    @startTime TIME,
    @venue VARCHAR(30),
    @hasProjector BIT,
    @endTime TIME,
    @teacherIdNumber CHAR(11),
    @ageRangeStart INT,
    @ageRangeEnd INT
AS
BEGIN
    -- Validate class name for special characters
    IF @className LIKE '%[^a-zA-Z0-9 ]%'
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
        INSERT INTO class (class_name, start_time, venue, has_projector, end_time, teacher_id_number, age_range_start, age_range_end)
        VALUES (@className, @startTime, @venue, @hasProjector, @endTime, @teacherIdNumber, @ageRangeStart, @ageRangeEnd);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Rollback transaction in case of error
        ROLLBACK TRANSACTION;

        -- Call the error handling procedure
        EXEC spHandleError;
    END CATCH
END;