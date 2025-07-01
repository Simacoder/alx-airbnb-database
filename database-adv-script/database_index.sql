-- =====================================================
-- ALX Airbnb Database Module: Index Implementation
-- File: database_index.sql
-- Purpose: Create indexes to optimize query performance
-- =====================================================
-- AUTHOR: Simanga Mchunu

-- =====================================================
-- 1. ANALYSIS OF HIGH-USAGE COLUMNS
-- =====================================================

/*
HIGH-USAGE COLUMNS IDENTIFIED:

USER TABLE:
- user_id: Primary key, frequently used in JOINs
- email: Used in WHERE clauses for user authentication/lookup
- role: Used in WHERE clauses for filtering by user type
- created_at: Used in ORDER BY and date range queries

BOOKING TABLE:
- booking_id: Primary key, frequently used in JOINs
- user_id: Foreign key, heavily used in JOINs with User table
- property_id: Foreign key, heavily used in JOINs with Property table
- start_date, end_date: Used in WHERE clauses for date range searches
- status: Used in WHERE clauses for filtering booking states
- created_at: Used in ORDER BY and date range queries
- total_price: Used in ORDER BY and aggregation queries

PROPERTY TABLE:
- property_id: Primary key, frequently used in JOINs
- location: Used in WHERE clauses for location-based searches
- pricepernight: Used in WHERE clauses for price filtering and ORDER BY
- created_at: Used in ORDER BY and date range queries

REVIEW TABLE:
- review_id: Primary key
- property_id: Foreign key, used in JOINs and GROUP BY
- user_id: Foreign key, used in JOINs
- rating: Used in WHERE clauses and aggregations
- created_at: Used in ORDER BY for recent reviews

PAYMENT TABLE:
- payment_id: Primary key
- booking_id: Foreign key, used in JOINs
- payment_date: Used in WHERE clauses for date filtering
- amount: Used in aggregations and ORDER BY
*/

-- =====================================================
-- 2. DROP EXISTING INDEXES (if recreating)
-- =====================================================

-- Drop indexes if they exist (use IF EXISTS for MySQL 5.7+)
-- Note: Adjust syntax based on your MySQL version

-- User table indexes
DROP INDEX IF EXISTS idx_user_email ON User;
DROP INDEX IF EXISTS idx_user_role ON User;
DROP INDEX IF EXISTS idx_user_created_at ON User;

-- Booking table indexes
DROP INDEX IF EXISTS idx_booking_user_id ON Booking;
DROP INDEX IF EXISTS idx_booking_property_id ON Booking;
DROP INDEX IF EXISTS idx_booking_dates ON Booking;
DROP INDEX IF EXISTS idx_booking_start_date ON Booking;
DROP INDEX IF EXISTS idx_booking_end_date ON Booking;
DROP INDEX IF EXISTS idx_booking_status ON Booking;
DROP INDEX IF EXISTS idx_booking_created_at ON Booking;
DROP INDEX IF EXISTS idx_booking_total_price ON Booking;
DROP INDEX IF EXISTS idx_booking_user_status ON Booking;
DROP INDEX IF EXISTS idx_booking_property_dates ON Booking;

-- Property table indexes
DROP INDEX IF EXISTS idx_property_location ON Property;
DROP INDEX IF EXISTS idx_property_pricepernight ON Property;
DROP INDEX IF EXISTS idx_property_created_at ON Property;
DROP INDEX IF EXISTS idx_property_location_price ON Property;

-- Review table indexes
DROP INDEX IF EXISTS idx_review_property_id ON Review;
DROP INDEX IF EXISTS idx_review_user_id ON Review;
DROP INDEX IF EXISTS idx_review_rating ON Review;
DROP INDEX IF EXISTS idx_review_created_at ON Review;
DROP INDEX IF EXISTS idx_review_property_rating ON Review;

-- Payment table indexes
DROP INDEX IF EXISTS idx_payment_booking_id ON Payment;
DROP INDEX IF EXISTS idx_payment_date ON Payment;
DROP INDEX IF EXISTS idx_payment_amount ON Payment;

