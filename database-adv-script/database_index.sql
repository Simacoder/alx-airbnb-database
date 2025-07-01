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
-- 6. PERFORMANCE TESTING QUERIES
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
PERFORMANCE TESTING SCRIPT:

1. Run the performance testing queries above with EXPLAIN before creating indexes
2. Note the execution plans, rows examined, and query cost
3. Create the indexes using the commands above
4. Run the same queries again with EXPLAIN
5. Compare the results to measure performance improvement

Key metrics to compare:
- Type: Should change from "ALL" (full table scan) to "ref" or "range"
- Rows: Number of rows examined should decrease significantly
- Key: Should show the index being used
- Extra: Should show "Using index" when possible

Example comparison:
Before: type=ALL, rows=10000, key=NULL
After:  type=ref, rows=1, key=idx_user_email
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

-- =====================================================
-- END OF INDEX IMPLEMENTATION
-- =====================================================