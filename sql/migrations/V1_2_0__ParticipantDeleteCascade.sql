ALTER TABLE user_participant DROP FOREIGN KEY user_participant_participant_id_fk;
ALTER TABLE user_participant
  ADD CONSTRAINT user_participant_participant_id_fk
FOREIGN KEY (id_participant) REFERENCES participant (id) ON DELETE CASCADE;

ALTER TABLE model_question_eval DROP FOREIGN KEY model_question_eval_participant_id_fk;
ALTER TABLE model_question_eval
  ADD CONSTRAINT model_question_eval_participant_id_fk
FOREIGN KEY (id_participant) REFERENCES participant (id) ON DELETE CASCADE;

ALTER TABLE model_question_eval DROP FOREIGN KEY model_question_eval_participant_id_fk;
ALTER TABLE model_question_eval
  ADD CONSTRAINT model_question_eval_participant_id_fk
FOREIGN KEY (id_participant) REFERENCES participant (id) ON DELETE CASCADE;


ALTER TABLE organization_participant DROP FOREIGN KEY organization_participant_organization_id_fk;
ALTER TABLE organization_participant
  ADD CONSTRAINT organization_participant_organization_id_fk
FOREIGN KEY (id_organization) REFERENCES organization (id) ON DELETE CASCADE;

ALTER TABLE organization_participant DROP FOREIGN KEY organization_participant_participant_id_fk;
ALTER TABLE organization_participant
  ADD CONSTRAINT organization_participant_participant_id_fk
FOREIGN KEY (id_participant) REFERENCES participant (id) ON DELETE CASCADE;


ALTER TABLE user_organization DROP FOREIGN KEY user_organization_user_id_fk;
ALTER TABLE user_organization
  ADD CONSTRAINT user_organization_user_id_fk
FOREIGN KEY (id_user) REFERENCES user (id) ON DELETE CASCADE;

ALTER TABLE user_organization DROP FOREIGN KEY user_organization_organization_id_fk;
ALTER TABLE user_organization
  ADD CONSTRAINT user_organization_organization_id_fk
FOREIGN KEY (id_organization) REFERENCES organization (id) ON DELETE CASCADE;