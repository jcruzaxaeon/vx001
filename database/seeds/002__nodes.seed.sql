-- 002__nodes.seed.sql

SET FOREIGN_KEY_CHECKS = 0;
DELETE FROM nodes;
SET FOREIGN_KEY_CHECKS = 1;

INSERT INTO nodes (
    name,
    name_canonical,
    slug,
    type,
    dev,
    visibility,
    creator_FK,
    updater_FK,
    owner_FK,
    created_at,
    updated_at
) VALUES

-- Public text node
('First Node', 'first node', 'first-node', 'text',
  JSON_OBJECT(
    'editable', TRUE,
    'tags', JSON_ARRAY('sample', 'test')
  ),
 'public', 1, 1, 1, NOW(), NOW()),

-- Private image node
('Secret Image', 'secret image', 'secret-image', 'image',
  JSON_OBJECT(
    'format', 'png',
    'width', 800,
    'height', 600
  ),
 'private', 2, NULL, 2, NOW(), NOW()),

-- Shared folder node
('Shared Folder', 'shared folder', 'shared-folder', 'folder',
  JSON_OBJECT(
    'permission', 'read-only'
  ),
 'shared', 3, 1, 1, NOW(), NOW()),

-- Public notebook node
('Notebook Entry', 'notebook entry', 'notebook-entry', 'notebook',
  JSON_OBJECT(
    'pages', 5,
    'color', 'blue'
  ),
 'public', 1, 3, 1, NOW(), NOW());
