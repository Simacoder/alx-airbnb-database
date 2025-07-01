-- =====================================================
-- ALX Airbnb Database Module: Aggregations and Window Functions
-- =====================================================

-- AUTHOR: Simanga Mchunu
-- DATE: 2023-10-01


-- Query 1: Aggregations - Total Bookings per User using COUNT and GROUP BY
-- =====================================================
-- Purpose: Find the total number of bookings made by each user
-- Demonstrates basic aggregation with GROUP BY

--- Total bookings per user

-- comprehensive booking statistics
SELECT 
    u.user_id,
    CONCAT(u.first_name, ' ', u.last_name) AS user_name,
    u.email,
    u.role,
    u.created_at AS user_since,
    -- Total bookings count
    COUNT(b.booking_id) AS total_bookings,
    -- Bookings by status
    COUNT(CASE WHEN b.status = 'confirmed' THEN 1 END) AS confirmed_bookings,
    COUNT(CASE WHEN b.status = 'completed' THEN 1 END) AS completed_bookings,
    COUNT(CASE WHEN b.status = 'cancelled' THEN 1 END) AS cancelled_bookings,
    COUNT(CASE WHEN b.status = 'pending' THEN 1 END) AS pending_bookings,
    -- Financial aggregations
    COALESCE(SUM(b.total_price), 0) AS total_spent,
    COALESCE(ROUND(AVG(b.total_price), 2), 0) AS avg_booking_value,
    COALESCE(MIN(b.total_price), 0) AS min_booking_value,
    COALESCE(MAX(b.total_price), 0) AS max_booking_value,
    -- Date aggregations
    MIN(b.created_at) AS first_booking_date,
    MAX(b.created_at) AS latest_booking_date,
    -- Calculate days between first and last booking
    CASE 
        WHEN MIN(b.created_at) = MAX(b.created_at) THEN 0
        WHEN MIN(b.created_at) IS NULL THEN NULL
        ELSE DATEDIFF(MAX(b.created_at), MIN(b.created_at))
    END AS days_between_first_last_booking,
    -- User activity categorization
    CASE 
        WHEN COUNT(b.booking_id) = 0 THEN 'No Bookings'
        WHEN COUNT(b.booking_id) = 1 THEN 'One-time User'
        WHEN COUNT(b.booking_id) BETWEEN 2 AND 5 THEN 'Occasional User'
        WHEN COUNT(b.booking_id) BETWEEN 6 AND 10 THEN 'Regular User'
        ELSE 'Power User'
    END AS user_category
FROM 
    User u
LEFT JOIN 
    Booking b ON u.user_id = b.user_id
GROUP BY 
    u.user_id, u.first_name, u.last_name, u.email, u.role, u.created_at
ORDER BY 
    total_bookings DESC, total_spent DESC;

-- Users with bookings only (excluding users with zero bookings)
SELECT 
    u.user_id,
    CONCAT(u.first_name, ' ', u.last_name) AS user_name,
    u.email,
    COUNT(b.booking_id) AS total_bookings,
    SUM(b.total_price) AS total_spent,
    ROUND(AVG(b.total_price), 2) AS avg_booking_value,
    MIN(b.start_date) AS earliest_stay_date,
    MAX(b.end_date) AS latest_stay_date
FROM 
    User u
INNER JOIN 
    Booking b ON u.user_id = b.user_id
GROUP BY 
    u.user_id, u.first_name, u.last_name, u.email
HAVING 
    COUNT(b.booking_id) > 0
ORDER BY 
    total_bookings DESC, total_spent DESC;


-- Query 2: Window Functions - Ranking Properties by Total Bookings
-- =====================================================
-- Purpose: Rank properties based on total number of bookings received
-- Demonstrates ROW_NUMBER, RANK, DENSE_RANK window functions

