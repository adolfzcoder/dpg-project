-- CREATE DATABASE childQRSystem
-- USE childQRSystem
 -- CREATE DATABASE childChurchQR_production;
-- USE childChurchQR_production;
-- CREATE DATABASE childChurchQrSystem
-- USE childChurchQrSystem
CREATE TABLE teacher (
    teacher_id_number CHAR(11) PRIMARY KEY,
    first_name VARCHAR(30) NOT NULL,
    last_name VARCHAR(30) NOT NULL,
    phone_number CHAR(10) NOT NULL UNIQUE,
    email VARCHAR(45) NOT NULL UNIQUE,
    town VARCHAR(30),  
    office_room_number INT NOT NULL  -- could be in the same room, but sharing, so can't be unique
);

-- DROP TABLE class
CREATE TABLE class (
    class_id INT PRIMARY KEY IDENTITY,
    class_name VARCHAR(30),
    start_time TIME NOT NULL,
    venue VARCHAR(30) NOT NULL,
    has_projector BIT NULL,
    end_time TIME NOT NULL,
    teacher_id_number CHAR(11) NOT NULL,
    FOREIGN KEY (teacher_id_number) REFERENCES teacher(teacher_id_number)
);

CREATE TABLE parent (
    parent_id_number CHAR(11) PRIMARY KEY,
    first_name VARCHAR(30) NOT NULL,
    last_name VARCHAR(30) NOT NULL,
    phone_number CHAR(10) NOT NULL UNIQUE,
    email VARCHAR(45) NOT NULL UNIQUE,
    town VARCHAR(30)
);

CREATE TABLE child (
    child_id INT PRIMARY KEY IDENTITY,
    first_name VARCHAR(30) NOT NULL,
    last_name VARCHAR(30) NOT NULL,
    date_of_birth DATE,
    emergency_contact_number CHAR(10) NOT NULL UNIQUE,
    emergency_contact_first_name VARCHAR(30),
    emergency_contact_last_name VARCHAR(30),
    class_id INT,
    parent_id_number CHAR(11) NOT NULL UNIQUE,  -- Enforce one-to-one relationship
    FOREIGN KEY (parent_id_number) REFERENCES parent(parent_id_number),
    FOREIGN KEY (class_id) REFERENCES class(class_id)
);

CREATE TABLE qrcode (
    qrcode_id INT PRIMARY KEY IDENTITY,
    qr_code_url VARCHAR(255) NOT NULL UNIQUE,  -- qr code data usually this long
    drop_off_time TIME NOT NULL,  -- drop off time same as the time the qr code will be generated
    drop_off_date DATE NOT NULL,
    parent_id_number CHAR(11) NOT NULL,
    child_id INT,
	picked_up BIT,
    FOREIGN KEY (parent_id_number) REFERENCES parent(parent_id_number),
    FOREIGN KEY (child_id) REFERENCES child(child_id)
);  -- qr code is used for only one pickup, ie child can only be picked up once with that qr code


CREATE TABLE pickup (
    pickup_id INT PRIMARY KEY IDENTITY,
    pickup_time TIME NOT NULL,
    pickup_date DATE NOT NULL,
    qrcode_id INT NOT NULL,
    FOREIGN KEY (qrcode_id) REFERENCES qrcode(qrcode_id)
);

CREATE TABLE adminTable (
    admin_id INT PRIMARY KEY IDENTITY,
    username VARCHAR(30) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(45) NOT NULL UNIQUE,
    role VARCHAR(20) DEFAULT 'admin',  -- 'admin' or 'superadmin', superadmins can add other admins
    phone_number CHAR(10) UNIQUE,
    created_at DATETIME DEFAULT GETDATE()
);

CREATE TABLE audit_log (
    log_id INT PRIMARY KEY IDENTITY,
    action VARCHAR(30) NOT NULL,
    new_values VARCHAR(MAX),
    timestamp DATETIME,
    performed_by_admin_id INT,
    table_name VARCHAR(255) NOT NULL
);