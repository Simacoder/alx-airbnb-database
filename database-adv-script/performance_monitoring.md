# Database Performance Monitoring and Optimization Guide

## Table of Contents
1. [Performance Monitoring Tools](#performance-monitoring-tools)
2. [Query Analysis Examples](#query-analysis-examples)
3. [Common Bottlenecks](#common-bottlenecks)
4. [Optimization Strategies](#optimization-strategies)
5. [Implementation Examples](#implementation-examples)
6. [Performance Measurement](#performance-measurement)

## Performance Monitoring Tools

### 1. EXPLAIN ANALYZE (PostgreSQL)
```sql
-- Basic query analysis
EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'user@example.com';

-- Detailed analysis with buffers and timing
EXPLAIN (ANALYZE, BUFFERS, TIMING) 
SELECT u.name, COUNT(o.id) as order_count
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
WHERE u.created_at > '2024-01-01'
GROUP BY u.id, u.name
ORDER BY order_count DESC;
```

### 2. SHOW PROFILE (MySQL)
```sql
-- Enable profiling
SET profiling = 1;

-- Execute your query
SELECT u.name, COUNT(o.id) as order_count
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
WHERE u.created_at > '2024-01-01'
GROUP BY u.id, u.name
ORDER BY order_count DESC;

-- Show profile results
SHOW PROFILES;
SHOW PROFILE FOR QUERY 1;

-- Detailed CPU and block I/O analysis
SHOW PROFILE CPU, BLOCK IO FOR QUERY 1;
```

### 3. Execution Plans (SQL Server)
```sql
-- Enable actual execution plan
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

-- Your query here
SELECT u.name, COUNT(o.id) as order_count
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
WHERE u.created_at > '2024-01-01'
GROUP BY u.id, u.name
ORDER BY order_count DESC;

-- View execution plan
-- Use SQL Server Management Studio's "Include Actual Execution Plan"
```

## Query Analysis Examples

### Example 1: Slow User Search Query

**Original Query:**
```sql
SELECT * FROM users 
WHERE email LIKE '%@gmail.com' 
AND created_at BETWEEN '2024-01-01' AND '2024-12-31';
```

**Analysis Results:**
```
EXPLAIN ANALYZE Output:
Seq Scan on users (cost=0.00..25000.00 rows=1000 width=64) 
                  (actual time=0.234..1245.678 rows=15432 loops=1)
Filter: ((email ~~ '%@gmail.com'::text) AND 
         (created_at >= '2024-01-01'::date) AND 
         (created_at <= '2024-12-31'::date))
Rows Removed by Filter: 984568
Planning Time: 0.123 ms
Execution Time: 1247.891 ms
```

**Issues Identified:**
- Sequential scan on entire table (984,568 rows scanned)
- LIKE with leading wildcard prevents index usage
- No index on created_at column

### Example 2: Complex Join Query

**Original Query:**
```sql
SELECT p.name, c.name as category, COUNT(oi.id) as sales_count
FROM products p
JOIN categories c ON p.category_id = c.id
JOIN order_items oi ON p.id = oi.product_id
JOIN orders o ON oi.order_id = o.id
WHERE o.created_at > '2024-06-01'
GROUP BY p.id, p.name, c.name
ORDER BY sales_count DESC
LIMIT 20;
```

**Analysis Results:**
```
EXPLAIN ANALYZE Output:
Limit (cost=89234.56..89234.61 rows=20 width=68) 
      (actual time=2341.234..2341.267 rows=20 loops=1)
->  Sort (cost=89234.56..89456.78 rows=88888 width=68) 
          (actual time=2341.233..2341.245 rows=20 loops=1)
    Sort Key: (count(oi.id)) DESC
    Sort Method: top-N heapsort Memory: 26kB
    ->  HashAggregate (cost=85678.90..87123.45 rows=88888 width=68) 
                      (actual time=2298.123..2334.567 rows=12456 loops=1)
```

## Common Bottlenecks

### 1. Missing Indexes
```sql
-- Check for missing indexes on frequently queried columns
SELECT schemaname, tablename, attname, correlation, n_distinct
FROM pg_stats 
WHERE schemaname = 'public' 
AND n_distinct > 100;

-- Query to find slow queries without indexes
SELECT query, calls, total_time, mean_time
FROM pg_stat_statements 
WHERE query NOT LIKE '%INDEX%'
ORDER BY total_time DESC 
LIMIT 10;
```

### 2. Inefficient JOINs
- Cartesian products due to missing JOIN conditions
- Large table joins without proper indexing
- Wrong join order in complex queries

### 3. Suboptimal WHERE Clauses
- Functions in WHERE clauses preventing index usage
- Leading wildcards in LIKE operations
- OR conditions that can't use indexes effectively

### 4. Unnecessary Data Retrieval
- SELECT * instead of specific columns
- Missing LIMIT clauses on large result sets
- Fetching data that's filtered on application side

## Optimization Strategies

### 1. Index Optimization

**Create Strategic Indexes:**
```sql
-- Composite index for multi-column searches
CREATE INDEX idx_users_email_created ON users(email, created_at);

-- Partial index for specific conditions
CREATE INDEX idx_orders_active_created 
ON orders(created_at) 
WHERE status = 'active';

-- Functional index for case-insensitive searches
CREATE INDEX idx_users_email_lower 
ON users(LOWER(email));
```

**Remove Unused Indexes:**
```sql
-- Find unused indexes (PostgreSQL)
SELECT schemaname, tablename, indexname, idx_scan
FROM pg_stat_user_indexes 
WHERE idx_scan = 0 
AND schemaname = 'public';
```

### 2. Query Rewriting

**Before:**
```sql
SELECT * FROM users 
WHERE email LIKE '%@gmail.com';
```

**After:**
```sql
-- Use suffix search with reverse index or full-text search
SELECT id, name, email FROM users 
WHERE email LIKE 'user@gmail.com'  -- Exact match when possible
OR email ~ '@gmail\.com$';         -- Regex for suffix match
```

### 3. Schema Adjustments

**Normalization vs Denormalization:**
```sql
-- Add calculated columns for frequent aggregations
ALTER TABLE users ADD COLUMN order_count INTEGER DEFAULT 0;

-- Create materialized view for complex reports
CREATE MATERIALIZED VIEW user_order_summary AS
SELECT u.id, u.name, COUNT(o.id) as order_count, 
       SUM(o.total) as total_spent
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.name;

-- Refresh strategy
CREATE INDEX ON user_order_summary(order_count DESC);
```

## Implementation Examples

### Example 1: Optimizing User Search

**Step 1: Add Indexes**
```sql
-- Create composite index
CREATE INDEX idx_users_created_email ON users(created_at, email);

-- Create functional index for domain searches
CREATE INDEX idx_users_email_domain 
ON users(SUBSTRING(email FROM '@(.*)$'));
```

**Step 2: Rewrite Query**
```sql
-- Optimized query
SELECT id, name, email, created_at 
FROM users 
WHERE created_at BETWEEN '2024-01-01' AND '2024-12-31'
AND SUBSTRING(email FROM '@(.*)$') = 'gmail.com';
```

**Step 3: Results**
```
Before: 1247.891 ms, 984,568 rows scanned
After:  23.456 ms, 15,432 rows scanned
Improvement: 98.1% faster
```

### Example 2: Optimizing Complex Joins

**Step 1: Add Missing Indexes**
```sql
CREATE INDEX idx_orders_created_at ON orders(created_at);
CREATE INDEX idx_order_items_product_order ON order_items(product_id, order_id);
CREATE INDEX idx_products_category ON products(category_id);
```

**Step 2: Rewrite with CTE**
```sql
WITH recent_orders AS (
  SELECT id FROM orders 
  WHERE created_at > '2024-06-01'
),
product_sales AS (
  SELECT oi.product_id, COUNT(*) as sales_count
  FROM order_items oi
  JOIN recent_orders ro ON oi.order_id = ro.id
  GROUP BY oi.product_id
)
SELECT p.name, c.name as category, ps.sales_count
FROM product_sales ps
JOIN products p ON ps.product_id = p.id
JOIN categories c ON p.category_id = c.id
ORDER BY ps.sales_count DESC
LIMIT 20;
```

**Step 3: Results**
```
Before: 2341.234 ms
After:  342.567 ms
Improvement: 85.4% faster
```

## Performance Measurement

### Before and After Comparison

**Metrics to Track:**
```sql
-- Query execution time
\timing on  -- PostgreSQL
SET @start_time = NOW(6); -- MySQL

-- I/O statistics
SHOW STATUS LIKE 'Handler_read%';  -- MySQL
SELECT * FROM pg_stat_user_tables; -- PostgreSQL

-- Index usage
SHOW STATUS LIKE 'Key_read%';      -- MySQL
SELECT * FROM pg_stat_user_indexes; -- PostgreSQL
```

### Monitoring Dashboard Queries

**Top Slow Queries:**
```sql
-- PostgreSQL
SELECT query, calls, total_time, mean_time, stddev_time
FROM pg_stat_statements 
ORDER BY total_time DESC 
LIMIT 10;

-- MySQL
SELECT DIGEST_TEXT, COUNT_STAR, AVG_TIMER_WAIT/1000000000 as avg_ms
FROM performance_schema.events_statements_summary_by_digest 
ORDER BY AVG_TIMER_WAIT DESC 
LIMIT 10;
```

**Index Efficiency:**
```sql
-- Check index hit ratio (should be > 95%)
SELECT 
  sum(idx_blks_hit) / (sum(idx_blks_hit) + sum(idx_blks_read)) * 100 
  AS index_hit_ratio
FROM pg_statio_user_indexes;
```

### Automated Monitoring Script

```sql
-- Create performance log table
CREATE TABLE performance_log (
  id SERIAL PRIMARY KEY,
  query_hash VARCHAR(64),
  execution_time_ms DECIMAL(10,3),
  rows_examined INTEGER,
  rows_returned INTEGER,
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Trigger for automatic logging (adapt to your database system)
-- This would be implemented as application-level logging
```

## Best Practices

1. **Regular Monitoring:** Set up automated monitoring for slow queries
2. **Index Maintenance:** Regularly review and optimize indexes
3. **Query Review:** Implement code review process for database queries
4. **Testing:** Always test optimizations in a staging environment
5. **Documentation:** Keep track of all performance changes and their impact

## Tools and Resources

- **PostgreSQL:** pg_stat_statements, EXPLAIN, pgAdmin
- **MySQL:** Performance Schema, MySQL Workbench, Percona Toolkit
- **SQL Server:** Query Store, SQL Server Profiler, DMVs
- **Cross-platform:** SolarWinds DPA, Datadog, New Relic

Remember to always backup your database before implementing schema changes and test optimizations in a non-production environment first.