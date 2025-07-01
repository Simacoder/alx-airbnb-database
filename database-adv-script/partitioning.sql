-- =====================================================
-- ALX Airbnb Database Module: Table Partitioning Implementation
-- File: partitioning.sql
-- Purpose: Implement table partitioning for large Booking table
-- =====================================================
-- AUTHOR: Simanga Mchunu

-- =====================================================
-- 1. ANALYSIS OF CURRENT BOOKING TABLE
-- =====================================================

-- Check current table structure and size
SELECT 
    COUNT(*) as total_bookings,
    MIN(start_date) as earliest_booking,
    MAX(start_date) as latest_booking,
    YEAR(MIN(start_date)) as earliest_year,
    YEAR(MAX(start_date)) as latest_year
FROM Booking;

-- Analyze data distribution by year
SELECT 
    YEAR(start_date) as booking_year,
    COUNT(*) as bookings_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Booking), 2) as percentage
FROM Booking
GROUP BY YEAR(start_date)
ORDER BY booking_year;

-- Analyze data distribution by month (for recent year)
SELECT 
    YEAR(start_date) as booking_year,
    MONTH(start_date) as booking_month,
    COUNT(*) as bookings_count
FROM Booking
WHERE start_date >= DATE_SUB(CURRENT_DATE, INTERVAL 2 YEAR)
GROUP BY YEAR(start_date), MONTH(start_date)
ORDER BY booking_year DESC, booking_month DESC;

-- Check current table size and performance
SHOW TABLE STATUS LIKE 'Booking';

-- =====================================================
-- 2. BACKUP ORIGINAL TABLE STRUCTURE
-- =====================================================

-- Create backup of original table structure
CREATE TABLE Booking_backup_structure LIKE Booking;

-- Document original indexes
SHOW INDEX FROM Booking;

-- =====================================================
-- 3. CREATE PARTITIONED BOOKING TABLE
-- =====================================================

-- Drop existing table (in production, use rename and careful migration)
-- DROP TABLE IF EXISTS Booking;

