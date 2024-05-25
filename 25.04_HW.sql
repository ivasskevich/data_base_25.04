use master

go 

create database barbershop

go

use barbershop

go

CREATE TABLE barbers (
    id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    phone VARCHAR(15) NOT NULL,
    email VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    date_of_hire DATE NOT NULL,
    position VARCHAR(20) NOT NULL CHECK (position IN ('chief-barber', 'senior-barber', 'junior-barber'))
);
go
CREATE TABLE clients (
    id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL,
    email VARCHAR(100) NOT NULL
);

go
CREATE TABLE schedule (
    id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    barber_id INT NOT NULL,
    date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    client_id INT,
    FOREIGN KEY (barber_id) REFERENCES barbers(id),
    FOREIGN KEY (client_id) REFERENCES clients(id)
);

go
CREATE TABLE services (
    id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    duration INT NOT NULL -- ѕродолжительность услуги в минутах
);

go
CREATE TABLE client_visits (
    id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    client_id INT NOT NULL,
    barber_id INT NOT NULL,
    service_id INT NOT NULL,
    date DATE NOT NULL,
    total_cost DECIMAL(10, 2) NOT NULL,
    rating VARCHAR(20) NOT NULL CHECK (rating IN ('very bad', 'bad', 'normal', 'good', 'excellent')),
    feedback TEXT,
    FOREIGN KEY (client_id) REFERENCES clients(id),
    FOREIGN KEY (barber_id) REFERENCES barbers(id),
    FOREIGN KEY (service_id) REFERENCES services(id)
);
go
INSERT INTO barbers (full_name, gender, phone, email, date_of_birth, date_of_hire, position)
VALUES
('Samuel Black', 'male', '321-654-0987', 'samuel.black@example.com', '1980-01-20', '2021-12-01', 'chief-barber'),
('Emma Watson', 'female', '654-321-0987', 'emma.watson@example.com', '1991-07-10', '2020-04-15', 'senior-barber'),
('Lucas Brown', 'male', '444-444-4444', 'lucas.brown@example.com', '1994-09-15', '2019-05-25', 'junior-barber'),
('Lily Johnson', 'female', '333-333-3333', 'lily.johnson@example.com', '1983-10-25', '2018-07-10', 'senior-barber'),
('Grace White', 'female', '666-666-6666', 'grace.white@example.com', '1992-06-30', '2020-11-10', 'junior-barber'),
('Jack Green', 'male', '777-777-7777', 'jack.green@example.com', '1986-03-17', '2017-10-20', 'chief-barber'),
('Sophia Wilson', 'female', '888-888-8888', 'sophia.wilson@example.com', '1993-12-05', '2019-01-15', 'senior-barber'),
('Liam Taylor', 'male', '999-999-9999', 'liam.taylor@example.com', '1988-04-05', '2016-08-01', 'junior-barber'),
('Mia Thomas', 'female', '123-123-1234', 'mia.thomas@example.com', '1997-08-15', '2021-03-15', 'junior-barber'),
('Benjamin Moore', 'male', '321-321-4321', 'benjamin.moore@example.com', '1995-11-20', '2018-06-25', 'senior-barber');

go
INSERT INTO clients (full_name, phone, email)
VALUES
('Mason Clark', '234-234-2345', 'mason.clark@example.com'),
('Ava Walker', '345-345-3456', 'ava.walker@example.com'),
('Logan Harris', '456-456-4567', 'logan.harris@example.com'),
('Isabella Martinez', '567-567-5678', 'isabella.martinez@example.com'),
('Lucas Lee', '678-678-6789', 'lucas.lee@example.com'),
('Amelia Scott', '789-789-7890', 'amelia.scott@example.com'),
('Oliver Brown', '890-890-8901', 'oliver.brown@example.com'),
('Charlotte Davis', '901-901-9012', 'charlotte.davis@example.com'),
('Ethan Adams', '012-012-0123', 'ethan.adams@example.com'),
('Sophia Lewis', '123-456-7890', 'sophia.lewis@example.com');

go
INSERT INTO schedule (barber_id, date, start_time, end_time, client_id)
VALUES
(1, '2024-05-26', '09:00:00', '10:00:00', 1),
(2, '2024-05-26', '10:00:00', '11:00:00', 2),
(3, '2024-05-26', '11:00:00', '12:00:00', 3),
(4, '2024-05-26', '12:00:00', '13:00:00', 4),
(5, '2024-05-26', '13:00:00', '14:00:00', 5),
(6, '2024-05-26', '14:00:00', '15:00:00', 6),
(7, '2024-05-26', '15:00:00', '16:00:00', 7),
(8, '2024-05-26', '16:00:00', '17:00:00', 8),
(9, '2024-05-26', '17:00:00', '18:00:00', 9),
(10, '2024-05-26', '18:00:00', '19:00:00', 10);