-- =====================================================
-- 3. CREATE SINGLE-COLUMN INDEXES
-- =====================================================

-- USER TABLE INDEXES
-- Index on email for user authentication and lookups
CREATE INDEX idx_user_email ON User(email);

-- Index on role for filtering by user type
CREATE INDEX idx_user_role ON User(role);

-- Index on created_at for date-based queries and sorting
CREATE INDEX idx_user_created_at ON User(created_at);

-- BOOKING TABLE INDEXES
-- Index on user_id for JOIN operations with User table
CREATE INDEX idx_booking_user_id ON Booking(user_id);

-- Index on property_id for JOIN operations with Property table
CREATE INDEX idx_booking_property_id ON Booking(property_id);

-- Index on start_date for date range queries
CREATE INDEX idx_booking_start_date ON Booking(start_date);

-- Index on end_date for date range queries
CREATE INDEX idx_booking_end_date ON Booking(end_date);

-- Index on status for filtering by booking status
CREATE INDEX idx_booking_status ON Booking(status);

-- Index on created_at for chronological sorting
CREATE INDEX idx_booking_created_at ON Booking(created_at);

-- Index on total_price for price-based sorting and filtering
CREATE INDEX idx_booking_total_price ON Booking(total_price);

-- PROPERTY TABLE INDEXES
-- Index on location for location-based searches
CREATE INDEX idx_property_location ON Property(location);

-- Index on pricepernight for price-based filtering and sorting
CREATE INDEX idx_property_pricepernight ON Property(pricepernight);

-- Index on created_at for date-based queries
CREATE INDEX idx_property_created_at ON Property(created_at);

-- REVIEW TABLE INDEXES
-- Index on property_id for JOIN operations and aggregations
CREATE INDEX idx_review_property_id ON Review(property_id);

-- Index on user_id for JOIN operations
CREATE INDEX idx_review_user_id ON Review(user_id);

-- Index on rating for rating-based filtering and aggregations
CREATE INDEX idx_review_rating ON Review(rating);

-- Index on created_at for chronological sorting
CREATE INDEX idx_review_created_at ON Review(created_at);

-- PAYMENT TABLE INDEXES
-- Index on booking_id for JOIN operations
CREATE INDEX idx_payment_booking_id ON Payment(booking_id);

-- Index on payment_date for date-based queries
CREATE INDEX idx_payment_date ON Payment(payment_date);

-- Index on amount for amount-based filtering and sorting
CREATE INDEX idx_payment_amount ON Payment(amount);

-- =====================================================
-- 4. CREATE COMPOSITE INDEXES
-- =====================================================

-- BOOKING TABLE COMPOSITE INDEXES
-- Composite index on user_id and status for user-specific status filtering
CREATE INDEX idx_booking_user_status ON Booking(user_id, status);

-- Composite index on property_id and dates for property availability queries
CREATE INDEX idx_booking_property_dates ON Booking(property_id, start_date, end_date);

-- Composite index on start_date and end_date for date range queries
CREATE INDEX idx_booking_dates ON Booking(start_date, end_date);

-- Composite index on status and created_at for status-based chronological queries
CREATE INDEX idx_booking_status_created ON Booking(status, created_at);

-- PROPERTY TABLE COMPOSITE INDEXES
-- Composite index on location and price for location-based price filtering
CREATE INDEX idx_property_location_price ON Property(location, pricepernight);

-- REVIEW TABLE COMPOSITE INDEXES
-- Composite index on property_id and rating for property rating queries
CREATE INDEX idx_review_property_rating ON Review(property_id, rating);

-- Composite index on property_id and created_at for recent reviews per property
CREATE INDEX idx_review_property_created ON Review(property_id, created_at);

-- =====================================================
-- 5. SPECIALIZED INDEXES
-- =====================================================

-- Full-text index on property name and description (if using MyISAM or InnoDB with MySQL 5.6+)
-- ALTER TABLE Property ADD FULLTEXT(name, description);

-- Partial index on active bookings only (MySQL 8.0+ with functional indexes)
-- CREATE INDEX idx_booking_active ON Booking((CASE WHEN status IN ('confirmed', 'pending') THEN 1 ELSE NULL END));

