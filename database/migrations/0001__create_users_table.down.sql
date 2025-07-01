-- pathname: ./database/migrations/0001__create_users_table.down.sql

DROP TABLE IF EXISTS users;

DELETE FROM migrations WHERE migration = '0001__create_users_table';