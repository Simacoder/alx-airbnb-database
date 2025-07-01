-- =====================================================
-- ALX Airbnb Database Module: Query Performance Optimization
-- File: performance.sql
-- Purpose: Demonstrate query optimization techniques
-- =====================================================
-- AUTHOR: Simanga Mchunu

-- =====================================================
-- 1. INITIAL COMPLEX QUERY (UNOPTIMIZED)
-- =====================================================

/*
INITIAL QUERY ANALYSIS:
This query retrieves all bookings with complete user, property, and payment details.
It demonstrates common performance issues that need optimization.

POTENTIAL ISSUES:
1. Uses SELECT * which retrieves unnecessary columns
2. Multiple JOINs without proper indexing considerations
3. No filtering conditions - retrieves ALL data
4. Suboptimal JOIN order
5. Missing indexes on JOIN conditions
6. No LIMIT clause for large datasets
*/

-- Initial unoptimized query
SELECT *
FROM Booking b
JOIN User u ON b.user_id = u.user_id
JOIN Property p ON b.property_id = p.property_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
ORDER BY b.created_at DESC;

-- =====================================================
-- 2. PERFORMANCE ANALYSIS OF INITIAL QUERY
-- =====================================================

-- Analyze the initial query performance
EXPLAIN SELECT *
FROM Booking b
JOIN User u ON b.user_id = u.user_id
JOIN Property p ON b.property_id = p.property_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
ORDER BY b.created_at DESC;

-- Get detailed execution statistics
EXPLAIN ANALYZE SELECT *
FROM Booking b
JOIN User u ON b.user_id = u.user_id
JOIN Property p ON b.property_id = p.property_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
ORDER BY b.created_at DESC
LIMIT 100; -- Adding LIMIT to prevent timeout in analysis

-- =====================================================
-- 3. IDENTIFIED PERFORMANCE ISSUES
-- =====================================================

/*
PERFORMANCE ISSUES IDENTIFIED:

1. FULL TABLE SCANS:
   - Without proper indexes, MySQL may scan entire tables
   - JOIN operations become expensive with large datasets

2. EXCESSIVE DATA RETRIEVAL:
   - SELECT * retrieves all columns from all tables
   - Network overhead and memory usage increase unnecessarily

3. MISSING INDEXES:
   - Foreign key columns may lack proper indexes
   - ORDER BY column (created_at) may not be indexed

4. SUBOPTIMAL JOIN ORDER:
   - Database engine may choose inefficient join order
   - Larger tables joined first increase intermediate result sets

5. NO FILTERING:
   - Query retrieves ALL bookings regardless of relevance
   - No date ranges, status filters, or user-specific conditions

6. INEFFICIENT SORTING:
   - ORDER BY on large result set without LIMIT
   - May require temporary tables or filesort operations
*/

-- =====================================================
-- 4. STEP-BY-STEP OPTIMIZATION PROCESS
-- =====================================================

-- =====================================================
-- 4.1 CREATE NECESSARY INDEXES (if not already created)
-- =====================================================

-- Ensure foreign key indexes exist for optimal JOINs
CREATE INDEX IF NOT EXISTS idx_booking_user_id ON Booking(user_id);
CREATE INDEX IF NOT EXISTS idx_booking_property_id ON Booking(property_id);
CREATE INDEX IF NOT EXISTS idx_payment_booking_id ON Payment(booking_id);
CREATE INDEX IF NOT EXISTS idx_booking_created_at ON Booking(created_at);

-- Composite indexes for common query patterns
CREATE INDEX IF NOT EXISTS idx_booking_status_created ON Booking(status, created_at);
CREATE INDEX IF NOT EXISTS idx_booking_user_status ON Booking(user_id, status);

-- =====================================================
-- 4.2 OPTIMIZATION STEP 1: SELECT SPECIFIC COLUMNS
-- =====================================================

-- Optimized query - Step 1: Select only needed columns
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    b.created_at,
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    pay.payment_id,
    pay.amount AS payment_amount,
    pay.payment_date,
    pay.payment_method
FROM Booking b
JOIN User u ON b.user_id = u.user_id
JOIN Property p ON b.property_id = p.property_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
ORDER BY b.created_at DESC
LIMIT 100;

-- Test performance improvement
EXPLAIN ANALYZE SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    b.created_at,
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    pay.payment_id,
    pay.amount AS payment_amount,
    pay.payment_date,
    pay.payment_method
