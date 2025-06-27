-- ===============================================
-- AirBnB Database Sample Data
-- File: seed_data.sql
-- Author: Simanga Mchunu
-- Created: 2025-06-27
-- Description: Comprehensive sample data for AirBnB database
-- ===============================================

-- Clear existing data (in proper order to respect foreign keys)
DELETE FROM Message;
DELETE FROM Review;
DELETE FROM Payment;
DELETE FROM Booking;
DELETE FROM Property;
DELETE FROM "User";

-- Reset sequences if using serial IDs (PostgreSQL specific)
-- This ensures consistent UUIDs for demonstration purposes

-- ===============================================
-- SAMPLE USERS DATA
-- ===============================================

INSERT INTO "User" (user_id, first_name, last_name, email, password_hash, phone_number, role, created_at) VALUES
-- Guests
('550e8400-e29b-41d4-a716-446655440001', 'Mpilo', 'Mchunu', 'mpilo@email.com', '$2b$10$rOiMz8Qv1YxKzV8wJH9aXOp7fKz3nJ2mL1qR9tS5uV6wX7yZ8aB9c', '+1-555-0101', 'guest', '2024-01-15 08:30:00'),
('550e8400-e29b-41d4-a716-446655440002', 'Palesa', 'Mlimi', 'palesa.mlimi@email.com', '$2b$10$sOiMz8Qv1YxKzV8wJH9aXOp7fKz3nJ2mL1qR9tS5uV6wX7yZ8aB9d', '+1-555-0102', 'guest', '2024-01-20 14:22:00'),
('550e8400-e29b-41d4-a716-446655440003', 'Michael', 'Chen', 'michael.chen@email.com', '$2b$10$tOiMz8Qv1YxKzV8wJH9aXOp7fKz3nJ2mL1qR9tS5uV6wX7yZ8aB9e', '+1-555-0103', 'guest', '2024-02-05 10:15:00'),
('550e8400-e29b-41d4-a716-446655440004', 'Emily', 'Davis', 'emily.davis@email.com', '$2b$10$uOiMz8Qv1YxKzV8wJH9aXOp7fKz3nJ2mL1qR9tS5uV6wX7yZ8aB9f', '+1-555-0104', 'guest', '2024-02-12 16:45:00'),
('550e8400-e29b-41d4-a716-446655440005', 'David', 'Wilson', 'david.wilson@email.com', '$2b$10$vOiMz8Qv1YxKzV8wJH9aXOp7fKz3nJ2mL1qR9tS5uV6wX7yZ8aB9g', '+1-555-0105', 'guest', '2024-03-01 09:30:00'),
('550e8400-e29b-41d4-a716-446655440006', 'Lisa', 'Anderson', 'lisa.anderson@email.com', '$2b$10$wOiMz8Qv1YxKzV8wJH9aXOp7fKz3nJ2mL1qR9tS5uV6wX7yZ8aB9h', '+1-555-0106', 'guest', '2024-03-15 13:20:00'),
('550e8400-e29b-41d4-a716-446655440016', 'Carlos', 'Rodriguez', 'carlos.rodriguez@email.com', '$2b$10$gOiMz8Qv1YxKzV8wJH9aXOp7fKz3nJ2mL1qR9tS5uV6wX7yZ8aB9r', '+1-555-0116', 'guest', '2024-04-10 12:15:00'),
('550e8400-e29b-41d4-a716-446655440017', 'Sophie', 'Williams', 'sophie.williams@email.com', '$2b$10$hOiMz8Qv1YxKzV8wJH9aXOp7fKz3nJ2mL1qR9tS5uV6wX7yZ8aB9s', '+1-555-0117', 'guest', '2024-04-22 15:30:00'),

