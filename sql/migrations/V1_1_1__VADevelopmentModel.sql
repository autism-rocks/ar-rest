-- table to support translations
CREATE TABLE lang
(
  id INT PRIMARY KEY AUTO_INCREMENT,
  lang VARCHAR(10)
);

-- table to hold all question-based development models
CREATE TABLE model
(
  id INT PRIMARY KEY AUTO_INCREMENT,
  ref VARCHAR(25) NOT NULL
);

-- table to hold the model name translations
CREATE TABLE model_lang
(
  id_model INT NOT NULL,
  id_lang INT NOT NULL,
  name VARCHAR(255),
  CONSTRAINT model_lang_id_model_id_lang_pk PRIMARY KEY (id_model, id_lang),
  CONSTRAINT model_lang_id_model_fk FOREIGN KEY (id_model) REFERENCES model (id),
  CONSTRAINT model_lang_id_lang_fk FOREIGN KEY (id_lang) REFERENCES lang (id)
);


-- table to hold the model group and translations
CREATE TABLE model_group
(
  id INT PRIMARY KEY AUTO_INCREMENT,
  id_parent INT,
  id_model INT NOT NULL,
  sequence_number INT,
  ref VARCHAR(25),
  CONSTRAINT model_group_parent_id_fk FOREIGN KEY (id_parent) REFERENCES model_group (id),
  CONSTRAINT model_id_model_fk FOREIGN KEY (id_model) REFERENCES model (id)
);

CREATE TABLE model_group_lang
(
  id_model_group INT NOT NULL,
  id_lang INT NOT NULL,
  name VARCHAR(255),
  CONSTRAINT model_group_lang_id_model_id_lang_pk PRIMARY KEY (id_model_group, id_lang),
  CONSTRAINT model_group_lang_id_model_fk FOREIGN KEY (id_model_group) REFERENCES model_group (id),
  CONSTRAINT model_group_lang_id_lang_fk FOREIGN KEY (id_lang) REFERENCES lang (id)
);


-- table to hold the model group and translations
CREATE TABLE model_question
(
  id INT PRIMARY KEY AUTO_INCREMENT,
  id_model_group INT NOT NULL,
  sequence_number INT,
  ref VARCHAR(25),
  CONSTRAINT model_question_id_model_group_fk FOREIGN KEY (id_model_group) REFERENCES model_group (id)
);

CREATE TABLE model_question_lang
(
  id_model_question INT NOT NULL,
  id_lang INT NOT NULL,
  title VARCHAR(255),
  description VARCHAR(255),
  CONSTRAINT model_question_lang_id_model_id_lang_pk PRIMARY KEY (id_model_question, id_lang),
  CONSTRAINT model_question_lang_id_model_fk FOREIGN KEY (id_model_question) REFERENCES model_question (id),
  CONSTRAINT model_question_lang_id_lang_fk FOREIGN KEY (id_lang) REFERENCES lang (id)
);


-- table to hold the question evaluations
CREATE TABLE model_question_eval
(
  id INT PRIMARY KEY AUTO_INCREMENT,
  id_user INT NOT NULL,
  id_participant INT NOT NULL,
  id_model_question INT NOT NULL,
  date DATE,
  level INT,
  confirmed BOOLEAN DEFAULT FALSE ,
  CONSTRAINT model_question_eval_user_id_fk FOREIGN KEY (id_user) REFERENCES user (id),
  CONSTRAINT model_question_eval_participant_id_fk FOREIGN KEY (id_participant) REFERENCES participant (id),
  CONSTRAINT model_question_eval_model_question_id_fk FOREIGN KEY (id_model_question) REFERENCES model_question (id)
);



-- Insert the default AutismRocks development model with Portuguese translations

INSERT INTO lang (id, lang) VALUES (1, 'pt');

INSERT INTO model (id, ref) VALUES (1, 'autism-rocks');
INSERT INTO model_lang (id_model, id_lang, name) VALUES (1, 1, 'Perfil Autism Rocks');


INSERT INTO model_group (id_model, id, id_parent, sequence_number, ref) VALUES (1, 1, NULL, 1, 'O');
INSERT INTO model_group_lang (id_model_group, id_lang, name) VALUES (1, 1, 'Contacto Visual e Comunicação Não-Verbal');