-- =====================================================
-- 6. PERFORMANCE TESTING WITH EXPLAIN AND EXPLAIN ANALYZE
-- =====================================================

-- =====================================================
-- 6.1 BASIC EXPLAIN QUERIES (Query Plan Analysis)
-- =====================================================

-- Query 1: User lookup by email (tests idx_user_email)
EXPLAIN SELECT * FROM User WHERE email = 'user@example.com';

-- Query 2: Bookings by user with status filter (tests idx_booking_user_status)
EXPLAIN SELECT * FROM Booking WHERE user_id = 123 AND status = 'confirmed';

-- Query 3: Property search by location and price range (tests idx_property_location_price)
EXPLAIN SELECT * FROM Property WHERE location = 'New York' AND pricepernight BETWEEN 100 AND 300;

-- Query 4: Bookings in date range (tests idx_booking_dates)
EXPLAIN SELECT * FROM Booking WHERE start_date >= '2024-01-01' AND end_date <= '2024-12-31';

-- Query 5: Property availability check (tests idx_booking_property_dates)
EXPLAIN SELECT COUNT(*) FROM Booking 
WHERE property_id = 456 
AND start_date <= '2024-06-15' 
AND end_date >= '2024-06-10';

-- Query 6: Recent reviews for property (tests idx_review_property_created)
EXPLAIN SELECT * FROM Review 
WHERE property_id = 789 
ORDER BY created_at DESC 
LIMIT 10;

-- Query 7: High-rated properties (tests idx_review_property_rating)
EXPLAIN SELECT p.property_id, p.name, AVG(r.rating) as avg_rating
FROM Property p
JOIN Review r ON p.property_id = r.property_id
WHERE r.rating >= 4.0
GROUP BY p.property_id, p.name
HAVING AVG(r.rating) > 4.5;

-- Query 8: Complex JOIN query (tests multiple indexes)
EXPLAIN SELECT 
    u.first_name, u.last_name,
    p.name as property_name,
    b.start_date, b.end_date,
    b.total_price
FROM User u
JOIN Booking b ON u.user_id = b.user_id
JOIN Property p ON b.property_id = p.property_id
WHERE u.role = 'guest'
AND b.status = 'completed'
AND b.start_date >= '2024-01-01'
ORDER BY b.created_at DESC;

-- =====================================================
-- 6.2 EXPLAIN ANALYZE QUERIES (Actual Execution Analysis)
-- =====================================================

-- Query 1: User lookup by email with actual execution stats
EXPLAIN ANALYZE SELECT * FROM User WHERE email = 'user@example.com';

-- Query 2: Bookings by user with status filter - actual performance
EXPLAIN ANALYZE SELECT * FROM Booking WHERE user_id = 123 AND status = 'confirmed';

-- Query 3: Property search by location and price range - execution analysis
EXPLAIN ANALYZE SELECT * FROM Property WHERE location = 'New York' AND pricepernight BETWEEN 100 AND 300;

-- Query 4: Bookings in date range - actual timing
EXPLAIN ANALYZE SELECT * FROM Booking WHERE start_date >= '2024-01-01' AND end_date <= '2024-12-31';

-- Query 5: Property availability check - real execution stats
EXPLAIN ANALYZE SELECT COUNT(*) FROM Booking 
WHERE property_id = 456 
AND start_date <= '2024-06-15' 
AND end_date >= '2024-06-10';

-- Query 6: Recent reviews for property - actual performance
EXPLAIN ANALYZE SELECT * FROM Review 
WHERE property_id = 789 
ORDER BY created_at DESC 
LIMIT 10;

-- Query 7: High-rated properties aggregation - execution analysis
EXPLAIN ANALYZE SELECT p.property_id, p.name, AVG(r.rating) as avg_rating
FROM Property p
JOIN Review r ON p.property_id = r.property_id
WHERE r.rating >= 4.0
GROUP BY p.property_id, p.name
HAVING AVG(r.rating) > 4.5;

-- Query 8: Complex JOIN query - comprehensive execution analysis
EXPLAIN ANALYZE SELECT 
    u.first_name, u.last_name,
    p.name as property_name,
    b.start_date, b.end_date,
    b.total_price
