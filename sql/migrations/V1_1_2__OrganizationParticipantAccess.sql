CREATE TABLE organization_participant
(
  id_organization INT,
  id_participant INT,
  role ENUM('EDITOR', 'VIEWER'),
  CONSTRAINT organization_participant_participant_id_fk FOREIGN KEY (id_participant) REFERENCES participant (id),
  CONSTRAINT organization_participant_organization_id_fk FOREIGN KEY (id_organization) REFERENCES organization (id)
);