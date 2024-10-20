CREATE DATABASE qrSystemDPG
USE qrSystemDPG



-- DROP TABLE class
CREATE TABLE class (
    class_id INT PRIMARY KEY IDENTITY,
    class_name VARCHAR(30),
    start_time TIME NOT NULL,
    venue VARCHAR(30) NOT NULL,
    has_projector VARCHAR(3) NULL,
    end_time TIME NOT NULL,
    age_range_start INT,
    age_range_end INT
);




CREATE TABLE parent (
    parent_id_number CHAR(11) PRIMARY KEY,
    first_name VARCHAR(30) NOT NULL,
    last_name VARCHAR(30) NOT NULL,
    phone_number CHAR(10) NOT NULL UNIQUE,
    email VARCHAR(45) NOT NULL UNIQUE,
    home_address VARCHAR(30),
    gender CHAR(1) NOT NULL
    
);

CREATE TABLE child (
    child_id INT PRIMARY KEY IDENTITY,
    first_name VARCHAR(30) NOT NULL,
    last_name VARCHAR(30) NOT NULL,
    date_of_birth DATE,
    emergency_contact_number CHAR(10) NOT NULL,
    emergency_contact_first_name VARCHAR(30),
    emergency_contact_last_name VARCHAR(30),
    gender CHAR(1) NOT NULL,
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
	picked_up BIT DEFAULT 0,
	file_path VARCHAR(255),
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

