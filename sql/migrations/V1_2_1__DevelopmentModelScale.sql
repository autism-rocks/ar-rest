ALTER TABLE model_group ADD scale VARCHAR(20) NULL;
UPDATE model_group set scale='frequency' WHERE id_parent IN (1, 6);
UPDATE model_group set scale='confirmation' WHERE id_parent IN (12, 17);
UPDATE model_group set scale='problem' WHERE id IN (20, 21);