-- Hosts
('550e8400-e29b-41d4-a716-446655440007', 'Robert', 'Martinez', 'robert.martinez@email.com', '$2b$10$xOiMz8Qv1YxKzV8wJH9aXOp7fKz3nJ2mL1qR9tS5uV6wX7yZ8aB9i', '+1-555-0107', 'host', '2023-12-01 11:00:00'),
('550e8400-e29b-41d4-a716-446655440008', 'Jennifer', 'Brown', 'jennifer.brown@email.com', '$2b$10$yOiMz8Qv1YxKzV8wJH9aXOp7fKz3nJ2mL1qR9tS5uV6wX7yZ8aB9j', '+1-555-0108', 'host', '2023-11-15 15:30:00'),
('550e8400-e29b-41d4-a716-446655440009', 'James', 'Taylor', 'james.taylor@email.com', '$2b$10$zOiMz8Qv1YxKzV8wJH9aXOp7fKz3nJ2mL1qR9tS5uV6wX7yZ8aB9k', '+1-555-0109', 'host', '2023-10-20 08:45:00'),
('550e8400-e29b-41d4-a716-446655440010', 'Maria', 'Garcia', 'maria.garcia@email.com', '$2b$10$aOiMz8Qv1YxKzV8wJH9aXOp7fKz3nJ2mL1qR9tS5uV6wX7yZ8aB9l', '+1-555-0110', 'host', '2023-09-10 12:15:00'),
('550e8400-e29b-41d4-a716-446655440011', 'Thomas', 'Miller', 'thomas.miller@email.com', '$2b$10$bOiMz8Qv1YxKzV8wJH9aXOp7fKz3nJ2mL1qR9tS5uV6wX7yZ8aB9m', '+1-555-0111', 'host', '2023-08-25 14:00:00'),
('550e8400-e29b-41d4-a716-446655440012', 'Amanda', 'Lee', 'amanda.lee@email.com', '$2b$10$cOiMz8Qv1YxKzV8wJH9aXOp7fKz3nJ2mL1qR9tS5uV6wX7yZ8aB9n', '+1-555-0112', 'host', '2023-07-30 10:30:00'),

-- Host-Guest hybrid users
('550e8400-e29b-41d4-a716-446655440013', 'Kevin', 'White', 'kevin.white@email.com', '$2b$10$dOiMz8Qv1YxKzV8wJH9aXOp7fKz3nJ2mL1qR9tS5uV6wX7yZ8aB9o', '+1-555-0113', 'host', '2024-01-10 16:20:00'),
('550e8400-e29b-41d4-a716-446655440014', 'Rachel', 'Moore', 'rachel.moore@email.com', '$2b$10$eOiMz8Qv1YxKzV8wJH9aXOp7fKz3nJ2mL1qR9tS5uV6wX7yZ8aB9p', '+1-555-0114', 'host', '2024-02-28 11:45:00'),

-- Admin
('550e8400-e29b-41d4-a716-446655440015', 'Admin', 'User', 'admin@airbnb.com', '$2b$10$fOiMz8Qv1YxKzV8wJH9aXOp7fKz3nJ2mL1qR9tS5uV6wX7yZ8aB9q', '+1-555-0000', 'admin', '2023-01-01 00:00:00');

-- ===============================================
-- SAMPLE PROPERTIES DATA
-- ===============================================

INSERT INTO Property (property_id, host_id, name, description, location, price_per_night, created_at, updated_at) VALUES
-- Robert Martinez properties
('660e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440007', 'Cozy Downtown Apartment', 'Beautiful 2-bedroom apartment in the heart of downtown. Walking distance to restaurants, shops, and public transportation. Modern amenities include WiFi, full kitchen, and washer/dryer. Perfect for business travelers or couples exploring the city.', 'New York, NY, USA', 150.00, '2023-12-05 10:30:00', '2024-05-15 14:20:00'),
('660e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440007', 'Luxury Penthouse Suite', 'Stunning penthouse with panoramic city views. Features 3 bedrooms, 2 bathrooms, gourmet kitchen, and private rooftop terrace. High-end furnishings and premium location make this perfect for special occasions or executive stays.', 'New York, NY, USA', 350.00, '2024-01-20 15:45:00', '2024-06-10 09:15:00'),

-- Jennifer Brown properties  
('660e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440008', 'Beachfront Villa', 'Spectacular oceanfront villa with private beach access. 4 bedrooms, 3 bathrooms, fully equipped kitchen, and outdoor deck with BBQ grill. Includes beach chairs, umbrellas, and water sports equipment. Ideal for families and groups.', 'Miami, FL, USA', 280.00, '2023-11-20 12:00:00', '2024-04-25 16:30:00'),
('660e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440008', 'Art Deco Studio', 'Stylish studio apartment in the famous Art Deco district. Recently renovated with modern amenities while preserving historic charm. Features Murphy bed, kitchenette, and balcony overlooking Ocean Drive. Perfect for solo travelers or couples.', 'Miami, FL, USA', 95.00, '2024-02-15 08:20:00', '2024-05-30 11:45:00'),

