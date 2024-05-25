USE barbershop

CREATE FUNCTION GetLongestServingBarber()
RETURNS TABLE
AS
RETURN
(
    SELECT TOP 1
        b.id,
        b.full_name,
        b.gender,
        b.phone,
        b.email,
        b.date_of_birth,
        b.date_of_hire,
        b.position,
        DATEDIFF(DAY, b.date_of_hire, GETDATE()) AS days_of_service
    FROM barbers b
    ORDER BY days_of_service DESC
);


CREATE PROCEDURE GetTopBarberByClientsServedInDateRange
    @start_date DATE,
    @end_date DATE
AS
BEGIN
    SELECT TOP 1
        b.id,
        b.full_name,
        b.gender,
        b.phone,
        b.email,
        b.date_of_birth,
        b.date_of_hire,
        b.position,
        COUNT(cv.client_id) AS clients_served
    FROM client_visits cv
    JOIN barbers b ON cv.barber_id = b.id
    WHERE cv.date BETWEEN @start_date AND @end_date
    GROUP BY b.id, b.full_name, b.gender, b.phone, b.email, b.date_of_birth, b.date_of_hire, b.position
    ORDER BY clients_served DESC;
END;


CREATE FUNCTION GetTopVisitingClient()
RETURNS TABLE
AS
RETURN
(
    SELECT TOP 1
        c.id,
        c.full_name,
        c.phone,
        c.email,
        COUNT(cv.client_id) AS visit_count
    FROM client_visits cv
    JOIN clients c ON cv.client_id = c.id
    GROUP BY c.id, c.full_name, c.phone, c.email
    ORDER BY visit_count DESC
);


CREATE FUNCTION GetTopSpendingClient()
RETURNS TABLE
AS
RETURN
(
    SELECT TOP 1
        c.id,
        c.full_name,
        c.phone,
        c.email,
        SUM(cv.total_cost) AS total_spent
    FROM client_visits cv
    JOIN clients c ON cv.client_id = c.id
    GROUP BY c.id, c.full_name, c.phone, c.email
    ORDER BY total_spent DESC
);


CREATE FUNCTION GetLongestService()
RETURNS TABLE
AS
RETURN
(
    SELECT TOP 1
        s.id,
        s.name,
        s.price,
        s.duration
    FROM services s
    ORDER BY s.duration DESC
);


SELECT * FROM GetLongestServingBarber();

EXEC GetTopBarberByClientsServedInDateRange '2024-04-01', '2024-04-26';

SELECT * FROM GetTopVisitingClient();

SELECT * FROM GetTopSpendingClient();

SELECT * FROM GetLongestService();




CREATE FUNCTION GetMostPopularBarber()
RETURNS TABLE
AS
RETURN
(
    SELECT TOP 1
        b.id,
        b.full_name,
        b.gender,
        b.phone,
        b.email,
        b.date_of_birth,
        b.date_of_hire,
        b.position,
        COUNT(cv.client_id) AS client_count
    FROM client_visits cv
    JOIN barbers b ON cv.barber_id = b.id
    GROUP BY b.id, b.full_name, b.gender, b.phone, b.email, b.date_of_birth, b.date_of_hire, b.position
    ORDER BY client_count DESC
);


CREATE PROCEDURE GetTop3BarbersByRevenueLastMonth
AS
BEGIN
    DECLARE @start_date DATE = DATEADD(MONTH, -1, GETDATE());
    DECLARE @end_date DATE = GETDATE();

    SELECT TOP 3
        b.id,
        b.full_name,
        b.gender,
        b.phone,
        b.email,
        b.date_of_birth,
        b.date_of_hire,
        b.position,
        SUM(cv.total_cost) AS total_revenue
    FROM client_visits cv
    JOIN barbers b ON cv.barber_id = b.id
    WHERE cv.date BETWEEN @start_date AND @end_date
    GROUP BY b.id, b.full_name, b.gender, b.phone, b.email, b.date_of_birth, b.date_of_hire, b.position
    ORDER BY total_revenue DESC;
END;


CREATE FUNCTION GetTop3BarbersByAverageRating()
RETURNS TABLE
AS
RETURN
(
    SELECT TOP 3
        b.id,
        b.full_name,
        b.gender,
        b.phone,
        b.email,
        b.date_of_birth,
        b.date_of_hire,
        b.position,
        AVG(CASE
            WHEN cv.rating = 'very bad' THEN 1
            WHEN cv.rating = 'bad' THEN 2
            WHEN cv.rating = 'normal' THEN 3
            WHEN cv.rating = 'good' THEN 4
            WHEN cv.rating = 'excellent' THEN 5
            ELSE NULL
        END) AS average_rating
    FROM client_visits cv
    JOIN barbers b ON cv.barber_id = b.id
    GROUP BY b.id, b.full_name, b.gender, b.phone, b.email, b.date_of_birth, b.date_of_hire, b.position
    HAVING COUNT(cv.client_id) >= 30
    ORDER BY average_rating DESC;
);


