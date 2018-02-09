ALTER TABLE model_group
  ADD scoring TEXT NULL;

CREATE TABLE model_group_score
(
  id             INT PRIMARY KEY AUTO_INCREMENT,
  id_user        INT,
  id_model_group INT,
  id_participant INT,
  score          INT,
  date           DATE,
  average_level  FLOAT NULL,
  sum_level      FLOAT NULL,
  CONSTRAINT model_participant_score_user_id_fk FOREIGN KEY (id_user) REFERENCES user (id),
  CONSTRAINT model_participant_score_participant_id_fk FOREIGN KEY (id_participant) REFERENCES participant (id),
  CONSTRAINT model_participant_score_model_group_id_fk FOREIGN KEY (id_model_group) REFERENCES model_group (id)
);

UPDATE model_group SET scoring='[[1,[0,50]], [2,[51,82]], [3,[83,119]],  [4,[120,144]], [5,[145,180]]]' WHERE ref='O';
UPDATE model_group SET scoring='[[1,[0,13]], [2,[14,19]], [3,[20,30]],   [4,[31,42]],   [5,[43,50]]]' WHERE ref='OF';
UPDATE model_group SET scoring='[[1,[0,22]], [2,[23,30]], [3,[31,34]],   [4,[35,39]],   [5,[40,50]]]' WHERE ref='OE';
UPDATE model_group SET scoring='[[1,[0,15]], [2,[16,33]], [3,[34,55]],   [4,[56,63]],   [5,[64,80]]]' WHERE ref='ON';
UPDATE model_group SET scoring='[[1,[0,56]], [2,[57,97]], [3,[98,133]],  [4,[134,194]], [5,[195,250]]]' WHERE ref='A';
UPDATE model_group SET scoring='[[1,[0,13]], [2,[14,21]], [3,[22,31]],   [4,[32,43]],   [5,[44,50]]]' WHERE ref='AD';
UPDATE model_group SET scoring='[[1,[0,10]], [2,[11,19]], [3,[20,27]],   [4,[28,39]],   [5,[40,50]]]' WHERE ref='AF';
UPDATE model_group SET scoring='[[1,[0,16]], [2,[17,34]], [3,[35,46]],   [4,[47,76]],   [5,[77,100]]]' WHERE ref='AA';
UPDATE model_group SET scoring='[[1,[0,17]], [2,[18,23]], [3,[24,29]],   [4,[30,36]],   [5,[37,50]]]' WHERE ref='AC';
UPDATE model_group SET scoring='[[1,[0,31]], [2,[32,88]], [3,[89,144]],  [4,[145,226]], [5,[227,280]]]' WHERE ref='V';
UPDATE model_group SET scoring='[[1,[0,16]], [2,[17,37]], [3,[38,47]],   [4,[48,57]],   [5,[58,70]]]' WHERE ref='VV';
UPDATE model_group SET scoring='[[1,[0,3]],  [2,[4,11]],  [3,[12,16]],   [4,[17,23]],   [5,[24,30]]]' WHERE ref='VT';
UPDATE model_group SET scoring='[[1,[0,1]],  [2,[2,6]],   [3,[7,16]],    [4,[17,33]],   [5,[34,40]]]' WHERE ref='VC';
UPDATE model_group SET scoring='[[1,[0,1]],  [2,[2,14]],  [3,[15,35]],   [4,[36,59]],   [5,[60,70]]]' WHERE ref='VM';
UPDATE model_group SET scoring='[[1,[0,10]], [2,[11,20]], [3,[21,30]],   [4,[31,54]],   [5,[55,70]]]' WHERE ref='VF';
UPDATE model_group SET scoring='[[1,[0,35]], [2,[36,68]], [3,[69,103]],  [4,[104,139]], [5,[140,160]]]' WHERE ref='F';
UPDATE model_group SET scoring='[[1,[0,22]], [2,[23,47]], [3,[48,68]],   [4,[69,96]],   [5,[97,110]]]' WHERE ref='FF';
UPDATE model_group SET scoring='[[1,[0,13]], [2,[14,21]], [3,[22,34]],   [4,[35,43]],   [5,[44,50]]]' WHERE ref='FE';
UPDATE model_group SET scoring='[[1,[0,24]], [2,[25,44]], [3,[45,54]],   [4,[55,66]],   [5,[67,90]]]' WHERE ref='S';
UPDATE model_group SET scoring='[[1,[0,8]],  [2,[9,20]],  [3,[21,39]],   [4,[40,64]],   [5,[65,90]]]' WHERE ref='C';
