CREATE TRIGGER trg_qr_insert
ON qrcode
AFTER INSERT
AS
BEGIN
    DECLARE @qr_code_url VARCHAR(255);
     DECLARE @admin_id INT; -- this value is stroed in the session, which is set after the admin logs in
    DECLARE @table_name VARCHAR(255) = 'qrcode';
    DECLARE @current_timestamp DATETIME;

    SET @current_timestamp = GETDATE();

    -- Get the QR code URL from the inserted row
    SELECT @qr_code_url = qr_code_url
    FROM inserted;

    SET @admin_id = CAST(SESSION_CONTEXT(N'admin_id') AS INT); -- this value is stroed in the session, which is set after the admin logs in

    
    INSERT INTO audit_log (action, new_values, timestamp, performed_by_admin_id, table_name)
    VALUES ('QR Code Generated', @qr_code_url, @current_timestamp, @admin_id, @table_name);
END;



-- trg for update on qr table  then inserts into the log table, the new values, and admin_id, which is stored after admin logs in
CREATE TRIGGER trg_qrcode_update
ON qrcode
AFTER UPDATE
AS
BEGIN
    DECLARE @new_values VARCHAR(MAX);
     DECLARE @admin_id INT; -- this value is stroed in the session, which is set after the admin logs in
    DECLARE @current_timestamp DATETIME = GETDATE();
    DECLARE @table_name VARCHAR(255) = 'qrcode';

    SET @new_values = (SELECT * FROM inserted FOR JSON PATH);
    SET @admin_id = CAST(SESSION_CONTEXT(N'admin_id') AS INT); -- this value is stroed in the session, which is set after the admin logs in

    INSERT INTO audit_log (action, new_values, timestamp, performed_by_admin_id, table_name)
    VALUES ('UPDATE', @new_values, @current_timestamp, @admin_id, @table_name);
END;




-- Trigger for INSERT on class table  then inserts into the log table, the new values, and admin_id, which is stored after admin logs in
CREATE TRIGGER trg_class_insert
ON class
AFTER INSERT
AS
BEGIN
    DECLARE @new_values VARCHAR(MAX);
     DECLARE @admin_id INT; -- this value is stroed in the session, which is set after the admin logs in
    DECLARE @current_timestamp DATETIME = GETDATE();
    DECLARE @table_name VARCHAR(255) = 'class';

    SET @new_values = (SELECT * FROM inserted FOR JSON PATH);
    SET @admin_id = CAST(SESSION_CONTEXT(N'admin_id') AS INT); -- this value is stroed in the session, which is set after the admin logs in

    INSERT INTO audit_log (action, new_values, timestamp, performed_by_admin_id, table_name)
    VALUES ('INSERT', @new_values, @current_timestamp, @admin_id, @table_name);
END;

-- Trigger for UPDATE on class table  then inserts into the log table, the new values, and admin_id, which is stored after admin logs in
CREATE TRIGGER trg_class_update
ON class
AFTER UPDATE
AS
BEGIN
    DECLARE @new_values VARCHAR(MAX);
     DECLARE @admin_id INT; -- this value is stroed in the session, which is set after the admin logs in
    DECLARE @current_timestamp DATETIME = GETDATE();
    DECLARE @table_name VARCHAR(255) = 'class';

    SET @new_values = (SELECT * FROM inserted FOR JSON PATH);
    SET @admin_id = CAST(SESSION_CONTEXT(N'admin_id') AS INT); -- this value is stroed in the session, which is set after the admin logs in

    INSERT INTO audit_log (action, new_values, timestamp, performed_by_admin_id, table_name)
    VALUES ('UPDATE', @new_values, @current_timestamp, @admin_id, @table_name);
END;


-- Trigger for INSERT on parent table  then inserts into the log table, the new values, and admin_id, which is stored after admin logs in
CREATE TRIGGER trg_parent_insert
ON parent
AFTER INSERT
AS
BEGIN
    DECLARE @new_values VARCHAR(MAX);
     DECLARE @admin_id INT; -- this value is stroed in the session, which is set after the admin logs in
    DECLARE @current_timestamp DATETIME = GETDATE();
    DECLARE @table_name VARCHAR(255) = 'parent';

    SET @new_values = (SELECT * FROM inserted FOR JSON PATH);
    SET @admin_id = CAST(SESSION_CONTEXT(N'admin_id') AS INT); -- this value is stroed in the session, which is set after the admin logs in

    INSERT INTO audit_log (action, new_values, timestamp, performed_by_admin_id, table_name)
    VALUES ('INSERT', @new_values, @current_timestamp, @admin_id, @table_name);
END;

-- Trigger for UPDATE on parent table  then inserts into the log table, the new values, and admin_id, which is stored after admin logs in
CREATE TRIGGER trg_parent_update
ON parent
AFTER UPDATE
AS
BEGIN
    DECLARE @new_values VARCHAR(MAX);
     DECLARE @admin_id INT; -- this value is stroed in the session, which is set after the admin logs in
    DECLARE @current_timestamp DATETIME = GETDATE();
    DECLARE @table_name VARCHAR(255) = 'parent';

    SET @new_values = (SELECT * FROM inserted FOR JSON PATH);
    SET @admin_id = CAST(SESSION_CONTEXT(N'admin_id') AS INT); -- this value is stroed in the session, which is set after the admin logs in

    INSERT INTO audit_log (action, new_values, timestamp, performed_by_admin_id, @table_name);
END;

