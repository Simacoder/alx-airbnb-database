-- =====================================================
-- ALX Airbnb Database Module: Practice Subqueries
-- =====================================================

-- AUTHOR: Simanga Mchunu

-- Query 1: Non-Correlated Subquery - Properties with Average Rating > 4.0
-- =====================================================
-- Purpose: Find all properties where the average rating is greater than 4.0
-- This is a non-correlated subquery because the inner query can run independently

SELECT 
    p.property_id,
    p.name AS property_name,
    p.description,
    p.location,
    p.pricepernight,
    p.created_at,
    -- Include the actual average rating for verification
    (SELECT ROUND(AVG(r.rating), 2) 
     FROM Review r 
     WHERE r.property_id = p.property_id) AS average_rating,
    -- Count of reviews
    (SELECT COUNT(*) 
     FROM Review r 
     WHERE r.property_id = p.property_id) AS total_reviews
FROM 
    Property p
WHERE 
    p.property_id IN (
        SELECT r.property_id
        FROM Review r
        GROUP BY r.property_id
        HAVING AVG(r.rating) > 4.0
    )
ORDER BY 
    average_rating DESC, total_reviews DESC;


-- Query 2: Correlated Subquery - Users with More Than 3 Bookings
-- =====================================================
-- Purpose: Find users who have made more than 3 bookings
-- This is a correlated subquery because the inner query references the outer query

SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.phone_number,
    u.role,
    u.created_at,
    -- Correlated subquery to count bookings for each user
    (SELECT COUNT(*) 
     FROM Booking b 
     WHERE b.user_id = u.user_id) AS total_bookings,
    -- Additional correlated subqueries for more insights
    (SELECT SUM(b.total_price) 
     FROM Booking b 
     WHERE b.user_id = u.user_id) AS total_spent,
    (SELECT MAX(b.created_at) 
     FROM Booking b 
     WHERE b.user_id = u.user_id) AS last_booking_date,
    (SELECT MIN(b.created_at) 
     FROM Booking b 
     WHERE b.user_id = u.user_id) AS first_booking_date
FROM 
    User u
WHERE 
    (SELECT COUNT(*) 
     FROM Booking b 
     WHERE b.user_id = u.user_id) > 3
ORDER BY 
    total_bookings DESC, total_spent DESC;

-- Complex Nested Subqueries
-- =====================================================

-- Find properties with above-average ratings in their location
SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    (SELECT ROUND(AVG(r.rating), 2) 
     FROM Review r 
     WHERE r.property_id = p.property_id) AS property_rating,
    (SELECT ROUND(AVG(inner_avg.avg_rating), 2)
     FROM (
         SELECT AVG(r2.rating) as avg_rating
         FROM Property p2
         JOIN Review r2 ON p2.property_id = r2.property_id
         WHERE p2.location = p.location
         GROUP BY p2.property_id
     ) as inner_avg) AS location_avg_rating
FROM 
    Property p
WHERE 
    (SELECT AVG(r.rating) 
     FROM Review r 
     WHERE r.property_id = p.property_id) > 
    (SELECT AVG(inner_avg.avg_rating)
     FROM (
         SELECT AVG(r2.rating) as avg_rating
         FROM Property p2
         JOIN Review r2 ON p2.property_id = r2.property_id
         WHERE p2.location = p.location
         GROUP BY p2.property_id
     ) as inner_avg)
    AND EXISTS (
        SELECT 1 
        FROM Review r 
        WHERE r.property_id = p.property_id
    )
ORDER BY 
    p.location, property_rating DESC;

-- Find users who have spent more than the average user spending
SELECT 
    u.user_id,
    CONCAT(u.first_name, ' ', u.last_name) AS user_name,
    u.email,
    (SELECT COALESCE(SUM(b.total_price), 0) 
     FROM Booking b 
     WHERE b.user_id = u.user_id) AS total_spent,
    (SELECT ROUND(AVG(user_totals.total), 2)
     FROM (
         SELECT COALESCE(SUM(b2.total_price), 0) as total
         FROM User u2
         LEFT JOIN Booking b2 ON u2.user_id = b2.user_id
         GROUP BY u2.user_id
     ) as user_totals
     WHERE user_totals.total > 0) AS avg_user_spending
FROM 
    User u
WHERE 
    (SELECT COALESCE(SUM(b.total_price), 0) 
     FROM Booking b 
     WHERE b.user_id = u.user_id) > 
    (SELECT AVG(user_totals.total)
     FROM (
         SELECT COALESCE(SUM(b2.total_price), 0) as total
         FROM User u2
         LEFT JOIN Booking b2 ON u2.user_id = b2.user_id
         GROUP BY u2.user_id
     ) as user_totals
     WHERE user_totals.total > 0)
ORDER BY 
    total_spent DESC;