-- James Taylor properties
('660e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440009', 'Mountain Cabin Retreat', 'Rustic log cabin nestled in the mountains with breathtaking views. Features fireplace, hot tub, full kitchen, and hiking trails nearby. 2 bedrooms accommodate up to 6 guests. Perfect for nature lovers and those seeking peaceful escape from city life.', 'Aspen, CO, USA', 220.00, '2023-10-25 14:15:00', '2024-03-18 10:00:00'),
('660e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440009', 'Ski Lodge Chalet', 'Luxury ski-in/ski-out chalet with stunning mountain views. 5 bedrooms, 4 bathrooms, gourmet kitchen, and spacious living areas with stone fireplace. Includes ski storage, boot warmers, and access to exclusive resort amenities.', 'Aspen, CO, USA', 450.00, '2023-11-30 16:45:00', '2024-01-22 13:30:00'),

-- Maria Garcia properties
('660e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440010', 'Historic Victorian Home', 'Beautifully restored Victorian house in prestigious neighborhood. 3 bedrooms, 2.5 bathrooms, original hardwood floors, and period furnishings. Garden patio and off-street parking included. Rich history and elegant architecture make this a unique experience.', 'San Francisco, CA, USA', 195.00, '2023-09-15 11:30:00', '2024-02-14 15:20:00'),
('660e8400-e29b-41d4-a716-446655440008', '550e8400-e29b-41d4-a716-446655440010', 'Modern Loft Space', 'Contemporary loft in converted warehouse with industrial chic design. Open floor plan, exposed brick walls, high ceilings, and floor-to-ceiling windows. Features modern kitchen, work space, and rooftop access. Great for creative professionals.', 'San Francisco, CA, USA', 175.00, '2024-03-10 09:45:00', '2024-06-05 12:10:00'),

-- Thomas Miller properties
('660e8400-e29b-41d4-a716-446655440009', '550e8400-e29b-41d4-a716-446655440011', 'Lakeside Cottage', 'Charming cottage right on the lake with private dock and canoe. 2 bedrooms, cozy living room with stone fireplace, and screened porch overlooking the water. Includes fishing equipment and outdoor fire pit. Perfect for romantic getaways or fishing enthusiasts.', 'Lake Tahoe, CA, USA', 180.00, '2023-08-30 13:20:00', '2024-04-12 08:55:00'),

-- Amanda Lee properties
('660e8400-e29b-41d4-a716-446655440010', '550e8400-e29b-41d4-a716-446655440012', 'Desert Oasis Resort', 'Luxurious desert resort-style home with pool, spa, and mountain views. 4 bedrooms, 3 bathrooms, gourmet kitchen, and outdoor entertainment area. Features putting green, fire pit, and outdoor kitchen. Ideal for large groups and special events.', 'Scottsdale, AZ, USA', 320.00, '2023-08-05 10:15:00', '2024-05-20 14:40:00'),

-- Kevin White properties
('660e8400-e29b-41d4-a716-446655440011', '550e8400-e29b-41d4-a716-446655440013', 'Urban Studio Apartment', 'Sleek studio in trendy neighborhood with easy access to nightlife and dining. Modern furnishings, full kitchen, and high-speed internet. Building amenities include gym and rooftop deck. Perfect for young professionals and city explorers.', 'Austin, TX, USA', 85.00, '2024-01-15 12:30:00', '2024-03-28 16:15:00'),
('660e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440013', 'Music City Townhouse', 'Stylish 3-bedroom townhouse in the heart of Music City. Walking distance to famous honky-tonks and live music venues. Features modern amenities, private parking, and rooftop terrace with city views. Includes local restaurant recommendations.', 'Nashville, TN, USA', 165.00, '2024-02-20 14:00:00', '2024-04-15 11:25:00'),

-- Rachel Moore properties
('660e8400-e29b-41d4-a716-446655440013', '550e8400-e29b-41d4-a716-446655440014', 'Wine Country Estate', 'Elegant estate surrounded by vineyards with tasting room and cellar. 6 bedrooms, 4 bathrooms, chef''s kitchen, and multiple entertaining areas. Includes wine tastings, vineyard tours, and concierge services. Perfect for wine enthusiasts and special celebrations.', 'Napa Valley, CA, USA', 500.00, '2024-03-05 15:30:00', '2024-05-10 10:20:00'),

