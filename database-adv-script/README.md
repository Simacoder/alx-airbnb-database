# Write Complex Queries with Joins

## Task 0:

**mandatory**:

Objective: Master SQL joins by writing complex queries using different types of joins.

**Instructions**:

Write a query using an INNER JOIN to retrieve all bookings and the respective users who made those bookings.

Write a query using aLEFT JOIN to retrieve all properties and their reviews, including properties that have no reviews.

Write a query using a FULL OUTER JOIN to retrieve all users and all bookings, even if the user has no booking or a booking is not linked to a user.

# Task 1:

**Query 1: Non-Correlated Subquery - Properties with Average Rating > 4.0**
## Key Features:

**Non-correlated**: The inner query can run independently of the outer query
**Multiple approaches**: Using IN, EXISTS, and JOIN with subquery
**Additional insights**: Includes actual ratings, review counts, and rating categories

## How it works:

The subquery calculates average ratings grouped by property
HAVING clause filters for ratings > 4.0
Main query retrieves property details for matching properties

**Query 2: Correlated Subquery - Users with More Than 3 Bookings**
## Key Features:

**Correlated**: Inner query references the outer query (u.user_id)
**Multiple calculations**: Total bookings, spending, dates
**Detailed analysis**: Booking status breakdown, average values

## How it works:

For each user in the outer query, the inner query counts their bookings
WHERE clause filters users with > 3 bookings
Additional correlated subqueries provide comprehensive user statistics

**Bonus Queries**: Complex Nested Subqueries
I've included advanced examples that demonstrate:

**Nested subqueries**: Multiple levels of subqueries
**Comparative analysis**: Properties vs. location averages
**Complex aggregations**: User spending vs. platform averages

# AUTHOR
- Simanga Mchunu