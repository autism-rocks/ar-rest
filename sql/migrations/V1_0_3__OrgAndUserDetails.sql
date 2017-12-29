ALTER TABLE organization ADD address VARCHAR(255) NULL;
ALTER TABLE organization ADD country VARCHAR(50) NULL;
ALTER TABLE organization ADD city VARCHAR(50) NULL;
ALTER TABLE organization ADD postcode VARCHAR(20) NULL;
ALTER TABLE organization ADD phone VARCHAR(25) NULL;
ALTER TABLE organization ADD website VARCHAR(255) NULL;
ALTER TABLE organization ADD verified BOOLEAN NULL;
ALTER TABLE organization ADD email VARCHAR(255) NULL;
CREATE UNIQUE INDEX organization_email_uindex ON organization (email);

ALTER TABLE user ADD address VARCHAR(255) NULL;
ALTER TABLE user ADD country VARCHAR(50) NULL;
ALTER TABLE user ADD city VARCHAR(50) NULL;
ALTER TABLE user ADD postcode VARCHAR(20) NULL;
ALTER TABLE user ADD phone VARCHAR(25) NULL;