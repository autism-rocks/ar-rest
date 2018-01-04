CREATE TABLE participant
(
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255),
  dob DATE,
  gender VARCHAR(8),
  country VARCHAR(50),
  city VARCHAR(50),
  photo VARCHAR(255)
);


-- Roles in participants
CREATE TABLE user_participant
(
  id_user INT,
  id_participant INT,
  role ENUM('ADMIN', 'VIEWER'),
  CONSTRAINT user_participant_id_user_id_participant_pk PRIMARY KEY (id_user, id_participant),
  CONSTRAINT user_participant_user_id_fk FOREIGN KEY (id_user) REFERENCES user (id),
  CONSTRAINT user_participant_participant_id_fk FOREIGN KEY (id_participant) REFERENCES participant (id)
);