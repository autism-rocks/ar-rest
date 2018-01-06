
-- Users Table
CREATE TABLE user
(
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255),
    display_name VARCHAR(255),
    email VARCHAR(255),
    password VARCHAR(255)
);
CREATE UNIQUE INDEX user_email_uindex ON user (email);

-- Organizations Table
CREATE TABLE organization
(
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255),
    display_name VARCHAR(255)
);
CREATE UNIQUE INDEX organization_name_uindex ON organization (name);

-- Roles in Organizations
CREATE TABLE user_organization
(
    id_user INT,
    id_organization INT,
    role ENUM('ADMIN', 'HELPDESK', 'TERAPEUT', 'MEMBER'),
    CONSTRAINT user_organization_id_user_id_organization_pk PRIMARY KEY (id_user, id_organization),
    CONSTRAINT user_organization_user_id_fk FOREIGN KEY (id_user) REFERENCES user (id),
    CONSTRAINT user_organization_organization_id_fk FOREIGN KEY (id_organization) REFERENCES organization (id)
);