-- Property rankings by total bookings and revenue
SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    COUNT(b.booking_id) AS total_bookings,
    SUM(COALESCE(b.total_price, 0)) AS total_revenue,
    -- Overall rankings
    ROW_NUMBER() OVER (ORDER BY COUNT(b.booking_id) DESC) AS overall_rank,
    RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS overall_rank_with_ties,
    -- Rankings within each location
    ROW_NUMBER() OVER (PARTITION BY p.location ORDER BY COUNT(b.booking_id) DESC) AS location_rank,
    RANK() OVER (PARTITION BY p.location ORDER BY COUNT(b.booking_id) DESC) AS location_rank_with_ties,
    -- Rankings by revenue
    ROW_NUMBER() OVER (ORDER BY SUM(COALESCE(b.total_price, 0)) DESC) AS revenue_rank,
    -- Rankings by price per night
    ROW_NUMBER() OVER (ORDER BY p.pricepernight DESC) AS price_rank,
    -- Calculate percentiles
    NTILE(4) OVER (ORDER BY COUNT(b.booking_id) DESC) AS booking_quartile,
    NTILE(10) OVER (ORDER BY COUNT(b.booking_id) DESC) AS booking_decile
FROM 
    Property p
LEFT JOIN 
    Booking b ON p.property_id = b.property_id
GROUP BY 
    p.property_id, p.name, p.location, p.pricepernight
ORDER BY 
    total_bookings DESC, total_revenue DESC;

-- window functions with running totals and moving averages
SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    COUNT(b.booking_id) AS total_bookings,
    SUM(COALESCE(b.total_price, 0)) AS total_revenue,
    -- Basic rankings
    ROW_NUMBER() OVER (ORDER BY COUNT(b.booking_id) DESC) AS booking_rank,
    -- Running totals
    SUM(COUNT(b.booking_id)) OVER (ORDER BY COUNT(b.booking_id) DESC 
                                   ROWS UNBOUNDED PRECEDING) AS running_total_bookings,
    SUM(SUM(COALESCE(b.total_price, 0))) OVER (ORDER BY COUNT(b.booking_id) DESC 
                                               ROWS UNBOUNDED PRECEDING) AS running_total_revenue,
    -- Moving averages (3-property window)
    AVG(COUNT(b.booking_id)) OVER (ORDER BY COUNT(b.booking_id) DESC 
                                   ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) AS moving_avg_bookings_3,
    -- Lag and Lead functions
    LAG(COUNT(b.booking_id), 1) OVER (ORDER BY COUNT(b.booking_id) DESC) AS prev_property_bookings,
    LEAD(COUNT(b.booking_id), 1) OVER (ORDER BY COUNT(b.booking_id) DESC) AS next_property_bookings,
    -- Calculate difference from previous
    COUNT(b.booking_id) - LAG(COUNT(b.booking_id), 1) OVER (ORDER BY COUNT(b.booking_id) DESC) AS booking_diff_from_prev,
    -- First and last values in the dataset
    FIRST_VALUE(p.name) OVER (ORDER BY COUNT(b.booking_id) DESC 
                              ROWS UNBOUNDED PRECEDING) AS top_property_name,
    LAST_VALUE(p.name) OVER (ORDER BY COUNT(b.booking_id) DESC 
                             ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS bottom_property_name
FROM 
    Property p
LEFT JOIN 
    Booking b ON p.property_id = b.property_id
GROUP BY 
    p.property_id, p.name, p.location, p.pricepernight
ORDER BY 
    total_bookings DESC;


-- Time-based booking analysis using window functions
SELECT 
    DATE_FORMAT(b.created_at, '%Y-%m') AS booking_month,
    COUNT(*) AS monthly_bookings,
    SUM(b.total_price) AS monthly_revenue,
    -- Running totals
    SUM(COUNT(*)) OVER (ORDER BY DATE_FORMAT(b.created_at, '%Y-%m')) AS cumulative_bookings,
    SUM(SUM(b.total_price)) OVER (ORDER BY DATE_FORMAT(b.created_at, '%Y-%m')) AS cumulative_revenue,
    -- Month-over-month growth
    LAG(COUNT(*)) OVER (ORDER BY DATE_FORMAT(b.created_at, '%Y-%m')) AS prev_month_bookings,
    ROUND(((COUNT(*) - LAG(COUNT(*)) OVER (ORDER BY DATE_FORMAT(b.created_at, '%Y-%m'))) / 
           LAG(COUNT(*)) OVER (ORDER BY DATE_FORMAT(b.created_at, '%Y-%m')) * 100), 2) AS booking_growth_pct,
    -- Moving averages
    ROUND(AVG(COUNT(*)) OVER (ORDER BY DATE_FORMAT(b.created_at, '%Y-%m') 
                              ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS rolling_3month_avg_bookings
FROM Booking b
WHERE b.created_at IS NOT NULL
GROUP BY DATE_FORMAT(b.created_at, '%Y-%m')
ORDER BY booking_month;