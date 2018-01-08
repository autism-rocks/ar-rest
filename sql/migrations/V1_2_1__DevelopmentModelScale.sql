ALTER TABLE model_question ADD scale VARCHAR(20) NULL;
UPDATE model_question SET scale = 'frequency' WHERE id < 90;
UPDATE model_question SET scale = 'problem' WHERE id >= 90;