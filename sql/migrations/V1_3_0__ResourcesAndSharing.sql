CREATE TABLE resource
(
  id INT PRIMARY KEY AUTO_INCREMENT,
  id_organization INT,
  id_lang INT,
  title VARCHAR(255),
  description TEXT,
  url VARCHAR(255),
  tags VARCHAR(255),
  thumbnail VARCHAR(255),
  created DATETIME,
  CONSTRAINT resource_id_organization_id_fk FOREIGN KEY (id_organization) REFERENCES organization (id) ON DELETE CASCADE,
  CONSTRAINT resource_id_lang_id_fk FOREIGN KEY (id_lang) REFERENCES lang (id)
);


CREATE TABLE message
(
  id INT PRIMARY KEY AUTO_INCREMENT,
  id_organization INT,
  id_user_from INT,
  id_user_to INT,
  subject VARCHAR(255),
  message_type_ref ENUM('EMAIL', 'SMS', 'CALL'),
  message VARCHAR(255),
  is_read BOOLEAN DEFAULT FALSE,
  sent_date DATETIME,
  CONSTRAINT resources_id_organization_id_fk FOREIGN KEY (id_organization) REFERENCES organization (id) ON DELETE CASCADE,
  CONSTRAINT resources_id_user_from_id_fk FOREIGN KEY (id_user_from) REFERENCES user (id) ON DELETE CASCADE,
  CONSTRAINT resources_id_user_to_id_fk FOREIGN KEY (id_user_to) REFERENCES user (id) ON DELETE CASCADE
);


CREATE TABLE message_resource (
  id INT PRIMARY KEY AUTO_INCREMENT,
  id_message INT,
  id_resource INT,
  CONSTRAINT resources_id_message_id_fk FOREIGN KEY (id_message) REFERENCES message (id) ON DELETE CASCADE,
  CONSTRAINT resources_id_resource_id_fk FOREIGN KEY (id_resource) REFERENCES resource (id) ON DELETE CASCADE
);