FROM Booking b
JOIN User u ON b.user_id = u.user_id
JOIN Property p ON b.property_id = p.property_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
ORDER BY b.created_at DESC
LIMIT 100;

-- =====================================================
-- 4.3 OPTIMIZATION STEP 2: ADD FILTERING CONDITIONS
-- =====================================================

-- Optimized query - Step 2: Add meaningful filters
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    b.created_at,
    u.first_name,
    u.last_name,
    u.email,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    pay.amount AS payment_amount,
    pay.payment_date,
    pay.payment_method
FROM Booking b
JOIN User u ON b.user_id = u.user_id
JOIN Property p ON b.property_id = p.property_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
WHERE b.created_at >= DATE_SUB(CURRENT_DATE, INTERVAL 1 YEAR)  -- Last year only
AND b.status IN ('confirmed', 'completed', 'cancelled')        -- Specific statuses
ORDER BY b.created_at DESC
LIMIT 100;

-- Test performance with filters
EXPLAIN ANALYZE SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    b.created_at,
    u.first_name,
    u.last_name,
    u.email,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    pay.amount AS payment_amount,
    pay.payment_date,
    pay.payment_method
FROM Booking b
JOIN User u ON b.user_id = u.user_id
JOIN Property p ON b.property_id = p.property_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
WHERE b.created_at >= DATE_SUB(CURRENT_DATE, INTERVAL 1 YEAR)
AND b.status IN ('confirmed', 'completed', 'cancelled')
ORDER BY b.created_at DESC
LIMIT 100;

-- =====================================================
-- 4.4 OPTIMIZATION STEP 3: OPTIMIZE JOIN ORDER
-- =====================================================

-- Optimized query - Step 3: Strategic join order (start with most selective table)
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    b.created_at,
    u.first_name,
    u.last_name,
    u.email,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    pay.amount AS payment_amount,
    pay.payment_date,
    pay.payment_method
FROM Booking b
STRAIGHT_JOIN User u ON b.user_id = u.user_id  -- Force join order
STRAIGHT_JOIN Property p ON b.property_id = p.property_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
WHERE b.created_at >= DATE_SUB(CURRENT_DATE, INTERVAL 1 YEAR)
AND b.status IN ('confirmed', 'completed')
ORDER BY b.created_at DESC
LIMIT 100;

-- =====================================================
-- 4.5 OPTIMIZATION STEP 4: USE COVERING INDEXES
-- =====================================================

-- Create covering index for the most common query pattern
CREATE INDEX IF NOT EXISTS idx_booking_covering 
ON Booking(status, created_at, user_id, property_id, booking_id, start_date, end_date, total_price);

-- Optimized query using covering index
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    b.created_at,
    u.first_name,
    u.last_name,
    u.email,
    p.name AS property_name,
    p.location
FROM Booking b
JOIN User u ON b.user_id = u.user_id
JOIN Property p ON b.property_id = p.property_id
WHERE b.status = 'confirmed'
AND b.created_at >= DATE_SUB(CURRENT_DATE, INTERVAL 6 MONTH)
ORDER BY b.created_at DESC
LIMIT 50;

-- =====================================================
-- 5. FINAL OPTIMIZED QUERIES FOR DIFFERENT USE CASES
-- =====================================================

-- =====================================================
-- 5.1 OPTIMIZED QUERY: RECENT BOOKINGS WITH PAYMENT INFO
-- =====================================================

SELECT 
    b.booking_id,
    CONCAT(u.first_name, ' ', u.last_name) AS guest_name,
    u.email,
    p.name AS property_name,
    p.location,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    pay.payment_method,
    pay.amount AS payment_amount,
    pay.payment_date
FROM Booking b
JOIN User u ON b.user_id = u.user_id
JOIN Property p ON b.property_id = p.property_id
INNER JOIN Payment pay ON b.booking_id = pay.booking_id  -- Only bookings with payments
WHERE b.status IN ('confirmed', 'completed')
AND b.created_at >= DATE_SUB(CURRENT_DATE, INTERVAL 3 MONTH)
AND pay.payment_date IS NOT NULL
ORDER BY b.created_at DESC
LIMIT 100;

-- Performance analysis
EXPLAIN ANALYZE SELECT 
    b.booking_id,
    CONCAT(u.first_name, ' ', u.last_name) AS guest_name,
    u.email,
    p.name AS property_name,
    p.location,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    pay.payment_method,
    pay.amount AS payment_amount,
    pay.payment_date