-- Additional properties for variety
('660e8400-e29b-41d4-a716-446655440014', '550e8400-e29b-41d4-a716-446655440008', 'Beach Bungalow', 'Charming beach bungalow just steps from the sand. 1 bedroom, full kitchen, and private patio with ocean views. Includes beach gear and bicycles. Perfect for a romantic escape or solo retreat.', 'Malibu, CA, USA', 225.00, '2024-01-12 09:30:00', '2024-03-20 14:15:00'),
('660e8400-e29b-41d4-a716-446655440015', '550e8400-e29b-41d4-a716-446655440009', 'City Loft Downtown', 'Modern loft in the heart of the business district. Open concept, floor-to-ceiling windows, and premium finishes. Walking distance to convention centers and fine dining. Ideal for business travelers.', 'Chicago, IL, USA', 190.00, '2024-02-08 11:20:00', '2024-05-12 16:45:00');

-- ===============================================
-- SAMPLE BOOKINGS DATA
-- ===============================================

INSERT INTO Booking (booking_id, property_id, user_id, start_date, end_date, total_price, status, created_at) VALUES
-- Confirmed bookings (past and current)
('770e8400-e29b-41d4-a716-446655440001', '660e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001', '2024-01-15', '2024-01-18', 450.00, 'confirmed', '2024-01-10 14:30:00'),
('770e8400-e29b-41d4-a716-446655440002', '660e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440002', '2024-02-01', '2024-02-07', 1680.00, 'confirmed', '2024-01-25 16:45:00'),
('770e8400-e29b-41d4-a716-446655440003', '660e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440003', '2024-02-14', '2024-02-17', 660.00, 'confirmed', '2024-02-08 10:20:00'),
('770e8400-e29b-41d4-a716-446655440004', '660e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440004', '2024-03-10', '2024-03-15', 1750.00, 'confirmed', '2024-03-05 12:15:00'),
('770e8400-e29b-41d4-a716-446655440005', '660e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440005', '2024-03-20', '2024-03-24', 780.00, 'confirmed', '2024-03-15 09:30:00'),

-- Current bookings  
('770e8400-e29b-41d4-a716-446655440006', '660e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440006', '2024-06-25', '2024-06-30', 475.00, 'confirmed', '2024-06-20 11:45:00'),
('770e8400-e29b-41d4-a716-446655440007', '660e8400-e29b-41d4-a716-446655440009', '550e8400-e29b-41d4-a716-446655440001', '2024-07-01', '2024-07-05', 720.00, 'confirmed', '2024-06-25 15:20:00'),

-- Future bookings
('770e8400-e29b-41d4-a716-446655440008', '660e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440002', '2024-08-15', '2024-08-22', 3150.00, 'confirmed', '2024-06-26 13:10:00'),
('770e8400-e29b-41d4-a716-446655440009', '660e8400-e29b-41d4-a716-446655440010', '550e8400-e29b-41d4-a716-446655440003', '2024-09-05', '2024-09-12', 2240.00, 'confirmed', '2024-06-27 08:30:00'),
('770e8400-e29b-41d4-a716-446655440010', '660e8400-e29b-41d4-a716-446655440013', '550e8400-e29b-41d4-a716-446655440004', '2024-10-10', '2024-10-17', 3500.00, 'confirmed', '2024-06-27 10:15:00'),

-- Additional bookings for new properties
('770e8400-e29b-41d4-a716-446655440015', '660e8400-e29b-41d4-a716-446655440014', '550e8400-e29b-41d4-a716-446655440016', '2024-04-05', '2024-04-08', 675.00, 'confirmed', '2024-04-01 09:20:00'),
('770e8400-e29b-41d4-a716-446655440016', '660e8400-e29b-41d4-a716-446655440015', '550e8400-e29b-41d4-a716-446655440017', '2024-04-12', '2024-04-16', 760.00, 'confirmed', '2024-04-08 14:30:00'),

-- Pending bookings
('770e8400-e29b-41d4-a716-446655440011', '660e8400-e29b-41d4-a716-446655440008', '550e8400-e29b-41d4-a716-446655440005', '2024-08-01', '2024-08-04', 525.00, 'pending', '2024-06-27 14:20:00'),
('770e8400-e29b-41d4-a716-446655440012', '660e8400-e29b-41d4-a716-446655440011', '550e8400-e29b-41d4-a716-446655440006', '2024-07-20', '2024-07-23', 255.00, 'pending', '2024-06-27 16:30:00'),

