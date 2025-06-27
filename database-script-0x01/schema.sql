-- ===============================================
-- AirBnB Database Schema Definition
-- File: schema.sql
-- Author: Simanga Mchunu
-- Created: 2025-06-27
-- Description: Complete database schema for AirBnB-like application
-- ===============================================

-- Enable UUID extension (PostgreSQL specific)
-- For MySQL, use CHAR(36) or consider using auto-increment integers
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ===============================================
-- DROP TABLES (for clean recreation)
-- ===============================================
DROP TABLE IF EXISTS Message CASCADE;
DROP TABLE IF EXISTS Review CASCADE;
DROP TABLE IF EXISTS Payment CASCADE;
DROP TABLE IF EXISTS Booking CASCADE;
DROP TABLE IF EXISTS Property CASCADE;
DROP TABLE IF EXISTS User CASCADE;

-- ===============================================
-- USER TABLE
-- ===============================================
CREATE TABLE User (
    user_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20) NULL,
    role VARCHAR(10) NOT NULL CHECK (role IN ('guest', 'host', 'admin')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Additional constraints
    CONSTRAINT chk_email_format CHECK (email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT chk_phone_format CHECK (phone_number IS NULL OR phone_number ~ '^\+?[1-9]\d{1,14}$'),
    CONSTRAINT chk_name_length CHECK (LENGTH(TRIM(first_name)) >= 1 AND LENGTH(TRIM(last_name)) >= 1)
);

-- User table indexes
CREATE INDEX idx_user_email ON User(email);
CREATE INDEX idx_user_role ON User(role);
CREATE INDEX idx_user_created_at ON User(created_at);
CREATE INDEX idx_user_full_name ON User(first_name, last_name);

-- ===============================================
-- PROPERTY TABLE
-- ===============================================
CREATE TABLE Property (
    property_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    host_id UUID NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    location VARCHAR(500) NOT NULL,
    price_per_night DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign key constraints
    CONSTRAINT fk_property_host FOREIGN KEY (host_id) REFERENCES User(user_id) ON DELETE CASCADE,
    
    -- Business logic constraints
    CONSTRAINT chk_price_positive CHECK (price_per_night > 0),
    CONSTRAINT chk_name_length CHECK (LENGTH(TRIM(name)) >= 3),
    CONSTRAINT chk_description_length CHECK (LENGTH(TRIM(description)) >= 10),
    CONSTRAINT chk_location_length CHECK (LENGTH(TRIM(location)) >= 5)
);

-- Property table indexes
CREATE INDEX idx_property_host_id ON Property(host_id);
CREATE INDEX idx_property_location ON Property(location);
CREATE INDEX idx_property_price ON Property(price_per_night);
CREATE INDEX idx_property_created_at ON Property(created_at);
CREATE INDEX idx_property_name ON Property(name);

-- Trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_property_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_property_updated_at
    BEFORE UPDATE ON Property
    FOR EACH ROW
    EXECUTE FUNCTION update_property_timestamp();

-- ===============================================
-- BOOKING TABLE
-- ===============================================
CREATE TABLE Booking (
    booking_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    property_id UUID NOT NULL,
    user_id UUID NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    status VARCHAR(10) NOT NULL CHECK (status IN ('pending', 'confirmed', 'canceled')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign key constraints
    CONSTRAINT fk_booking_property FOREIGN KEY (property_id) REFERENCES Property(property_id) ON DELETE CASCADE,
    CONSTRAINT fk_booking_user FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE CASCADE,
    
    -- Business logic constraints
    CONSTRAINT chk_booking_dates CHECK (end_date > start_date),
    CONSTRAINT chk_booking_future CHECK (start_date >= CURRENT_DATE),
    CONSTRAINT chk_total_price_positive CHECK (total_price > 0),
    
    -- Prevent double booking (same property, overlapping dates, confirmed status)
    CONSTRAINT chk_no_overlap EXCLUDE USING gist (
        property_id WITH =,
        daterange(start_date, end_date, '[]') WITH &&
    ) WHERE (status = 'confirmed')
);

-- Booking table indexes
CREATE INDEX idx_booking_property_id ON Booking(property_id);
CREATE INDEX idx_booking_user_id ON Booking(user_id);
CREATE INDEX idx_booking_dates ON Booking(start_date, end_date);
CREATE INDEX idx_booking_status ON Booking(status);
CREATE INDEX idx_booking_created_at ON Booking(created_at);
CREATE INDEX idx_booking_property_dates ON Booking(property_id, start_date, end_date);

-- ===============================================
-- PAYMENT TABLE
-- ===============================================
CREATE TABLE Payment (
    payment_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id UUID NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_method VARCHAR(15) NOT NULL CHECK (payment_method IN ('credit_card', 'paypal', 'stripe')),
    transaction_reference VARCHAR(100) NULL,
    payment_status VARCHAR(10) DEFAULT 'completed' CHECK (payment_status IN ('pending', 'completed', 'failed', 'refunded')),
    
    -- Foreign key constraints
    CONSTRAINT fk_payment_booking FOREIGN KEY (booking_id) REFERENCES Booking(booking_id) ON DELETE CASCADE,
    
    -- Business logic constraints
    CONSTRAINT chk_payment_amount_positive CHECK (amount > 0)
);

-- Payment table indexes
CREATE INDEX idx_payment_booking_id ON Payment(booking_id);
CREATE INDEX idx_payment_date ON Payment(payment_date);
CREATE INDEX idx_payment_method ON Payment(payment_method);
CREATE INDEX idx_payment_status ON Payment(payment_status);
CREATE INDEX idx_payment_reference ON Payment(transaction_reference);

-- ===============================================
-- REVIEW TABLE
-- ===============================================
CREATE TABLE Review (
    review_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    property_id UUID NOT NULL,
    user_id UUID NOT NULL,
    rating INTEGER NOT NULL,
    comment TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign key constraints
    CONSTRAINT fk_review_property FOREIGN KEY (property_id) REFERENCES Property(property_id) ON DELETE CASCADE,
    CONSTRAINT fk_review_user FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE CASCADE,
    
    -- Business logic constraints
    CONSTRAINT chk_rating_range CHECK (rating >= 1 AND rating <= 5),
    CONSTRAINT chk_comment_length CHECK (LENGTH(TRIM(comment)) >= 10),
    
    -- Prevent multiple reviews from same user for same property
    CONSTRAINT uk_review_user_property UNIQUE (user_id, property_id)
);

-- Review table indexes
CREATE INDEX idx_review_property_id ON Review(property_id);
CREATE INDEX idx_review_user_id ON Review(user_id);
CREATE INDEX idx_review_rating ON Review(rating);
CREATE INDEX idx_review_created_at ON Review(created_at);
CREATE INDEX idx_review_property_rating ON Review(property_id, rating);

-- ===============================================
-- MESSAGE TABLE
-- ===============================================
CREATE TABLE Message (
    message_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sender_id UUID NOT NULL,
    recipient_id UUID NOT NULL,
    message_body TEXT NOT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP NULL,
    message_type VARCHAR(20) DEFAULT 'general' CHECK (message_type IN ('general', 'booking_inquiry', 'booking_confirmation', 'support')),
    
    -- Foreign key constraints
    CONSTRAINT fk_message_sender FOREIGN KEY (sender_id) REFERENCES User(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_message_recipient FOREIGN KEY (recipient_id) REFERENCES User(user_id) ON DELETE CASCADE,
    
    -- Business logic constraints  
    CONSTRAINT chk_message_body_length CHECK (LENGTH(TRIM(message_body)) >= 1),
    CONSTRAINT chk_different_users CHECK (sender_id != recipient_id)
);

-- Message table indexes
CREATE INDEX idx_message_sender_id ON Message(sender_id);
CREATE INDEX idx_message_recipient_id ON Message(recipient_id);
CREATE INDEX idx_message_sent_at ON Message(sent_at);
CREATE INDEX idx_message_read_at ON Message(read_at);
CREATE INDEX idx_message_type ON Message(message_type);
CREATE INDEX idx_message_conversation ON Message(sender_id, recipient_id, sent_at);

-- ===============================================
-- ADDITIONAL PERFORMANCE INDEXES
-- ===============================================

-- Composite indexes for common query patterns
CREATE INDEX idx_property_host_price ON Property(host_id, price_per_night);
CREATE INDEX idx_booking_user_status ON Booking(user_id, status);
CREATE INDEX idx_booking_property_status ON Booking(property_id, status);
CREATE INDEX idx_payment_booking_status ON Payment(booking_id, payment_status);

-- Full-text search indexes (PostgreSQL specific)
CREATE INDEX idx_property_search ON Property USING gin(to_tsvector('english', name || ' ' || description || ' ' || location));
CREATE INDEX idx_user_search ON User USING gin(to_tsvector('english', first_name || ' ' || last_name || ' ' || COALESCE(email, '')));

-- ===============================================
-- VIEWS FOR COMMON QUERIES
-- ===============================================

-- Property details with host information
CREATE OR REPLACE VIEW property_details AS
SELECT 
    p.property_id,
    p.name AS property_name,
    p.description,
    p.location,
    p.price_per_night,
    p.created_at AS property_created_at,
    u.user_id AS host_id,
    u.first_name AS host_first_name,
    u.last_name AS host_last_name,
    u.email AS host_email,
    COUNT(r.review_id) AS total_reviews,
    ROUND(AVG(r.rating), 2) AS average_rating
FROM Property p
JOIN User u ON p.host_id = u.user_id
LEFT JOIN Review r ON p.property_id = r.property_id
GROUP BY p.property_id, u.user_id;

-- Booking summary with user and property details
CREATE OR REPLACE VIEW booking_summary AS
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    b.created_at AS booking_created_at,
    u.first_name AS guest_first_name,
    u.last_name AS guest_last_name,
    u.email AS guest_email,
    p.name AS property_name,
    p.location AS property_location,
    h.first_name AS host_first_name,
    h.last_name AS host_last_name
FROM Booking b
JOIN User u ON b.user_id = u.user_id
JOIN Property p ON b.property_id = p.property_id
JOIN User h ON p.host_id = h.user_id;

-- ===============================================
-- FUNCTIONS FOR BUSINESS LOGIC
-- ===============================================

-- Function to calculate booking duration
CREATE OR REPLACE FUNCTION calculate_booking_duration(start_date DATE, end_date DATE)
RETURNS INTEGER AS $$
BEGIN
    RETURN end_date - start_date;
END;
$$ LANGUAGE plpgsql;

-- Function to check property availability
CREATE OR REPLACE FUNCTION is_property_available(
    prop_id UUID, 
    check_start_date DATE, 
    check_end_date DATE
)
RETURNS BOOLEAN AS $$
DECLARE
    booking_count INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO booking_count
    FROM Booking
    WHERE property_id = prop_id
    AND status = 'confirmed'
    AND daterange(start_date, end_date, '[]') && daterange(check_start_date, check_end_date, '[]');
    
    RETURN booking_count = 0;
END;
$$ LANGUAGE plpgsql;

-- ===============================================
-- SAMPLE DATA CONSTRAINTS VALIDATION
-- ===============================================

-- Add comments for documentation
COMMENT ON TABLE User IS 'Stores user information for guests, hosts, and administrators';
COMMENT ON TABLE Property IS 'Stores property listings with host information';
COMMENT ON TABLE Booking IS 'Stores booking information linking users and properties';
COMMENT ON TABLE Payment IS 'Stores payment information for bookings';
COMMENT ON TABLE Review IS 'Stores user reviews and ratings for properties';
COMMENT ON TABLE Message IS 'Stores messages between users';

COMMENT ON COLUMN User.role IS 'User role: guest, host, or admin';
COMMENT ON COLUMN Booking.status IS 'Booking status: pending, confirmed, or canceled';
COMMENT ON COLUMN Payment.payment_method IS 'Payment method: credit_card, paypal, or stripe';
COMMENT ON COLUMN Review.rating IS 'Property rating from 1 to 5 stars';

-- ===============================================
-- SECURITY AND PERMISSIONS
-- ===============================================

-- Create roles (uncomment and modify as needed for your environment)
-- CREATE ROLE airbnb_admin;
-- CREATE ROLE airbnb_app;
-- CREATE ROLE airbnb_readonly;

-- Grant permissions
-- GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO airbnb_admin;
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO airbnb_app;
-- GRANT SELECT ON ALL TABLES IN SCHEMA public TO airbnb_readonly;

-- ===============================================
-- END OF SCHEMA DEFINITION
-- ===============================================

-- Display creation summary
DO $$
BEGIN
    RAISE NOTICE 'AirBnB Database Schema Created Successfully!';
    RAISE NOTICE 'Tables: User, Property, Booking, Payment, Review, Message';
    RAISE NOTICE 'Views: property_details, booking_summary';
    RAISE NOTICE 'Functions: calculate_booking_duration, is_property_available';
    RAISE NOTICE 'Total Indexes: 25+ performance-optimized indexes created';
END $$;