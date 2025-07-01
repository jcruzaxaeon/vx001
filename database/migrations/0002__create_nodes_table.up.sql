-- pathname: ./database/migrations/0002__create_nodes_table.up.sql

CREATE TABLE IF NOT EXISTS nodes (
    node_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    name_canonical VARCHAR(255) NOT NULL UNIQUE,
    slug VARCHAR(255) NOT NULL UNIQUE,
    type VARCHAR(50) NOT NULL,
    dev JSON,
    visibility ENUM('private', 'shared', 'public') NOT NULL DEFAULT 'private',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    creator_FK BIGINT NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    updater_FK BIGINT,
    owner_FK BIGINT NOT NULL

    -- -- Foreign key constraints
    -- CONSTRAINT fk_nodes_creator FOREIGN KEY (creator_FK) REFERENCES users(id) ON DELETE RESTRICT,
    -- CONSTRAINT fk_nodes_updater FOREIGN KEY (updater_FK) REFERENCES users(id) ON DELETE SET NULL,
    -- CONSTRAINT fk_nodes_owner FOREIGN KEY (owner_FK) REFERENCES users(id) ON DELETE RESTRICT,
    
    -- -- Indexes
    -- INDEX idx_nodes_type (type),
    -- INDEX idx_nodes_visibility (visibility),
    -- INDEX idx_nodes_creator_fk (creator_FK),
    -- INDEX idx_nodes_owner_fk (owner_FK),
    -- INDEX idx_nodes_created_at (created_at)
);

-- Record migration
INSERT INTO migrations (migration) VALUES ('0002__create_nodes_table');