-- fired after insert to child table then inserts into the log table, the new values, and admin_id, which is stored after admin logs in
CREATE TRIGGER trg_child_insert
ON child
AFTER INSERT
AS
BEGIN
    DECLARE @new_values VARCHAR(MAX);
     DECLARE @admin_id INT; -- this value is stroed in the session, which is set after the admin logs in
    DECLARE @current_timestamp DATETIME = GETDATE();
    DECLARE @table_name VARCHAR(255) = 'child';

    SET @new_values = (SELECT * FROM inserted FOR JSON PATH);
    SET @admin_id = CAST(SESSION_CONTEXT(N'admin_id') AS INT); -- this value is stroed in the session, which is set after the admin logs in

    INSERT INTO audit_log (action, new_values, timestamp, performed_by_admin_id, table_name)
    VALUES ('INSERT', @new_values, @current_timestamp, @admin_id, @table_name);
END;

-- trg for update on qr table then inserts into the log table, the new values, and admin_id, which is stored after admin logs in
CREATE TRIGGER trg_child_update
ON child
AFTER UPDATE
AS
BEGIN
    DECLARE @new_values VARCHAR(MAX);
     DECLARE @admin_id INT; -- this value is stroed in the session, which is set after the admin logs in
    DECLARE @current_timestamp DATETIME = GETDATE();
    DECLARE @table_name VARCHAR(255) = 'child';

    SET @new_values = (SELECT * FROM inserted FOR JSON PATH);
    SET @admin_id = CAST(SESSION_CONTEXT(N'admin_id') AS INT); -- this value is stroed in the session, which is set after the admin logs in

    INSERT INTO audit_log (action, new_values, timestamp, performed_by_admin_id, table_name)
    VALUES ('UPDATE', @new_values, @current_timestamp, @admin_id, @table_name);
END;


-- fired afer insert to pickup table  then inserts into the log table, the new values, and admin_id, which is stored after admin logs in
CREATE TRIGGER trg_pickup_insert
ON pickup
AFTER INSERT
AS
BEGIN
    DECLARE @new_values VARCHAR(MAX);
     DECLARE @admin_id INT; -- this value is stroed in the session, which is set after the admin logs in
    DECLARE @current_timestamp DATETIME = GETDATE();
    DECLARE @table_name VARCHAR(255) = 'pickup';

    SET @new_values = (SELECT * FROM inserted FOR JSON PATH);
    SET @admin_id = CAST(SESSION_CONTEXT(N'admin_id') AS INT); -- this value is stroed in the session, which is set after the admin logs in

    INSERT INTO audit_log (action, new_values, timestamp, performed_by_admin_id, table_name)
    VALUES ('INSERT', @new_values, @current_timestamp, @admin_id, @table_name);
END;

-- fired afer update to pickup table  then inserts into the log table, the new values, and admin_id, which is stored after admin logs in
CREATE TRIGGER trg_pickup_update
ON pickup
AFTER UPDATE
AS
BEGIN
    DECLARE @new_values VARCHAR(MAX); -- new values can be large, hence why using (MAX) it can store uop to 2GB of data
     DECLARE @admin_id INT; -- this value is stroed in the session, which is set after the admin logs in
    DECLARE @current_timestamp DATETIME = GETDATE();
    DECLARE @table_name VARCHAR(255) = 'pickup';

    SET @new_values = (SELECT * FROM inserted FOR JSON PATH);
    SET @admin_id = CAST(SESSION_CONTEXT(N'admin_id') AS INT); -- this value is stroed in the session, which is set after the admin logs in

    INSERT INTO audit_log (action, new_values, timestamp, performed_by_admin_id, table_name)
    VALUES ('UPDATE', @new_values, @current_timestamp, @admin_id, @table_name);
END;

-- this trigger is fired after any insert to the admin table tble then inserts into the log table, the new values, and admin_id, which is stored after admin logs in
CREATE TRIGGER trg_adminTable_insert
ON adminTable
AFTER INSERT
AS
BEGIN
    DECLARE @new_values VARCHAR(MAX);
     DECLARE @admin_id INT; -- this value is stroed in the session, which is set after the admin logs in
    DECLARE @current_timestamp DATETIME = GETDATE();
    DECLARE @table_name VARCHAR(255) = 'adminTable';

    SET @new_values = (SELECT * FROM inserted FOR JSON PATH);
    SET @admin_id = CAST(SESSION_CONTEXT(N'admin_id') AS INT); -- this value is stroed in the session, which is set after the admin logs in

    INSERT INTO audit_log (action, new_values, timestamp, performed_by_admin_id, table_name)
    VALUES ('INSERT', @new_values, @current_timestamp, @admin_id, @table_name);
END;

-- this trigger is fired after any updates to the admin tble then inserts into the log table, the new values, and admin_id, which is stored after admin logs in

CREATE TRIGGER trg_adminTable_update
ON adminTable
AFTER UPDATE
AS
BEGIN
    DECLARE @new_values VARCHAR(MAX);
     DECLARE @admin_id INT; -- this value is stroed in the session, which is set after the admin logs in
    DECLARE @current_timestamp DATETIME = GETDATE();
    DECLARE @table_name VARCHAR(255) = 'adminTable';

    SET @new_values = (SELECT * FROM inserted FOR JSON PATH);
    SET @admin_id = CAST(SESSION_CONTEXT(N'admin_id') AS INT); -- this value is stroed in the session, which is set after the admin logs in

    INSERT INTO audit_log (action, new_values, timestamp, performed_by_admin_id, table_name)
    VALUES ('UPDATE', @new_values, @current_timestamp, @admin_id, @table_name);
END;