FROM User u
JOIN Booking b ON u.user_id = b.user_id
JOIN Property p ON b.property_id = p.property_id
WHERE u.role = 'guest'
AND b.status = 'completed'
AND b.start_date >= '2024-01-01'
ORDER BY b.created_at DESC;

-- =====================================================
-- 6.3 PERFORMANCE COMPARISON QUERIES
-- =====================================================

-- Query to measure performance improvement for booking searches
EXPLAIN ANALYZE SELECT 
    b.booking_id,
    b.total_price,
    u.email,
    p.name as property_name
FROM Booking b
JOIN User u ON b.user_id = u.user_id
JOIN Property p ON b.property_id = p.property_id
WHERE b.status IN ('confirmed', 'completed')
AND b.start_date BETWEEN '2024-01-01' AND '2024-12-31'
AND p.location LIKE '%New York%'
ORDER BY b.total_price DESC
LIMIT 50;

-- Query to test composite index effectiveness
EXPLAIN ANALYZE SELECT 
    property_id,
    COUNT(*) as booking_count,
    AVG(total_price) as avg_price
FROM Booking 
WHERE status = 'completed'
AND start_date >= '2024-01-01'
GROUP BY property_id
HAVING booking_count > 5
ORDER BY avg_price DESC;

-- Query to test review aggregation performance
EXPLAIN ANALYZE SELECT 
    p.property_id,
    p.name,
    p.location,
    COUNT(r.review_id) as review_count,
    AVG(r.rating) as avg_rating,
    MAX(r.created_at) as latest_review
FROM Property p
LEFT JOIN Review r ON p.property_id = r.property_id
WHERE p.pricepernight BETWEEN 50 AND 200
GROUP BY p.property_id, p.name, p.location
HAVING review_count >= 3
ORDER BY avg_rating DESC, review_count DESC
LIMIT 20;

-- =====================================================
-- 7. INDEX MAINTENANCE COMMANDS
-- =====================================================

-- Check index usage statistics (MySQL 5.6+)
-- SELECT 
--     OBJECT_SCHEMA,
--     OBJECT_NAME,
--     INDEX_NAME,
--     COUNT_FETCH,
--     COUNT_INSERT,
--     COUNT_UPDATE,
--     COUNT_DELETE
-- FROM performance_schema.table_io_waits_summary_by_index_usage
-- WHERE OBJECT_SCHEMA = 'airbnb_db'
-- ORDER BY COUNT_FETCH DESC;

-- Show indexes for each table
SHOW INDEX FROM User;
SHOW INDEX FROM Booking;
SHOW INDEX FROM Property;
SHOW INDEX FROM Review;
SHOW INDEX FROM Payment;

-- Analyze tables to update index statistics
ANALYZE TABLE User;
ANALYZE TABLE Booking;
ANALYZE TABLE Property;
ANALYZE TABLE Review;
ANALYZE TABLE Payment;

-- =====================================================
-- 8. BEFORE/AFTER PERFORMANCE COMPARISON
-- =====================================================

/*
COMPREHENSIVE PERFORMANCE TESTING PROCEDURE:

PHASE 1: BASELINE MEASUREMENT (Before Index Creation)
1. Drop all non-primary indexes
2. Run EXPLAIN ANALYZE on all test queries
3. Record execution times, rows examined, and query costs
4. Save results for comparison

PHASE 2: INDEX IMPLEMENTATION
1. Create all indexes as defined in sections 3-4
2. Run ANALYZE TABLE on all tables
3. Allow MySQL to update statistics

PHASE 3: POST-INDEX MEASUREMENT
1. Run identical EXPLAIN ANALYZE queries
2. Record new execution times and statistics
3. Compare with baseline results

KEY METRICS TO COMPARE:
- Execution Time: Actual time taken (from EXPLAIN ANALYZE)
- Rows Examined: Should decrease significantly
- Index Usage: Type should change from "ALL" to "ref"/"range"
- Cost: Query optimizer cost should decrease
- Join Algorithm: Should use index-based joins

EXPLAIN vs EXPLAIN ANALYZE DIFFERENCES:
- EXPLAIN: Shows the query execution plan (predicted)
- EXPLAIN ANALYZE: Shows actual execution statistics (real performance)
- EXPLAIN ANALYZE provides:
  * Actual execution time
  * Actual rows processed
  * Number of loops executed
  * Time spent in each operation
  * Memory usage (in some versions)

Example EXPLAIN ANALYZE output interpretation:
-> Index lookup on User using idx_user_email (email='user@example.com') 
   (cost=0.35 rows=1) (actual time=0.123..0.125 rows=1 loops=1)

This shows:
- Used index: idx_user_email
- Estimated cost: 0.35, rows: 1
- Actual time: 0.123-0.125ms
- Actual rows: 1
- Executed once (loops=1)
*/