CREATE PROCEDURE GetBarberScheduleForDay
    @barber_id INT,
    @date DATE
AS
BEGIN
    SELECT
        s.id,
        s.barber_id,
        s.date,
        s.start_time,
        s.end_time,
        s.client_id,
        c.full_name AS client_name
    FROM schedule s
    LEFT JOIN clients c ON s.client_id = c.id
    WHERE s.barber_id = @barber_id AND s.date = @date;
END;


CREATE PROCEDURE GetBarberFreeTimeSlotsForWeek
    @barber_id INT,
    @start_date DATE
AS
BEGIN
    DECLARE @end_date DATE = DATEADD(DAY, 6, @start_date);
    
    WITH FreeTimeSlots AS (
        SELECT
            @start_date AS date,
            TIME('09:00:00') AS start_time,
            TIME('20:00:00') AS end_time
        UNION ALL
        SELECT
            DATEADD(DAY, 1, date) AS date,
            TIME('09:00:00') AS start_time,
            TIME('20:00:00') AS end_time
        FROM FreeTimeSlots
        WHERE date < @end_date
    )

    SELECT
        f.date,
        f.start_time,
        f.end_time
    FROM FreeTimeSlots f
    LEFT JOIN schedule s ON f.date = s.date AND @barber_id = s.barber_id
    WHERE s.date IS NULL;
END;


CREATE PROCEDURE ArchivePastServices
AS
BEGIN
    -- Переместим завершенные услуги в таблицу архива (предполагается, что она существует)
    INSERT INTO service_archive
    SELECT * FROM client_visits
    WHERE date < GETDATE();

    -- Удаляем перемещенные услуги из таблицы посещений
    DELETE FROM client_visits
    WHERE date < GETDATE();
END;


CREATE TRIGGER PreventBookingOnOccupiedSlot
ON schedule
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @barber_id INT, @date DATE, @start_time TIME, @end_time TIME;

    SELECT @barber_id = inserted.barber_id, @date = inserted.date, @start_time = inserted.start_time, @end_time = inserted.end_time
    FROM inserted;

    -- Проверяем, есть ли уже запись у этого барбера на данное время и дату
    IF EXISTS (
        SELECT 1
        FROM schedule
        WHERE barber_id = @barber_id
        AND date = @date
        AND ((start_time <= @start_time AND end_time > @start_time) OR
             (start_time < @end_time AND end_time >= @end_time))
    )
    BEGIN
        -- Если запись найдена, отменяем вставку и выбрасываем ошибку
        THROW 50000, 'Запись на уже занятое время не разрешена.', 1;
    END
END;


CREATE TRIGGER PreventNewJuniorBarber
ON barbers
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @new_position VARCHAR(20);

    -- Проверяем позицию нового барбера
    SELECT @new_position = inserted.position
    FROM inserted;

    IF @new_position = 'junior-barber'
    BEGIN
        -- Считаем текущее количество junior-барберов
        DECLARE @current_junior_barbers_count INT = (
            SELECT COUNT(*)
            FROM barbers
            WHERE position = 'junior-barber'
        );

        -- Если количество junior-барберов равно 5, отменяем вставку и выбрасываем ошибку
        IF @current_junior_barbers_count >= 5
        BEGIN
            THROW 50000, 'Невозможно добавить нового junior-barber, так как уже работают 5 junior-barbers.', 1;
        END
    END
END;


CREATE FUNCTION GetClientsWithoutFeedbackAndRating()
RETURNS TABLE
AS
RETURN
(
    SELECT
        c.id,
        c.full_name,
        c.phone,
        c.email
    FROM clients c
    LEFT JOIN client_visits cv ON c.id = cv.client_id
    WHERE cv.id IS NULL OR (cv.feedback IS NULL AND cv.rating IS NULL)
);


CREATE FUNCTION GetInactiveClients()
RETURNS TABLE
AS
RETURN
(
    SELECT
        c.id,
        c.full_name,
        c.phone,
        c.email
    FROM clients c
    JOIN client_visits cv ON c.id = cv.client_id
    WHERE cv.date < DATEADD(YEAR, -1, GETDATE())
);
