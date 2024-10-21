-- first input the class


EXEC spAddClass 'Nursery', '08:00:00', 'Room 101', 'yes', '12:00:00', 1, 2
EXEC spAddClass 'Day Care', '09:00:00', 'Room 102', 'no', '13:00:00', 3, 5
EXEC spAddClass 'Kindergarten', '08:30:00', 'Room 103', 'yes', '12:30:00', 6, 8
EXEC spAddClass 'Grade 1', '09:00:00', 'Room 104', 'yes', '14:00:00', 7 ,9
EXEC spAddClass 'Grade 2', '09:00:00', 'Room 105', 'yes', '14:00:00', 10, 12
EXEC spAddClass 'Grade 3', '09:00:00', 'Room 106', 'yes', '14:00:00', 13, 17

-- add parent next

EXEC spAddParent '82010154321', 'Anna', 'Kavango', '0819876543', 'annakavango@example.com', 'Windhoek', 'F'
EXEC spAddParent '99051790321', 'Adolf', 'Chikombo', '0816166785', 'adavid@muhoko.org', 'Otjiarare', 'M'

-- add child

EXEC spAddChild 'John', 'Kavango', '2018-05-15', '0811234567', 'Peter', 'Kavango', 'Male', '82010154321'

-- Generate the qr code

EXEC spGenerateQrCode 'John', 'Kavango'

-- pickup verification 
-- BA9A2F9C-DA3F-41 is the uuid, that uniquely ideintifies who is picking up the child and the qr code
EXEC spPickupVerification 'John', 'Kavango', '82010154321', 'BA9A2F9C-DA3F-41', 'BA9A2F9C-DA3F-41'

-- Generate report

EXEC spGenerateDailyReport '2023-10-01';