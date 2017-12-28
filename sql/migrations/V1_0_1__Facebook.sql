ALTER TABLE user ADD facebook_id VARCHAR(255) NULL;
CREATE UNIQUE INDEX user_facebook_id_uindex ON user (facebook_id);
ALTER TABLE user ADD locale VARCHAR(10) NULL;
ALTER TABLE user ADD timezone INT NULL;