FROM Booking b
JOIN User u ON b.user_id = u.user_id
JOIN Property p ON b.property_id = p.property_id
INNER JOIN Payment pay ON b.booking_id = pay.booking_id
WHERE b.status IN ('confirmed', 'completed')
AND b.created_at >= DATE_SUB(CURRENT_DATE, INTERVAL 3 MONTH)
AND pay.payment_date IS NOT NULL
ORDER BY b.created_at DESC
LIMIT 100;

-- =====================================================
-- 5.2 OPTIMIZED QUERY: USER-SPECIFIC BOOKINGS
-- =====================================================

-- When querying for specific user (most selective filter first)
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    pay.amount AS payment_amount,
    pay.payment_method,
    pay.payment_date
FROM User u
JOIN Booking b ON u.user_id = b.user_id  -- Start with User table when filtering by user
JOIN Property p ON b.property_id = p.property_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
WHERE u.email = 'specific@user.com'  -- Highly selective filter
ORDER BY b.created_at DESC
LIMIT 20;

-- =====================================================
-- 5.3 OPTIMIZED QUERY: PROPERTY-SPECIFIC BOOKINGS
-- =====================================================

-- When querying for specific property
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    CONCAT(u.first_name, ' ', u.last_name) AS guest_name,
    u.email,
    u.phone,
    pay.amount AS payment_amount,
    pay.payment_method,
    pay.payment_date
FROM Property p
JOIN Booking b ON p.property_id = b.property_id  -- Start with Property when filtering by property
JOIN User u ON b.user_id = u.user_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
WHERE p.property_id = 123  -- Highly selective filter
AND b.start_date >= CURRENT_DATE  -- Future bookings only
ORDER BY b.start_date ASC
LIMIT 50;

-- =====================================================
-- 6. PERFORMANCE COMPARISON QUERIES
-- =====================================================

-- =====================================================
-- 6.1 BEFORE OPTIMIZATION (Baseline)
-- =====================================================

-- Original inefficient query for comparison
EXPLAIN ANALYZE SELECT *
FROM Booking b
JOIN User u ON b.user_id = u.user_id
JOIN Property p ON b.property_id = p.property_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
ORDER BY b.created_at DESC
LIMIT 100;

-- =====================================================
-- 6.2 AFTER OPTIMIZATION (Improved)
-- =====================================================

-- Final optimized query for comparison
EXPLAIN ANALYZE SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    b.created_at,
    CONCAT(u.first_name, ' ', u.last_name) AS guest_name,
    u.email,
    p.name AS property_name,
    p.location,
    pay.amount AS payment_amount,
    pay.payment_method
FROM Booking b
JOIN User u ON b.user_id = u.user_id
JOIN Property p ON b.property_id = p.property_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
WHERE b.status IN ('confirmed', 'completed')
AND b.created_at >= DATE_SUB(CURRENT_DATE, INTERVAL 6 MONTH)
ORDER BY b.created_at DESC
LIMIT 100;

-- =====================================================
-- 7. ADVANCED OPTIMIZATION TECHNIQUES
-- =====================================================

-- =====================================================
-- 7.1 USING SUBQUERIES FOR BETTER PERFORMANCE
-- =====================================================

-- When you need aggregated payment info, use subquery instead of JOIN
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    CONCAT(u.first_name, ' ', u.last_name) AS guest_name,
    u.email,
    p.name AS property_name,
    p.location,
    (SELECT SUM(amount) 
     FROM Payment 
     WHERE booking_id = b.booking_id) AS total_paid,
    (SELECT payment_method 
     FROM Payment 
     WHERE booking_id = b.booking_id 
     ORDER BY payment_date DESC 
     LIMIT 1) AS latest_payment_method
FROM Booking b
JOIN User u ON b.user_id = u.user_id
JOIN Property p ON b.property_id = p.property_id
WHERE b.status = 'completed'
AND b.created_at >= DATE_SUB(CURRENT_DATE, INTERVAL 1 YEAR)
ORDER BY b.created_at DESC
LIMIT 100;

-- =====================================================
-- 7.2 USING MATERIALIZED VIEW CONCEPT (CTE)
-- =====================================================

