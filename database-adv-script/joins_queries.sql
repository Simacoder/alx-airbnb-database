-- =====================================================
-- ALX Airbnb Database Module: Complex Queries with Joins
-- =====================================================

-- AUTHOR: Simanga Mchunu
-- DATE: 2023-10-01

-- Query 1: INNER JOIN - Retrieve all bookings with respective users
-- =====================================================
-- Purpose: Get all bookings along with user information who made those bookings
-- Only returns records where both booking and user exist (intersection)



SELECT 
    CONCAT(u.first_name, ' ', u.last_name) AS guest_name,
    u.email AS guest_email,
    b.booking_id,
    b.start_date,
    b.end_date,
    DATEDIFF(b.end_date, b.start_date) AS nights_stayed,
    b.total_price,
    ROUND(b.total_price / DATEDIFF(b.end_date, b.start_date), 2) AS price_per_night,
    b.status AS booking_status
FROM 
    Booking b
INNER JOIN 
    User u ON b.user_id = u.user_id
WHERE 
    b.status IN ('confirmed', 'completed')
ORDER BY 
    b.start_date DESC;


-- Query 2: LEFT JOIN - Retrieve all properties and their reviews
-- =====================================================
-- Purpose: Get all properties including those without reviews
-- Shows all properties (left table) and matching reviews (right table)

SELECT 
    p.property_id,
    p.name AS property_name,
    p.description,
    p.location,
    p.pricepernight,
    p.created_at AS property_created_at,
    r.review_id,
    r.rating,
    r.comment,
    r.created_at AS review_created_at,
    CONCAT(u.first_name, ' ', u.last_name) AS reviewer_name
FROM 
    Property p
LEFT JOIN 
    Review r ON p.property_id = r.property_id
LEFT JOIN 
    User u ON r.user_id = u.user_id
ORDER BY 
    p.property_id, r.created_at DESC;

-- Summary version showing review statistics per property
SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    COUNT(r.review_id) AS total_reviews,
    ROUND(AVG(r.rating), 2) AS average_rating,
    MAX(r.created_at) AS latest_review_date,
    CASE 
        WHEN COUNT(r.review_id) = 0 THEN 'No Reviews'
        WHEN AVG(r.rating) >= 4.5 THEN 'Excellent'
        WHEN AVG(r.rating) >= 4.0 THEN 'Very Good'
        WHEN AVG(r.rating) >= 3.5 THEN 'Good'
        WHEN AVG(r.rating) >= 3.0 THEN 'Average'
        ELSE 'Below Average'
    END AS rating_category
FROM 
    Property p
LEFT JOIN 
    Review r ON p.property_id = r.property_id
GROUP BY 
    p.property_id, p.name, p.location, p.pricepernight
ORDER BY 
    average_rating DESC NULLS LAST, total_reviews DESC;


-- Query 3: FULL OUTER JOIN - Retrieve all users and all bookings
-- =====================================================
-- Purpose: Get all users and all bookings, including unmatched records
-- Shows users without bookings and bookings without valid users

-- Note: MySQL doesn't support FULL OUTER JOIN directly
-- We'll use UNION of LEFT JOIN and RIGHT JOIN to simulate it

SELECT 
    u.user_id,
    CONCAT(u.first_name, ' ', u.last_name) AS user_name,
    u.email,
    u.phone_number,
    u.role,
    u.created_at AS user_created_at,
    b.booking_id,
    b.property_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status AS booking_status,
    b.created_at AS booking_created_at,
    CASE 
        WHEN b.booking_id IS NULL THEN 'User with no bookings'
        WHEN u.user_id IS NULL THEN 'Booking with invalid user'
        ELSE 'Valid user-booking pair'
    END AS record_type
FROM 
    User u
LEFT JOIN 
    Booking b ON u.user_id = b.user_id

UNION

SELECT 
    u.user_id,
    CONCAT(u.first_name, ' ', u.last_name) AS user_name,
    u.email,
    u.phone_number,
    u.role,
    u.created_at AS user_created_at,
    b.booking_id,
    b.property_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status AS booking_status,
    b.created_at AS booking_created_at,
    CASE 
        WHEN b.booking_id IS NULL THEN 'User with no bookings'
        WHEN u.user_id IS NULL THEN 'Booking with invalid user'
        ELSE 'Valid user-booking pair'
    END AS record_type
FROM 
    User u
RIGHT JOIN 
    Booking b ON u.user_id = b.user_id
WHERE 
    u.user_id IS NULL

ORDER BY 
    user_id NULLS LAST, booking_created_at DESC;

--- Complex multi-table join with aggregations
-- =====================================================
-- Purpose: Comprehensive view combining users, bookings, properties, and reviews

SELECT 
    u.user_id,
    CONCAT(u.first_name, ' ', u.last_name) AS user_name,
    u.email,
    COUNT(DISTINCT b.booking_id) AS total_bookings,
    COUNT(DISTINCT r.review_id) AS total_reviews,
    ROUND(AVG(r.rating), 2) AS average_rating_given,
    SUM(b.total_price) AS total_spent,
    MAX(b.created_at) AS last_booking_date,
    DATEDIFF(CURDATE(), MAX(b.created_at)) AS days_since_last_booking
FROM 
    User u
LEFT JOIN 
    Booking b ON u.user_id = b.user_id
LEFT JOIN 
    Review r ON u.user_id = r.user_id
WHERE 
    u.role = 'guest'
GROUP BY 
    u.user_id, u.first_name, u.last_name, u.email
HAVING 
    COUNT(DISTINCT b.booking_id) > 0 OR COUNT(DISTINCT r.review_id) > 0
ORDER BY 
    total_spent DESC NULLS LAST;