INSERT INTO teacher (teacher_id_number, first_name, last_name, phone_number, email, home_address, office_room_number)
VALUES 
('98031712345', 'Petrus', 'Nangolo', '0812345678', 'petrusnangolo@example.com', 'Windhoek', 101),
('85020256789', 'Maria', 'Kandjii', '0818765432', 'mariakandjii@example.com', 'Swakopmund', 102),
('90030391012', 'Johannes', 'Shilongo', '0811122334', 'johannesshilongo@example.com', 'Walvis Bay', 103),
('87040411223', 'Elina', 'Amutenya', '0812233445', 'elinaamutenya@example.com', 'Oshakati', 104),
('95050533444', 'Samuel', 'Kaunda', '0813344556', 'samuelkaunda@example.com', 'Rundu', 105);

INSERT INTO class (class_name, start_time, venue, has_projector, end_time, teacher_id_number)
VALUES 
('Math 101', '08:00:00', 'Room 201', 1, '09:30:00', '98031712345'),
('Science 101', '09:45:00', 'Room 202', 0, '11:15:00', '85020256789'),
('History 101', '11:30:00', 'Room 203', 1, '13:00:00', '90030391012'),
('Art 101', '13:15:00', 'Room 204', 0, '14:45:00', '87040411223'),
('Music 101', '15:00:00', 'Room 205', 1, '16:30:00', '95050533444');

-- Insert data into parent table
INSERT INTO parent (parent_id_number, first_name, last_name, phone_number, email, home_address)
VALUES 
('82010154321', 'Anna', 'Kavango', '0819876543', 'annakavango@example.com', 'Windhoek'),
('83020265432', 'David', 'Ndebele', '0818765432', 'davidndebele@example.com', 'Swakopmund'),
('84030376543', 'Linda', 'Mubita', '0817654321', 'lindamubita@example.com', 'Walvis Bay'),
('85040487654', 'Peter', 'Shikongo', '0816543210', 'petershikongo@example.com', 'Oshakati'),
('86050598765', 'Grace', 'Kapenda', '0815432109', 'gracekapenda@example.com', 'Rundu');

-- Insert data into child table
INSERT INTO child (first_name, last_name, date_of_birth, emergency_contact_number, emergency_contact_first_name, emergency_contact_last_name, class_name, parent_id_number)
VALUES 
('John', 'Kavango', '2010-05-15', '0811234567', 'Peter', 'Kavango', 'Math 101', '82010154321'),
('Sarah', 'Ndebele', '2011-06-20', '0812345678', 'Maria', 'Ndebele', 'Science 101', '83020265432'),
('Michael', 'Mubita', '2012-07-25', '0813456789', 'John', 'Mubita', 'History 101', '84030376543'),
('Emily', 'Shikongo', '2013-08-30', '0814567890', 'Anna', 'Shikongo', 'Art 101', '85040487654'),
('Daniel', 'Kapenda', '2014-09-05', '0815678901', 'Grace', 'Kapenda', 'Music 101', '86050598765');