INSERT INTO model_group (id_model, id, id_parent, sequence_number, ref) VALUES (1, 2, 1, 1, 'OF');
INSERT INTO model_group_lang (id_model_group, id_lang, name) VALUES (2, 1, 'Função do Contacto Visual');

INSERT INTO model_question (id, id_model_group, ref) VALUES (1, 2, 'O1');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (1, 1, 'Olha para ter as suas necessidades atendidas', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (2, 2, 'O2');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (2, 1, 'Olha para os outros para iniciar ou continuar uma interação', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (3, 2, 'O3');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (3, 1, 'Olha para chamar atenção para objetos ou acontecimentos do seu interesse', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (4, 2, 'O4');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (4, 1, 'Olha para manter a atenção dos outros', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (5, 2, 'O5');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (5, 1, 'Olha para avaliar os sinais sociais oferecidos pelos outros', '');

INSERT INTO model_group (id_model, id, id_parent, sequence_number, ref) VALUES (1, 3, 1, 1, 'OE');
INSERT INTO model_group_lang (id_model_group, id_lang, name) VALUES (3, 1, 'Expressões Partilhadas');

INSERT INTO model_question (id, id_model_group, ref) VALUES (6, 3, 'O6');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (6, 1, 'Olha com breves episódios de expressão facial', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (7, 3, 'O7');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (7, 1, 'Sorri ou dá gargalhadas durante uma interação', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (8, 3, 'O8');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (8, 1, 'Imita algumas expressões faciais simples e exageradas', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (9, 3, 'O9');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (9, 1, 'Demostra uma variedade de expressões faciais de forma espontânea', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (10, 3, 'O10');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (10, 1, 'Responde adequadamente às expressões faciais dos outros', '');

INSERT INTO model_group (id_model, id, id_parent, sequence_number, ref) VALUES (1, 4, 1, 1, 'OC');
INSERT INTO model_group_lang (id_model_group, id_lang, name) VALUES (4, 1, 'Comunicação Não-Verbal');

INSERT INTO model_question (id, id_model_group, ref) VALUES (11, 4, 'O11');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (11, 1, 'Responde quando chamado pelo nome', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (12, 4, 'O12');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (12, 1, 'Olha para pessoas e animais', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (13, 4, 'O13');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (13, 1, 'Move os outros de forma física para conseguir o que quer', '');

INSERT INTO model_group (id_model, id, id_parent, sequence_number, ref) VALUES (1, 5, 1, 1, 'O14');
INSERT INTO model_group_lang (id_model_group, id_lang, name) VALUES (5, 1, 'Aponta');

INSERT INTO model_question (id, id_model_group, ref) VALUES (15, 5, 'O15');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (15, 1, 'Faz gestos simples quando solicitada', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (16, 5, 'O16');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (16, 1, 'Faz gestos simples de forma espontânea', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (17, 5, 'O17');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (17, 1, 'Utiliza gestos espontâneos para enfatizar a comunicação verbal', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (18, 5, 'O18');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (18, 1, 'Compreende, utiliza e responde a sinais sociais básicos', '');


INSERT INTO model_group (id_model, id, id_parent, sequence_number, ref) VALUES (1, 6, NULL, 1, 'V');
INSERT INTO model_group_lang (id_model_group, id_lang, name) VALUES (6, 1, 'Comunicação Verbal');

INSERT INTO model_group (id_model, id, id_parent, sequence_number, ref) VALUES (1, 7, 6, 1, 'VV');
INSERT INTO model_group_lang (id_model_group, id_lang, name) VALUES (7, 1, 'Vocabulário/ Conteúdo');

INSERT INTO model_question (id, id_model_group, ref) VALUES (19, 7, 'V1');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (19, 1, 'Faz lalações ou vocalizações com significado', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (20, 7, 'V2');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (20, 1, 'Até 50 palavras isoladas', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (21, 7, 'V3');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (21, 1, 'Frases simples com 2 palavras (ir casa; não quero)', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (22, 7, 'V4');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (22, 1, 'Frases simples com 3 palavras (quero mais água)', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (23, 7, 'V5');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (23, 1, 'Frases complexas, gramaticamente corretas', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (24, 7, 'V6');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (24, 1, 'Frases complexas adequadas para a idade', '');

INSERT INTO model_group (id_model, id, id_parent, sequence_number, ref) VALUES (1, 8, 6, 1, 'VC');
INSERT INTO model_group_lang (id_model_group, id_lang, name) VALUES (8, 1, 'Clareza');

INSERT INTO model_question (id, id_model_group, ref) VALUES (25, 8, 'V7');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (25, 1, 'Parcialmente clara', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (26, 8, 'V8');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (26, 1, 'Geralmente clara', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (27, 8, 'V9');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (27, 1, 'Constantemente clara', '');

INSERT INTO model_group (id_model, id, id_parent, sequence_number, ref) VALUES (1, 9, 6, 1, 'VCO');
INSERT INTO model_group_lang (id_model_group, id_lang, name) VALUES (9, 1, 'Ciclos de Conversação');

INSERT INTO model_question (id, id_model_group, ref) VALUES (28, 9, 'V10');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (28, 1, 'Mais de 2 ciclos', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (29, 9, 'V11');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (29, 1, 'Respeita ciclos de conversação', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (30, 9, 'V12');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (30, 1, 'Inicia dialogos', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (31, 9, 'V13');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (31, 1, 'Mantém tópico conversa', '');

INSERT INTO model_group (id_model, id, id_parent, sequence_number, ref) VALUES (1, 10, 6, 1, 'VCC');
INSERT INTO model_group_lang (id_model_group, id_lang, name) VALUES (10, 1, 'Conteúdo da Conversa');

INSERT INTO model_question (id, id_model_group, ref) VALUES (32, 10, 'V14');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (32, 1, 'Comunica o que quer ou não quer de forma espontânea', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (33, 10, 'V15');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (33, 1, 'Faz comentários simples', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (34, 10, 'V16');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (34, 1, 'Faz/responde a perguntas simples', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (35, 10, 'V17');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (35, 1, 'Utiliza expressões esteriotipadas e/ou ecolália', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (36, 10, 'V18');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (36, 1, 'Constrói frases originais de forma espontânea', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (37, 10, 'V19');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (37, 1, 'Faz comentários complexos', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (38, 10, 'V20');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (38, 1, 'Faz/responde a perguntas complexas', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (39, 10, 'V21');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (39, 1, 'Explica o que quer clararamente', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (40, 10, 'V22');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (40, 1, 'Faz comentários e perguntas refletidas, relacionadas ao contexto', '');

INSERT INTO model_group (id_model, id, id_parent, sequence_number, ref) VALUES (1, 11, 6, 1, 'VFC');
INSERT INTO model_group_lang (id_model_group, id_lang, name) VALUES (11, 1, 'Função da Comunicação Verbal');

INSERT INTO model_question (id, id_model_group, ref) VALUES (41, 11, 'V23');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (41, 1, 'Para ter as necessidades atendidas', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (42, 11, 'V24');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (42, 1, 'Para iniciar ou continuar uma interação', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (43, 11, 'V25');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (43, 1, 'Para partilhar uma experiência', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (44, 11, 'V26');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (44, 1, 'Para partilhar histórias relevantes à conversa', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (45, 11, 'V27');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (45, 1, 'Para procurar informações pessoais de outros, dentro da conversa', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (46, 11, 'V28');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (46, 1, 'Para descobrir sobre as experiências internas de outros (pensamentos e sentimentos)', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (47, 11, 'V29');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (47, 1, 'Para partilhar as suas experiências internas (pensamentos e sentimentos)', '');


INSERT INTO model_group (id_model, id, id_parent, sequence_number, ref) VALUES (1, 12, NULL, 1, 'A');
INSERT INTO model_group_lang (id_model_group, id_lang, name) VALUES (12, 1, 'Periodo de Atenção Conjunta');

INSERT INTO model_group (id_model, id, id_parent, sequence_number, ref) VALUES (1, 13, 12, 1, 'AD');
INSERT INTO model_group_lang (id_model_group, id_lang, name) VALUES (13, 1, 'Duração');

INSERT INTO model_question (id, id_model_group, ref) VALUES (48, 13, 'A1');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (48, 1, 'Até 2 minutos', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (49, 13, 'A2');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (49, 1, '3-4 minutos ou mais', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (50, 13, 'A3');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (50, 1, '5-9 minutos', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (51, 13, 'A4');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (51, 1, '10-20 minutos', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (52, 13, 'A5');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (52, 1, 'Duração adequada para a idade (3 a 5 minutos multiplicados pela idade da criança)', '');

INSERT INTO model_group (id_model, id, id_parent, sequence_number, ref) VALUES (1, 14, 12, 1, 'AF');
INSERT INTO model_group_lang (id_model_group, id_lang, name) VALUES (14, 1, 'Frequência');

INSERT INTO model_question (id, id_model_group, ref) VALUES (53, 14, 'A6');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (53, 1, 'Prefere ser deixado sozinho', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (54, 14, 'A7');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (54, 1, 'Até 3 vezes por hora', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (55, 14, 'A8');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (55, 1, '4 vezes por hora', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (56, 14, 'A9');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (56, 1, '5 vezes por hora ou mais', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (57, 14, 'A10');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (57, 1, 'Até 5 vezes por hora ou mais (duração de 10 minutos ou mais)', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (58, 14, 'A11');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (58, 1, 'Continuamente interativa', '');

INSERT INTO model_group (id_model, id, id_parent, sequence_number, ref) VALUES (1, 15, 12, 1, 'AT');
INSERT INTO model_group_lang (id_model_group, id_lang, name) VALUES (15, 1, 'Tipo de Atividade');

INSERT INTO model_question (id, id_model_group, ref) VALUES (59, 15, 'A12');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (59, 1, 'Dá atenção quando lhe fala mesmo sem dizer o seu nome', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (60, 15, 'A13');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (60, 1, 'Interage em atividades físicas', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (61, 15, 'A14');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (61, 1, 'Interage com uma pessoa em atividades simples que incluem objetos', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (62, 15, 'A15');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (62, 1, 'Interage em brincadeiras simbólicas (que utilizem imaginação)', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (63, 15, 'A16');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (63, 1, 'Interage em atividades que utilizem imaginação para representar papéis', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (64, 15, 'A17');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (64, 1, 'Olha para o que os outros estão a olhar', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (65, 15, 'A18');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (65, 1, 'Entende instruções simples', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (66, 15, 'A19');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (66, 1, 'Compreende explicações', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (67, 15, 'A20');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (67, 1, 'Brinca com brinquedos de forma apropriada', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (68, 15, 'A21');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (68, 1, 'Interage em diversos tipos de atividades', '');

INSERT INTO model_group (id_model, id, id_parent, sequence_number, ref) VALUES (1, 16, 12, 1, 'AA');
INSERT INTO model_group_lang (id_model_group, id_lang, name) VALUES (16, 1, 'Amizades com Colegas');

INSERT INTO model_question (id, id_model_group, ref) VALUES (69, 16, 'A22');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (69, 1, 'Demonstra interesse pelos colegas', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (70, 16, 'A23');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (70, 1, 'Brinca ao lado de colegas, demonstrando interesse, mas sem interagir com eles', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (71, 16, 'A24');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (71, 1, 'Interações simples com colegas', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (72, 16, 'A25');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (72, 1, 'Interage com um colega de forma apropriada', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (73, 16, 'A26');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (73, 1, 'Interage com pequenos grupos de colegas de forma apropriada', '');


INSERT INTO model_group (id_model, id, id_parent, sequence_number, ref) VALUES (1, 17, NULL, 1, 'F');
INSERT INTO model_group_lang (id_model_group, id_lang, name) VALUES (17, 1, 'Flexibilidade');

INSERT INTO model_group (id_model, id, id_parent, sequence_number, ref) VALUES (1, 18, 17, 1, 'FF');
INSERT INTO model_group_lang (id_model_group, id_lang, name) VALUES (18, 1, 'Flexibilidade');

INSERT INTO model_question (id, id_model_group, ref) VALUES (74, 18, 'F1');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (74, 1, 'Permite que o ajudem dentro das atividades interativas rígidas/ repetitivas escolhidas por ela', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (75, 18, 'F2');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (75, 1, 'Permite variações periféricas nas atividades interativas rígidas/ repetitivas escolhidas por ela', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (76, 18, 'F3');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (76, 1, 'Participa fisicamente na interação', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (77, 18, 'F4');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (77, 1, 'Participa verbalmente na interação', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (78, 18, 'F5');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (78, 1, 'Permite variações centrais nas atividades interativas rígidas/ repetitivas escolhidas por ela', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (79, 18, 'F6');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (79, 1, 'Demonstra interesse pelas atividades dos outros', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (80, 18, 'F7');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (80, 1, 'Flexível dentro da atividade escolhida por ela', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (81, 18, 'F8');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (81, 1, 'Permite variações dentro da atividade escolhida por outro', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (82, 18, 'F9');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (82, 1, 'Divide tempo interativo entre a sua atividade e a atividade do outro', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (83, 18, 'F10');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (83, 1, 'Flexível dentro de diversos tipos de atividades', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (84, 18, 'F11');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (84, 1, 'Espontânea dentro de diversos tipos de atividades', '');

INSERT INTO model_group (id_model, id, id_parent, sequence_number, ref) VALUES (1, 19, 17, 1, 'FL');
INSERT INTO model_group_lang (id_model_group, id_lang, name) VALUES (19, 1, 'Lidando com Estímulos Sensoriais');

INSERT INTO model_question (id, id_model_group, ref) VALUES (85, 19, 'F12');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (85, 1, 'Responde calmamente em ambientes que oferecem alto grau de suporte', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (86, 19, 'F13');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (86, 1, 'Lida fácil e calmamente com limites impostos dentro de um ambiente com alto grau de suporte', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (87, 19, 'F14');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (87, 1, 'Interage facilmente num ambiente com grau médio de suporte', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (88, 19, 'F15');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (88, 1, 'Com ajuda, consegue lidar com a exposição a diferentes estímulos sensoriais, em ambientes típicos e apropriados para a idade', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (89, 19, 'F16');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (89, 1, 'Lida fácil e calmamente com quase todas as transições para novos ambiente e situações não estruturados', '');



INSERT INTO model_group (id_model, id, id_parent, sequence_number, ref) VALUES (1, 20, NULL, 1, 'C');
INSERT INTO model_group_lang (id_model_group, id_lang, name) VALUES (20, 1, 'Comportamento - é um problema?');

INSERT INTO model_question (id, id_model_group, ref) VALUES (90, 20, 'C1');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (90, 1, 'Tem noção do perigo', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (91, 20, 'C2');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (91, 1, 'Faz birras', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (92, 20, 'C3');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (92, 1, 'Autoagride-se', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (93, 20, 'C4');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (93, 1, 'Agride outros', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (94, 20, 'C5');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (94, 1, 'Fixação em determinados objectos', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (95, 20, 'C6');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (95, 1, 'Insensivel à dor', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (96, 20, 'C7');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (96, 1, 'Sensível sons', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (97, 20, 'C8');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (97, 1, 'Movimentos repetitivos/estereotipias', '');


INSERT INTO model_group (id_model, id, id_parent, sequence_number, ref) VALUES (1, 21, NULL, 1, 'H');
INSERT INTO model_group_lang (id_model_group, id_lang, name) VALUES (21, 1, 'Saúde - é um problema?');

INSERT INTO model_question (id, id_model_group, ref) VALUES (98, 21, 'H1');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (98, 1, 'Selectivo na alimentação', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (99, 21, 'H2');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (99, 1, 'Diarreia', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (100, 21, 'H3');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (100, 1, 'Obstipação', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (101, 21, 'H4');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (101, 1, 'Convulções', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (102, 21, 'H5');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (102, 1, 'Controle esfincters', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (103, 21, 'H6');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (103, 1, 'Rotinas rigidas', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (104, 21, 'H7');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (104, 1, 'Hiperactivo', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (105, 21, 'H8');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (105, 1, 'Alterações sono', '');
