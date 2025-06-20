-- Clean up all seed data (useful for testing)
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE nodes;
TRUNCATE TABLE users;
SET FOREIGN_KEY_CHECKS = 1;

-- Reset auto increment
ALTER TABLE users AUTO_INCREMENT = 1;
ALTER TABLE nodes AUTO_INCREMENT = 1;