-- Canceled bookings
('770e8400-e29b-41d4-a716-446655440013', '660e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001', '2024-04-01', '2024-04-05', 600.00, 'canceled', '2024-03-25 11:00:00'),
('770e8400-e29b-41d4-a716-446655440014', '660e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440002', '2024-05-15', '2024-05-20', 825.00, 'canceled', '2024-05-10 13:45:00');

-- ===============================================
-- SAMPLE PAYMENTS DATA
-- ===============================================

INSERT INTO Payment (payment_id, booking_id, amount, payment_date, payment_method, transaction_reference, payment_status) VALUES
-- Payments for confirmed bookings
('880e8400-e29b-41d4-a716-446655440001', '770e8400-e29b-41d4-a716-446655440001', 450.00, '2024-01-10 14:35:00', 'credit_card', 'CC_2024_001_4532', 'completed'),
('880e8400-e29b-41d4-a716-446655440002', '770e8400-e29b-41d4-a716-446655440002', 1680.00, '2024-01-25 16:50:00', 'stripe', 'STRIPE_2024_002_7891', 'completed'),
('880e8400-e29b-41d4-a716-446655440003', '770e8400-e29b-41d4-a716-446655440003', 660.00, '2024-02-08 10:25:00', 'paypal', 'PAYPAL_2024_003_2456', 'completed'),
('880e8400-e29b-41d4-a716-446655440004', '770e8400-e29b-41d4-a716-446655440004', 1750.00, '2024-03-05 12:20:00', 'credit_card', 'CC_2024_004_9876', 'completed'),
('880e8400-e29b-41d4-a716-446655440005', '770e8400-e29b-41d4-a716-446655440005', 780.00, '2024-03-15 09:35:00', 'stripe', 'STRIPE_2024_005_3321', 'completed'),
('880e8400-e29b-41d4-a716-446655440006', '770e8400-e29b-41d4-a716-446655440006', 475.00, '2024-06-20 11:50:00', 'credit_card', 'CC_2024_006_5544', 'completed'),
('880e8400-e29b-41d4-a716-446655440007', '770e8400-e29b-41d4-a716-446655440007', 720.00, '2024-06-25 15:25:00', 'paypal', 'PAYPAL_2024_007_6677', 'completed'),
('880e8400-e29b-41d4-a716-446655440008', '770e8400-e29b-41d4-a716-446655440008', 3150.00, '2024-06-26 13:15:00', 'stripe', 'STRIPE_2024_008_8899', 'completed'),
('880e8400-e29b-41d4-a716-446655440009', '770e8400-e29b-41d4-a716-446655440009', 2240.00, '2024-06-27 08:35:00', 'credit_card', 'CC_2024_009_1122', 'completed'),
('880e8400-e29b-41d4-a716-446655440010', '770e8400-e29b-41d4-a716-446655440010', 3500.00, '2024-06-27 10:20:00', 'stripe', 'STRIPE_2024_010_3344', 'completed'),

-- Payments for additional bookings
('880e8400-e29b-41d4-a716-446655440017', '770e8400-e29b-41d4-a716-446655440015', 675.00, '2024-04-01 09:25:00', 'credit_card', 'CC_2024_017_1357', 'completed'),
('880e8400-e29b-41d4-a716-446655440018', '770e8400-e29b-41d4-a716-446655440016', 760.00, '2024-04-08 14:35:00', 'paypal', 'PAYPAL_2024_018_2468', 'completed'),

-- Pending payments
('880e8400-e29b-41d4-a716-446655440011', '770e8400-e29b-41d4-a716-446655440011', 525.00, '2024-06-27 14:25:00', 'credit_card', 'CC_2024_011_5566', 'pending'),
('880e8400-e29b-41d4-a716-446655440012', '770e8400-e29b-41d4-a716-446655440012', 255.00, '2024-06-27 16:35:00', 'paypal', 'PAYPAL_2024_012_7788', 'pending'),

