ALTER TABLE user ADD google_id VARCHAR(255) NULL;
CREATE UNIQUE INDEX user_google_id_uindex ON user (google_id);