-- Using Common Table Expression for complex filtering
WITH RecentBookings AS (
    SELECT 
        booking_id,
        user_id,
        property_id,
        start_date,
        end_date,
        total_price,
        status,
        created_at
    FROM Booking
    WHERE created_at >= DATE_SUB(CURRENT_DATE, INTERVAL 6 MONTH)
    AND status IN ('confirmed', 'completed')
),
BookingPayments AS (
    SELECT 
        booking_id,
        SUM(amount) AS total_paid,
        COUNT(*) AS payment_count,
        MAX(payment_date) AS last_payment_date
    FROM Payment
    WHERE payment_date >= DATE_SUB(CURRENT_DATE, INTERVAL 6 MONTH)
    GROUP BY booking_id
)
SELECT 
    rb.booking_id,
    rb.start_date,
    rb.end_date,
    rb.total_price,
    rb.status,
    CONCAT(u.first_name, ' ', u.last_name) AS guest_name,
    u.email,
    p.name AS property_name,
    p.location,
    bp.total_paid,
    bp.payment_count,
    bp.last_payment_date
FROM RecentBookings rb
JOIN User u ON rb.user_id = u.user_id
JOIN Property p ON rb.property_id = p.property_id
LEFT JOIN BookingPayments bp ON rb.booking_id = bp.booking_id
ORDER BY rb.created_at DESC
LIMIT 100;

-- =====================================================
-- 8. PERFORMANCE MONITORING AND VALIDATION
-- =====================================================

-- Query to monitor slow queries
-- SELECT 
--     SQL_TEXT,
--     EXEC_COUNT,
--     TOTAL_LATENCY,
--     AVG_LATENCY,
--     ROWS_EXAMINED_AVG,
--     ROWS_SENT_AVG,
--     CREATED_TMP_TABLES,
--     CREATED_TMP_DISK_TABLES
-- FROM sys.x$statement_analysis
-- WHERE EXEC_COUNT > 10
-- ORDER BY AVG_LATENCY DESC
-- LIMIT 10;

-- =====================================================
-- 9. INDEX RECOMMENDATIONS FOR OPTIMAL PERFORMANCE
-- =====================================================

/*
RECOMMENDED INDEXES FOR OPTIMAL QUERY PERFORMANCE:

1. PRIMARY INDEXES (should already exist):
   - User(user_id) - Primary Key
   - Booking(booking_id) - Primary Key  
   - Property(property_id) - Primary Key
   - Payment(payment_id) - Primary Key

2. FOREIGN KEY INDEXES:
   - Booking(user_id) - for User JOINs
   - Booking(property_id) - for Property JOINs
   - Payment(booking_id) - for Payment JOINs

3. FILTERING INDEXES:
   - Booking(status) - for status filtering
   - Booking(created_at) - for date range queries
   - User(email) - for user lookup
   - Payment(payment_date) - for payment date filtering

4. COMPOSITE INDEXES:
   - Booking(status, created_at) - for filtered date queries
   - Booking(user_id, status) - for user-specific status queries
   - Booking(property_id, start_date, end_date) - for availability queries

5. COVERING INDEXES (for specific high-frequency queries):
   - Booking(status, created_at, user_id, property_id, booking_id, total_price)

IMPLEMENTATION:
Run the index creation commands from database_index.sql to implement these optimizations.
*/

-- =====================================================
-- 10. PERFORMANCE TESTING SUMMARY
-- =====================================================

/*
OPTIMIZATION RESULTS SUMMARY:

TECHNIQUES APPLIED:
1. ✓ Select specific columns instead of SELECT *
2. ✓ Added appropriate WHERE clauses for filtering
3. ✓ Implemented proper indexing strategy
4. ✓ Optimized JOIN order for better performance
5. ✓ Used covering indexes where applicable
6. ✓ Added LIMIT clauses to prevent large result sets
7. ✓ Used INNER JOIN instead of LEFT JOIN where appropriate
8. ✓ Implemented subqueries for aggregation efficiency
9. ✓ Used CTEs for complex filtering logic

EXPECTED PERFORMANCE IMPROVEMENTS:
- Query execution time: 70-90% reduction
- Rows examined: 80-95% reduction  
- Memory usage: 60-80% reduction
- CPU usage: 50-70% reduction
- I/O operations: 70-90% reduction

MEASUREMENT COMMANDS:
- Use EXPLAIN to see query execution plan
- Use EXPLAIN ANALYZE to get actual performance metrics
- Compare execution times before and after optimization
- Monitor index usage with performance_schema queries

MAINTENANCE RECOMMENDATIONS:
- Regularly run ANALYZE TABLE to update index statistics
- Monitor query performance with sys.x$statement_analysis
- Review and update indexes based on query patterns
- Consider partitioning for very large tables
*/

-- =====================================================
-- END OF PERFORMANCE OPTIMIZATION
-- =====================================================