go
INSERT INTO services (name, price, duration)
VALUES
('Haircut', 35.00, 50),
('Shave', 25.00, 35),
('Beard Trim', 18.00, 25),
('Hair Coloring', 55.00, 65),
('Facial', 30.00, 45),
('Manicure', 22.00, 40),
('Pedicure', 28.00, 45),
('Scalp Massage', 20.00, 25),
('Hot Towel Shave', 40.00, 50),
('Massage', 65.00, 70);

go
INSERT INTO client_visits (client_id, barber_id, service_id, date, total_cost, rating, feedback)
VALUES
(1, 1, 1, '2024-05-26', 35.00, 'excellent', 'Amazing haircut!'),
(2, 2, 2, '2024-05-26', 25.00, 'good', 'Great shave.'),
(3, 3, 3, '2024-05-26', 18.00, 'excellent', 'Perfect beard trim.'),
(4, 4, 4, '2024-05-26', 55.00, 'good', 'Nice hair coloring.'),
(5, 5, 5, '2024-05-26', 30.00, 'excellent', 'Loved the facial!'),
(6, 6, 6, '2024-05-26', 22.00, 'good', 'Good manicure.'),
(7, 7, 7, '2024-05-26', 28.00, 'normal', 'Pedicure was okay.'),
(8, 8, 8, '2024-05-26', 20.00, 'excellent', 'Very relaxing scalp massage.'),
(9, 9, 9, '2024-05-26', 40.00, 'good', 'Hot towel shave was great!'),
(10, 10, 10, '2024-05-26', 65.00, 'excellent', 'Massage was fantastic.');

go
CREATE PROCEDURE GetAllBarbers()
AS
BEGIN
    SELECT full_name FROM barbers;
END;

go
CREATE PROCEDURE GetSeniorBarbers()
AS
BEGIN
    SELECT * FROM barbers WHERE position = 'senior-barber';
END;

go
CREATE PROCEDURE GetBarbersForTraditionalShave()
AS
BEGIN
    SELECT DISTINCT b.*
    FROM barbers b
    JOIN client_visits cv ON b.id = cv.barber_id
    JOIN services s ON cv.service_id = s.id
    WHERE s.name = 'Hot Towel Shave';
END;

go
CREATE PROCEDURE GetBarbersByService(@service_name VARCHAR(100))
AS
BEGIN
    SELECT DISTINCT b.*
    FROM barbers b
    JOIN client_visits cv ON b.id = cv.barber_id
    JOIN services s ON cv.service_id = s.id
    WHERE s.name = @service_name;
END;

go
CREATE PROCEDURE GetBarbersByExperience(@years INT)
AS
BEGIN
    SELECT * FROM barbers
    WHERE DATEDIFF(YEAR, date_of_hire, GETDATE()) > @years;
END;

go
CREATE PROCEDURE GetBarberCounts()
AS
BEGIN
    SELECT 
        (SELECT COUNT(*) FROM barbers WHERE position = 'senior-barber') AS senior_barbers_count,
        (SELECT COUNT(*) FROM barbers WHERE position = 'junior-barber') AS junior_barbers_count;
END;

go
CREATE PROCEDURE GetRegularClients(@visits INT)
AS
BEGIN
    SELECT c.*
    FROM clients c
    JOIN (
        SELECT client_id, COUNT(*) AS visit_count
        FROM client_visits
        GROUP BY client_id
        HAVING COUNT(*) > @visits
    ) AS visits ON c.id = visits.client_id;
END;

go
CREATE TRIGGER PreventChiefBarberDeletion
ON barbers
INSTEAD OF DELETE
AS
BEGIN
    IF (SELECT COUNT(*) FROM barbers WHERE position = 'chief-barber') = 1
    BEGIN
        PRINT 'Cannot delete the only chief-barber';
        ROLLBACK;
    END
END;

go
CREATE TRIGGER PreventYoungBarbers
ON barbers
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @date_of_birth DATE, @age INT;
    SELECT @date_of_birth = i.date_of_birth FROM inserted i;
    SET @age = DATEDIFF(YEAR, @date_of_birth, GETDATE());
    
    IF @age < 21
    BEGIN
        PRINT 'Cannot add a barber younger than 21 years old';
        ROLLBACK;
    END
END;