-- Refunded payments (for canceled bookings)
('880e8400-e29b-41d4-a716-446655440013', '770e8400-e29b-41d4-a716-446655440013', 600.00, '2024-03-25 11:05:00', 'credit_card', 'CC_2024_013_9900', 'refunded'),
('880e8400-e29b-41d4-a716-446655440014', '770e8400-e29b-

-- Complete the Payment INSERT statement
('880e8400-e29b-41d4-a716-446655440014', '770e8400-e29b-41d4-a716-446655440014', 825.00, '2024-05-10 13:50:00', 'stripe', 'STRIPE_2024_014_1234', 'refunded'),

-- Failed payment
('880e8400-e29b-41d4-a716-446655440015', '770e8400-e29b-41d4-a716-446655440013', 600.00, '2024-03-20 10:30:00', 'credit_card', 'CC_2024_015_FAIL', 'failed');

-- ===============================================
-- SAMPLE REVIEWS DATA
-- ===============================================

INSERT INTO Review (review_id, property_id, user_id, rating, comment, created_at) VALUES
-- Reviews for completed stays
('990e8400-e29b-41d4-a716-446655440001', '660e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001', 5, 'Amazing location and spotless apartment. Robert was very responsive and helpful. Highly recommend!', '2024-01-20 10:15:00'),
('990e8400-e29b-41d4-a716-446655440002', '660e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440002', 4, 'Beautiful beachfront property with stunning views. Could use some kitchen upgrades but overall great stay.', '2024-02-10 14:30:00'),
('990e8400-e29b-41d4-a716-446655440003', '660e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440003', 5, 'Perfect mountain getaway. Cozy cabin with everything we needed. Will definitely book again!', '2024-02-20 16:45:00'),
('990e8400-e29b-41d4-a716-446655440004', '660e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440004', 5, 'Luxury penthouse exceeded expectations. Incredible city views and premium amenities.', '2024-03-18 11:20:00'),
('990e8400-e29b-41d4-a716-446655440005', '660e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440005', 4, 'Charming Victorian home with great character. Neighborhood was perfect for exploring the city.', '2024-03-27 09:30:00'),
('990e8400-e29b-41d4-a716-446655440006', '660e8400-e29b-41d4-a716-446655440014', '550e8400-e29b-41d4-a716-446655440016', 3, 'Nice beach location but property needs some maintenance. Host was accommodating though.', '2024-04-12 15:20:00');

-- ===============================================
-- SAMPLE MESSAGES DATA
-- ===============================================

INSERT INTO Message (message_id, sender_id, receiver_id, booking_id, message_content, sent_at, is_read) VALUES
-- Booking coordination messages
('aa0e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440007', '770e8400-e29b-41d4-a716-446655440001', 'Hi Robert, looking forward to our stay. What time is check-in?', '2024-01-12 09:30:00', true),
('aa0e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440001', '770e8400-e29b-41d4-a716-446655440001', 'Hi John! Check-in is flexible between 3-7 PM. I''ll send you the door code closer to arrival.', '2024-01-12 11:45:00', true),
('aa0e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440008', '770e8400-e29b-41d4-a716-446655440002', 'Do you have any restaurant recommendations near the villa?', '2024-01-28 16:20:00', true),
('aa0e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440008', '550e8400-e29b-41d4-a716-446655440002', '770e8400-e29b-41d4-a716-446655440002', 'Absolutely! I''ve left a local dining guide in the welcome folder. Joe''s Stone Crab is a must-try!', '2024-01-28 18:10:00', true),
('aa0e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440011', '770e8400-e29b-41d4-a716-446655440011', 'Is the property pet-friendly? I have a small dog.', '2024-06-27 15:30:00', false),
('aa0e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440012', '770e8400-e29b-41d4-a716-446655440009', 'Thank you for the booking! The pool will be heated for your September stay.', '2024-06-27 12:15:00', false);

-- ===============================================
-- VERIFICATION AND SUMMARY
-- ===============================================

-- Check record counts
SELECT 'Users' as table_name, COUNT(*) as record_count FROM "User"
UNION ALL
SELECT 'Properties', COUNT(*) FROM Property
UNION ALL  
SELECT 'Bookings', COUNT(*) FROM Booking
UNION ALL
SELECT 'Payments', COUNT(*) FROM Payment
UNION ALL
SELECT 'Reviews', COUNT(*) FROM Review
UNION ALL
SELECT 'Messages', COUNT(*) FROM Message;

-- ===============================================
-- END OF SAMPLE DATA SCRIPT
-- ===============================================