-- Create new partitioned Booking table
CREATE TABLE Booking_partitioned (
    booking_id CHAR(36) NOT NULL,
    property_id CHAR(36) NOT NULL,
    user_id CHAR(36) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    status ENUM('pending', 'confirmed', 'canceled') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    PRIMARY KEY (booking_id, start_date),  -- Must include partition key
    KEY idx_user_id (user_id, start_date),
    KEY idx_property_id (property_id, start_date),
    KEY idx_status_date (status, start_date),
    KEY idx_created_at (created_at),
    
    FOREIGN KEY (property_id) REFERENCES Property(property_id),
    FOREIGN KEY (user_id) REFERENCES User(user_id)
) 
PARTITION BY RANGE (YEAR(start_date)) (
    PARTITION p2020 VALUES LESS THAN (2021),
    PARTITION p2021 VALUES LESS THAN (2022),
    PARTITION p2022 VALUES LESS THAN (2023),
    PARTITION p2023 VALUES LESS THAN (2024),
    PARTITION p2024 VALUES LESS THAN (2025),
    PARTITION p2025 VALUES LESS THAN (2026),
    PARTITION p2026 VALUES LESS THAN (2027),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- =====================================================
-- 4. ALTERNATIVE PARTITIONING STRATEGIES
-- =====================================================

-- Strategy 1: Monthly partitioning for more granular control
-- (Use this for tables with very high volume)
CREATE TABLE Booking_monthly_partitioned (
    booking_id CHAR(36) NOT NULL,
    property_id CHAR(36) NOT NULL,
    user_id CHAR(36) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    status ENUM('pending', 'confirmed', 'canceled') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    PRIMARY KEY (booking_id, start_date),
    KEY idx_user_id (user_id, start_date),
    KEY idx_property_id (property_id, start_date),
    KEY idx_status_date (status, start_date)
) 
PARTITION BY RANGE (YEAR(start_date) * 100 + MONTH(start_date)) (
    PARTITION p202401 VALUES LESS THAN (202402),
    PARTITION p202402 VALUES LESS THAN (202403),
    PARTITION p202403 VALUES LESS THAN (202404),
    PARTITION p202404 VALUES LESS THAN (202405),
    PARTITION p202405 VALUES LESS THAN (202406),
    PARTITION p202406 VALUES LESS THAN (202407),
    PARTITION p202407 VALUES LESS THAN (202408),
    PARTITION p202408 VALUES LESS THAN (202409),
    PARTITION p202409 VALUES LESS THAN (202410),
    PARTITION p202410 VALUES LESS THAN (202411),
    PARTITION p202411 VALUES LESS THAN (202412),
    PARTITION p202412 VALUES LESS THAN (202501),
    PARTITION p202501 VALUES LESS THAN (202502),
    PARTITION p202502 VALUES LESS THAN (202503),
    PARTITION p202503 VALUES LESS THAN (202504),
    PARTITION p202504 VALUES LESS THAN (202505),
    PARTITION p202505 VALUES LESS THAN (202506),
    PARTITION p202506 VALUES LESS THAN (202507),
    PARTITION p202507 VALUES LESS THAN (202508),
    PARTITION p202508 VALUES LESS THAN (202509),
    PARTITION p202509 VALUES LESS THAN (202510),
    PARTITION p202510 VALUES LESS THAN (202511),
    PARTITION p202511 VALUES LESS THAN (202512),
    PARTITION p202512 VALUES LESS THAN (202601),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- Strategy 2: Hash partitioning for even distribution
-- (Use when date-based queries are not the primary pattern)
CREATE TABLE Booking_hash_partitioned (
    booking_id CHAR(36) NOT NULL,
    property_id CHAR(36) NOT NULL,
    user_id CHAR(36) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    status ENUM('pending', 'confirmed', 'canceled') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    PRIMARY KEY (booking_id),
    KEY idx_user_date (user_id, start_date),
    KEY idx_property_date (property_id, start_date),
    KEY idx_status_date (status, start_date),
    KEY idx_start_date (start_date)
) 
PARTITION BY HASH(CONV(SUBSTRING(booking_id, 1, 8), 16, 10))
PARTITIONS 8;

-- =====================================================
-- 5. DATA MIGRATION (FOR EXISTING DATA)
-- =====================================================

-- Migrate data from original table to partitioned table
-- INSERT INTO Booking_partitioned 
-- SELECT * FROM Booking;

-- Or migrate in batches for large tables
-- INSERT INTO Booking_partitioned 
-- SELECT * FROM Booking 
-- WHERE start_date >= '2024-01-01' AND start_date < '2025-01-01';

-- Verify data migration
-- SELECT COUNT(*) FROM Booking_partitioned;
-- SELECT COUNT(*) FROM Booking;

-- =====================================================
-- 6. PARTITION MANAGEMENT PROCEDURES
-- =====================================================

-- Procedure to add future partitions
DELIMITER //
CREATE PROCEDURE AddYearlyPartition(IN partition_year INT)
BEGIN
    DECLARE partition_name VARCHAR(20);
    DECLARE partition_value INT;
    DECLARE sql_stmt TEXT;
    
    SET partition_name = CONCAT('p', partition_year);
    SET partition_value = partition_year + 1;
    
    SET sql_stmt = CONCAT(
        'ALTER TABLE Booking_partitioned ADD PARTITION (',
        'PARTITION ', partition_name, ' VALUES LESS THAN (', partition_value, '))'
    );
    
    SET @sql = sql_stmt;
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //
DELIMITER ;

-- Procedure to drop old partitions (for data archival)
DELIMITER //
CREATE PROCEDURE DropOldPartition(IN partition_name VARCHAR(20))
BEGIN
    DECLARE sql_stmt TEXT;
    
    SET sql_stmt = CONCAT('ALTER TABLE Booking_partitioned DROP PARTITION ', partition_name);
    
    SET @sql = sql_stmt;
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //
DELIMITER ;

-- =====================================================
-- 7. PERFORMANCE TEST QUERIES
-- =====================================================

-- =====================================================
-- 7.1 Test Query 1: Date Range Query (Most Common)
-- =====================================================

-- Query for specific year (should hit only one partition)
EXPLAIN PARTITIONS
SELECT 
    booking_id,
    property_id,
    user_id,
    start_date,
    end_date,
    total_price,
    status
FROM Booking_partitioned
WHERE start_date >= '2024-01-01' 
AND start_date <= '2024-12-31';

-- Performance test: Recent bookings (last 6 months)
EXPLAIN PARTITIONS
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    u.first_name,
    u.last_name,
    p.name as property_name
FROM Booking_partitioned b
JOIN User u ON b.user_id = u.user_id
JOIN Property p ON b.property_id = p.property_id
WHERE b.start_date >= DATE_SUB(CURRENT_DATE, INTERVAL 6 MONTH)
AND b.status = 'confirmed'
ORDER BY b.start_date DESC
LIMIT 100;

-- =====================================================
-- 7.2 Test Query 2: User-Specific Queries
-- =====================================================

-- User bookings for specific period
EXPLAIN PARTITIONS
SELECT 
    booking_id,
    start_date,
    end_date,
    total_price,
    status
FROM Booking_partitioned
WHERE user_id = 'user-uuid-example'
AND start_date >= '2024-01-01'
AND start_date <= '2024-12-31'
ORDER BY start_date DESC;

-- =====================================================
-- 7.3 Test Query 3: Property Availability
-- =====================================================

-- Check property availability for specific date range
EXPLAIN PARTITIONS
SELECT 
    COUNT(*) as conflicting_bookings
FROM Booking_partitioned
WHERE property_id = 'property-uuid-example'
AND status IN ('confirmed', 'pending')
AND (
    (start_date <= '2025-08-15' AND end_date >= '2025-08-01') OR
    (start_date <= '2025-08-31' AND end_date >= '2025-08-15')
);

-- =====================================================
-- 7.4 Test Query 4: Aggregation Queries
-- =====================================================

-- Monthly revenue analysis
EXPLAIN PARTITIONS
SELECT 
    YEAR(start_date) as booking_year,
    MONTH(start_date) as booking_month,
    COUNT(*) as total_bookings,
    SUM(total_price) as total_revenue,
    AVG(total_price) as avg_booking_value
FROM Booking_partitioned
WHERE start_date >= '2024-01-01'
AND status = 'confirmed'
GROUP BY YEAR(start_date), MONTH(start_date)
ORDER BY booking_year DESC, booking_month DESC;

-- =====================================================
-- 8. PARTITION PRUNING VERIFICATION
-- =====================================================

-- Verify partition pruning is working
EXPLAIN PARTITIONS
SELECT COUNT(*)
FROM Booking_partitioned
WHERE start_date = '2024-06-15';

-- Should show only p2024 partition accessed

-- Query that spans multiple partitions
EXPLAIN PARTITIONS
SELECT COUNT(*)
FROM Booking_partitioned
WHERE start_date >= '2023-12-01' AND start_date <= '2024-02-01';

-- Should show p2023 and p2024 partitions accessed

-- =====================================================
-- 9. PERFORMANCE COMPARISON QUERIES
-- =====================================================

-- =====================================================
-- 9.1 Before Partitioning (Original Table)
-- =====================================================

-- Large date range query on original table
-- EXPLAIN ANALYZE
-- SELECT COUNT(*) 
-- FROM Booking 
-- WHERE start_date >= '2024-01-01' AND start_date <= '2024-12-31';

-- =====================================================
-- 9.2 After Partitioning
-- =====================================================

-- Same query on partitioned table
EXPLAIN ANALYZE
SELECT COUNT(*) 
FROM Booking_partitioned 
WHERE start_date >= '2024-01-01' AND start_date <= '2024-12-31';

-- =====================================================
-- 10. MONITORING AND MAINTENANCE
-- =====================================================

-- Check partition information
SELECT 
    PARTITION_NAME,
    PARTITION_EXPRESSION,
    PARTITION_DESCRIPTION,
    TABLE_ROWS,
    AVG_ROW_LENGTH,
    DATA_LENGTH,
    INDEX_LENGTH
FROM INFORMATION_SCHEMA.PARTITIONS
WHERE TABLE_SCHEMA = 'airbnb' AND TABLE_NAME = 'Booking_partitioned'
ORDER BY PARTITION_ORDINAL_POSITION;

-- Check partition pruning effectiveness
SELECT 
    PARTITION_NAME,
    TABLE_ROWS,
    ROUND(DATA_LENGTH / 1024 / 1024, 2) as DATA_SIZE_MB,
    ROUND(INDEX_LENGTH / 1024 / 1024, 2) as INDEX_SIZE_MB
FROM INFORMATION_SCHEMA.PARTITIONS
WHERE TABLE_SCHEMA = 'airbnb' AND TABLE_NAME = 'Booking_partitioned'
AND PARTITION_NAME IS NOT NULL;

-- =====================================================
-- 11. AUTOMATED PARTITION MANAGEMENT
-- =====================================================

-- Event to automatically add new partitions
DELIMITER //
CREATE EVENT auto_add_partition
ON SCHEDULE EVERY 1 MONTH
STARTS '2025-01-01 00:00:00'
DO
BEGIN
    DECLARE next_year INT;
    DECLARE partition_exists INT DEFAULT 0;
    
    SET next_year = YEAR(CURRENT_DATE) + 2;
    
    -- Check if partition already exists
    SELECT COUNT(*) INTO partition_exists
    FROM INFORMATION_SCHEMA.PARTITIONS
    WHERE TABLE_SCHEMA = 'airbnb' 
    AND TABLE_NAME = 'Booking_partitioned'
    AND PARTITION_NAME = CONCAT('p', next_year);
    
    -- Add partition if it doesn't exist
    IF partition_exists = 0 THEN
        CALL AddYearlyPartition(next_year);
    END IF;
END //
DELIMITER ;

-- Enable event scheduler
-- SET GLOBAL event_scheduler = ON;

-- =====================================================
-- 12. PARTITION MAINTENANCE QUERIES
-- =====================================================

-- Analyze table to update statistics
ANALYZE TABLE Booking_partitioned;

-- Optimize specific partition
-- ALTER TABLE Booking_partitioned OPTIMIZE PARTITION p2024;

-- Check for partition that can be archived/dropped
SELECT 
    PARTITION_NAME,
    TABLE_ROWS,
    CREATE_TIME,
    UPDATE_TIME
FROM INFORMATION_SCHEMA.PARTITIONS
WHERE TABLE_SCHEMA = 'airbnb' 
AND TABLE_NAME = 'Booking_partitioned'
AND PARTITION_NAME IS NOT NULL
AND TABLE_ROWS > 0
ORDER BY PARTITION_ORDINAL_POSITION;

-- =====================================================
-- 13. BEST PRACTICES IMPLEMENTATION
-- =====================================================

/*
PARTITIONING BEST PRACTICES IMPLEMENTED:

1. ✓ Partition key included in PRIMARY KEY
2. ✓ Indexes include partition key where beneficial
3. ✓ Reasonable partition size (yearly partitions)
4. ✓ Future partition planning (p_future)
5. ✓ Automated partition management procedures
6. ✓ Partition pruning verification
7. ✓ Performance monitoring queries
8. ✓ Data migration strategy
9. ✓ Maintenance procedures

PARTITIONING CONSIDERATIONS:

1. ADVANTAGES:
   - Improved query performance for date-based queries
   - Faster maintenance operations (ALTER, DELETE)
   - Parallel processing capabilities
   - Easier data archival and purging
   - Reduced index size per partition

2. DISADVANTAGES:
   - Increased complexity in table management
   - Partition key must be part of PRIMARY KEY
   - Cross-partition queries may be slower
   - Additional overhead for partition management

3. WHEN TO USE PARTITIONING:
   - Tables with > 1GB data size
   - Clear partitioning strategy (date-based queries)
   - Regular data archival requirements
   - Performance issues with large table scans
   - Parallel processing requirements

4. MAINTENANCE REQUIREMENTS:
   - Regular partition pruning/archival
   - Monitoring partition sizes
   - Updating table statistics
   - Managing partition growth
*/

-- =====================================================
-- END OF PARTITIONING IMPLEMENTATION
-- =====================================================