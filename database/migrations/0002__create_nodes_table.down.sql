-- pathname: ./api/database/migrations/0002__create_nodes_table.down.sql

DROP TABLE IF EXISTS nodes;

DELETE FROM migrations WHERE migration = '0002__create_nodes_table';