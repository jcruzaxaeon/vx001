-- 001__users.seed.sql

-- Disable foreign key checks for safe reseeding
SET FOREIGN_KEY_CHECKS = 0;

-- Clear the table first (safe for dev environments)
DELETE FROM users;

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

-- Insert sample users
INSERT INTO users (
    email,
    password_hash,
    username,
    email_verified,
    email_verification_token,
    email_verification_expiry,
    reset_token,
    reset_token_expiry,
    created_at,
    updated_at
) VALUES
-- Basic verified user
('alice@example.com', 'hashed_password_1', 'alice123', TRUE, NULL, NULL, NULL, NULL, NOW(), NOW()),

-- Unverified user
('bob@example.com', 'hashed_password_2', 'bobby', FALSE, 'token_bob_123', NOW() + INTERVAL 1 DAY, NULL, NULL, NOW(), NOW()),

-- User with a reset token
('charlie@example.com', 'hashed_password_3', 'charlieC', TRUE, NULL, NULL, 'reset_charlie_xyz', NOW() + INTERVAL 30 MINUTE, NOW(), NOW()),

-- Edge case: no username, unverified
('dana@example.com', 'hashed_password_4', NULL, FALSE, 'token_dana_456', NOW() + INTERVAL 2 DAY, NULL, NULL, NOW(), NOW());