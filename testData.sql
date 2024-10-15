INSERT INTO teacher (teacher_id_number, first_name, last_name, phone_number, email, town, office_room_number)
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
