CREATE DATABASE childChurchQR;
USE childChurchQR;

CREATE TABLE teacher (
    teacher_id_number INT PRIMARY KEY,
    first_name VARCHAR(30) NOT NULL,
    last_name VARCHAR(30) NOT NULL,
    phone_number VARCHAR(30) UNIQUE,
    email VARCHAR(255) UNIQUE,
    office_room_number INT,
    home_address VARCHAR(30),
    salary INT
);


CREATE TABLE class (
    class_name VARCHAR(30) PRIMARY KEY,
    start_time TIME,
    end_time TIME,
    venue VARCHAR(30),
    teacher_id_number INT UNIQUE, 
    FOREIGN KEY (teacher_id_number) REFERENCES teacher(teacher_id_number)
);


CREATE TABLE parent (
    parent_id INT PRIMARY KEY IDENTITY,
    first_name VARCHAR(30) NOT NULL,
    last_name VARCHAR(30) NOT NULL,
    phone_number VARCHAR(30) UNIQUE,
    email VARCHAR(30) UNIQUE,
    home_address VARCHAR(30)
);


CREATE TABLE child (
    child_id INT PRIMARY KEY IDENTITY,
    first_name VARCHAR(30) NOT NULL,
    last_name VARCHAR(30) NOT NULL,
    date_of_birth DATE,
    class_name VARCHAR(30),
    parent_id INT,
    FOREIGN KEY (class_name) REFERENCES class(class_name),
    FOREIGN KEY (parent_id) REFERENCES parent(parent_id)
);


CREATE TABLE qrcode (
    qrcode_id INT PRIMARY KEY IDENTITY,
    url VARCHAR(255),
    time_generated DATETIME,
    parent_id INT,
    child_id INT,
    date DATE, 
    FOREIGN KEY (parent_id) REFERENCES parent(parent_id),
    FOREIGN KEY (child_id) REFERENCES child(child_id),
    UNIQUE (parent_id, child_id, date) 
);


CREATE TABLE pickup (
    pickup_id INT PRIMARY KEY IDENTITY,
    pickup_time TIME,
    pickup_date DATE,
    qrcode_id INT,
    FOREIGN KEY (qrcode_id) REFERENCES qrcode(qrcode_id)
);


CREATE TABLE dropOff (
    dropoff_id INT PRIMARY KEY IDENTITY,
    dropoff_time TIME,
    dropoff_date DATE,
    qrcode_id INT,
    FOREIGN KEY (qrcode_id) REFERENCES qrcode(qrcode_id)
);


CREATE TABLE audit_log (
    log_id INT PRIMARY KEY IDENTITY,
    table_name VARCHAR(255) NOT NULL,
    action VARCHAR(50) NOT NULL,
    record_id INT NOT NULL,
    old_values VARCHAR(MAX), 
    new_values VARCHAR(MAX), 
    timestamp DATETIME,
    performed_by VARCHAR(30)
);