-- =====================================================
-- 9. INDEX MONITORING QUERIES
-- =====================================================

-- Monitor index effectiveness
SELECT 
    TABLE_SCHEMA,
    TABLE_NAME,
    INDEX_NAME,
    CARDINALITY,
    SUB_PART,
    PACKED,
    NULLABLE,
    INDEX_TYPE
FROM INFORMATION_SCHEMA.STATISTICS 
WHERE TABLE_SCHEMA = 'airbnb_db'
ORDER BY TABLE_NAME, INDEX_NAME;

-- Check for unused indexes (requires performance schema)
-- SELECT 
--     OBJECT_SCHEMA,
--     OBJECT_NAME,
--     INDEX_NAME
-- FROM performance_schema.table_io_waits_summary_by_index_usage
-- WHERE OBJECT_SCHEMA = 'airbnb_db'
-- AND INDEX_NAME IS NOT NULL
-- AND COUNT_FETCH = 0
-- AND COUNT_INSERT = 0
-- AND COUNT_UPDATE = 0
-- AND COUNT_DELETE = 0;

-- Real-time query performance monitoring
-- SELECT 
--     SQL_TEXT,
--     EXEC_COUNT,
--     TOTAL_LATENCY,
--     AVG_LATENCY,
--     ROWS_EXAMINED_AVG,
--     ROWS_SENT_AVG
-- FROM sys.x$statement_analysis
-- WHERE DB = 'airbnb_db'
-- ORDER BY TOTAL_LATENCY DESC
-- LIMIT 10;

-- =====================================================
-- 10. INDEX PERFORMANCE BENCHMARKING
-- =====================================================

-- Benchmark script for systematic performance testing
/*
BENCHMARKING PROCEDURE:

1. Create a test script that runs each query multiple times
2. Measure average execution time over multiple runs
3. Record results in a benchmarking table:

CREATE TABLE index_benchmark (
    test_id INT AUTO_INCREMENT PRIMARY KEY,
    query_name VARCHAR(100),
    index_status ENUM('before', 'after'),
    execution_time_ms DECIMAL(10,3),
    rows_examined INT,
    test_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

4. Use this template for each test query:
INSERT INTO index_benchmark (query_name, index_status, execution_time_ms, rows_examined)
VALUES ('user_email_lookup', 'before', <time>, <rows>);

5. Generate performance reports:
SELECT 
    query_name,
    AVG(CASE WHEN index_status = 'before' THEN execution_time_ms END) as before_avg_ms,
    AVG(CASE WHEN index_status = 'after' THEN execution_time_ms END) as after_avg_ms,
    (AVG(CASE WHEN index_status = 'before' THEN execution_time_ms END) - 
     AVG(CASE WHEN index_status = 'after' THEN execution_time_ms END)) as improvement_ms,
    ROUND(((AVG(CASE WHEN index_status = 'before' THEN execution_time_ms END) - 
            AVG(CASE WHEN index_status = 'after' THEN execution_time_ms END)) / 
           AVG(CASE WHEN index_status = 'before' THEN execution_time_ms END)) * 100, 2) as improvement_percent
FROM index_benchmark
GROUP BY query_name
ORDER BY improvement_percent DESC;
*/

-- =====================================================
-- END OF ENHANCED INDEX IMPLEMENTATION
-- =====================================================