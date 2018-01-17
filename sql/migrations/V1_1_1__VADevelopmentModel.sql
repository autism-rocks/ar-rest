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
  scale VARCHAR(20),
  ref VARCHAR(25),
  CONSTRAINT model_group_parent_id_fk FOREIGN KEY (id_parent) REFERENCES model_group (id),
  CONSTRAINT model_id_model_fk FOREIGN KEY (id_model) REFERENCES model (id)
);

CREATE TABLE model_group_lang
(
  id_model_group INT NOT NULL,
  id_lang INT NOT NULL,
  name VARCHAR(255),
  description VARCHAR(255),
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




INSERT INTO model_group (id_model, id, id_parent, sequence_number, ref, scale) VALUES (1, 1, null, 1, 'O', null);
INSERT INTO model_group_lang (id_model_group, id_lang, name, description) VALUES (1, 1, 'Contacto Visual e Comunicação Não-Verbal', '');


INSERT INTO model_group (id_model, id, id_parent, sequence_number, ref, scale) VALUES (1, 2, 1, 1, 'OF', 'frequency');
INSERT INTO model_group_lang (id_model_group, id_lang, name, description) VALUES (2, 1, 'Função do Contacto Visual', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (3, 2, 'OF1');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (3, 1, 'Olha para os outros para iniciar ou continuar uma interação', 'Quando paramos de falar , a criança olha para nós para iniciar ou continuar uma actividade');
INSERT INTO model_question (id, id_model_group, ref) VALUES (4, 2, 'OF2');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (4, 1, 'Olha para ter as suas necessidades atendidas', 'Para ter comida, água, para ter o seu objecto preferido');
INSERT INTO model_question (id, id_model_group, ref) VALUES (5, 2, 'OF3');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (5, 1, 'Olha para chamar atenção para objetos ou acontecimentos do seu interesse', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (6, 2, 'OF4');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (6, 1, 'Olha enquanto fala ', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (7, 2, 'OF5');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (7, 1, 'Olha para avaliar os sinais sociais oferecidos pelos outros', '');


INSERT INTO model_group (id_model, id, id_parent, sequence_number, ref, scale) VALUES (1, 8, 1, 1, 'OE', 'frequency');
INSERT INTO model_group_lang (id_model_group, id_lang, name, description) VALUES (8, 1, 'Expressões Partilhadas', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (9, 8, 'OE1');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (9, 1, 'Olha com breves episódios de expressão facial', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (10, 8, 'OE2');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (10, 1, 'Sorri ou dá gargalhadas durante uma interação', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (11, 8, 'OE3');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (11, 1, 'Imita algumas expressões faciais simples e exageradas.', 'Ex: cara triste, cara feliz');
INSERT INTO model_question (id, id_model_group, ref) VALUES (12, 8, 'OE4');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (12, 1, 'Demostra uma variedade de expressões faciais de forma espontânea', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (13, 8, 'OE5');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (13, 1, 'Responde adequadamente às expressões faciais dos outros', '');


INSERT INTO model_group (id_model, id, id_parent, sequence_number, ref, scale) VALUES (1, 14, 1, 1, 'ON', 'frequency');
INSERT INTO model_group_lang (id_model_group, id_lang, name, description) VALUES (14, 1, 'Comunicação Não-Verbal', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (15, 14, 'ON1');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (15, 1, 'Responde quando chamado pelo nome', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (16, 14, 'ON2');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (16, 1, 'Move os outros de forma física para conseguir o que quer', 'Empurra quando quer algo, dá á mão, etc');
INSERT INTO model_question (id, id_model_group, ref) VALUES (17, 14, 'ON3');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (17, 1, 'Aponta', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (18, 14, 'ON4');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (18, 1, 'Olha para pessoas e animais', 'Ex: quando alguem está a cantar; a falar sobre um tópico de interesse, etc');
INSERT INTO model_question (id, id_model_group, ref) VALUES (19, 14, 'ON5');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (19, 1, 'Faz gestos simples quando solicitada', 'Bate palmas, abana a cabeça para sim e não, diz adeus, põem a mão na boca para shiuuu');
INSERT INTO model_question (id, id_model_group, ref) VALUES (20, 14, 'ON6');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (20, 1, 'Faz gestos simples de forma espontânea', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (21, 14, 'ON7');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (21, 1, 'Utiliza gestos espontâneos para enfatizar a comunicação verbal', 'Ex: cruza braços, gesticula');
INSERT INTO model_question (id, id_model_group, ref) VALUES (22, 14, 'ON8');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (22, 1, 'Compreende, utiliza e responde a sinais sociais básicos', 'Ex: se a criança esta a falar com alguem e essa pessoa não está a olhar para ela, a criança compreende');


INSERT INTO model_group (id_model, id, id_parent, sequence_number, ref, scale) VALUES (1, 23, null, 1, 'A', null);
INSERT INTO model_group_lang (id_model_group, id_lang, name, description) VALUES (23, 1, 'Tempo de Atenção Conjunta', '');


INSERT INTO model_group (id_model, id, id_parent, sequence_number, ref, scale) VALUES (1, 24, 23, 1, 'AD', 'frequency');
INSERT INTO model_group_lang (id_model_group, id_lang, name, description) VALUES (24, 1, 'Duração', 'Inclui outra pessoa num jogo ou actividade. O TAC termina quando a criança deixa de interagir e não volta após dois pedidos para continuar a actividade');
INSERT INTO model_question (id, id_model_group, ref) VALUES (25, 24, 'AD1');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (25, 1, 'Até 2 minutos', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (26, 24, 'AD2');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (26, 1, '3-4 minutos ou mais', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (27, 24, 'AD3');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (27, 1, '5-9 minutos', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (28, 24, 'AD4');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (28, 1, '10-20 minutos', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (29, 24, 'AD5');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (29, 1, 'Duração adequada para a idade (3 a 5 minutos multiplicados pela idade da criança)', '');


INSERT INTO model_group (id_model, id, id_parent, sequence_number, ref, scale) VALUES (1, 30, 23, 1, 'AF', 'frequency');
INSERT INTO model_group_lang (id_model_group, id_lang, name, description) VALUES (30, 1, 'Frequência', 'Numero de vezes por hora que a criança interage consigo independentemente da duração da interação');
INSERT INTO model_question (id, id_model_group, ref) VALUES (31, 30, 'AF1');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (31, 1, 'Até 3 vezes por hora', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (32, 30, 'AF2');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (32, 1, '4 vezes por hora', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (33, 30, 'AF3');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (33, 1, '5 vezes por hora ou mais', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (34, 30, 'AF4');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (34, 1, 'Até 5 vezes por hora ou mais (duração de 10 minutos ou mais)', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (35, 30, 'AF5');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (35, 1, 'Continuamente interativa', '');


INSERT INTO model_group (id_model, id, id_parent, sequence_number, ref, scale) VALUES (1, 36, 23, 1, 'AA', 'frequency');
INSERT INTO model_group_lang (id_model_group, id_lang, name, description) VALUES (36, 1, 'Tipo de Atividade', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (37, 36, 'AA1');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (37, 1, 'Dá atenção quando lhe fala mesmo sem dizer o seu nome', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (38, 36, 'AA2');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (38, 1, 'Interage em atividades físicas', 'Pode incluir: cocegas, apanhadas, massagens...etc');
INSERT INTO model_question (id, id_model_group, ref) VALUES (39, 36, 'AA3');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (39, 1, 'Interage com uma pessoa em atividades simples que incluem objetos', 'Bolas, carros, legos...etc');
INSERT INTO model_question (id, id_model_group, ref) VALUES (40, 36, 'AA4');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (40, 1, 'Brinca com brinquedos de forma apropriada', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (41, 36, 'AA5');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (41, 1, 'Interage em brincadeiras simbólicas (que utilizem imaginação)', 'Um bloco de lego que pode ser um carro, um cobertor que pode ser um tapete voador, etc');
INSERT INTO model_question (id, id_model_group, ref) VALUES (42, 36, 'AA6');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (42, 1, 'Entende instruções simples', 'Ex: vai buscar os teus sapatos, fecha a porta, traz o carro azul');
INSERT INTO model_question (id, id_model_group, ref) VALUES (43, 36, 'AA7');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (43, 1, 'Interage em atividades que utilizem imaginação para representar papéis', 'Faz de conta que é um animal, uma personagem do seu filme favorito, imagina que é um super herois e que consegue voar, etc');
INSERT INTO model_question (id, id_model_group, ref) VALUES (44, 36, 'AA8');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (44, 1, 'Olha para o que os outros estão a olha', 'Consegue olhar quando lhe dizemos "olha para aquele cão que vai do outro lado da rua, olha o avião ali no céu..etc');
INSERT INTO model_question (id, id_model_group, ref) VALUES (45, 36, 'AA9');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (45, 1, 'Compreende explicações', 'Entende e aceita explicações quando surge alguma situação ou quando algo é alterado- Ex: hoje não vais ao parque porque estás doente e não quero que fiques pior');
INSERT INTO model_question (id, id_model_group, ref) VALUES (46, 36, 'AA10');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (46, 1, 'Interage em diversos tipos de atividades', 'Interage em actividades fisicas, conversação, imaginativas, etc');


INSERT INTO model_group (id_model, id, id_parent, sequence_number, ref, scale) VALUES (1, 47, 23, 1, 'AC', 'frequency');
INSERT INTO model_group_lang (id_model_group, id_lang, name, description) VALUES (47, 1, 'Amizades com Colegas', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (48, 47, 'AC1');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (48, 1, 'Demonstra interesse pelos colegas', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (49, 47, 'AC2');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (49, 1, 'Brinca ao lado de colegas, demonstrando interesse, mas sem interagir com eles', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (50, 47, 'AC3');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (50, 1, 'Interações simples com colegas', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (51, 47, 'AC4');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (51, 1, 'Interage com um colega de forma apropriada', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (52, 47, 'AC5');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (52, 1, 'Interage com pequenos grupos de colegas de forma apropriada', 'Dá a vez, negoceia, permite que outras crianças participem');


INSERT INTO model_group (id_model, id, id_parent, sequence_number, ref, scale) VALUES (1, 53, null, 1, 'V', null);
INSERT INTO model_group_lang (id_model_group, id_lang, name, description) VALUES (53, 1, 'Comunicação Verbal', '');


INSERT INTO model_group (id_model, id, id_parent, sequence_number, ref, scale) VALUES (1, 54, 53, 1, 'VV', 'frequency');
INSERT INTO model_group_lang (id_model_group, id_lang, name, description) VALUES (54, 1, 'Vocabulário/ Conteúdo', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (55, 54, 'VV1');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (55, 1, 'Faz sons ou aproximações a palavras', 'Ex: "aba" para água, "bo"para bola, ');
INSERT INTO model_question (id, id_model_group, ref) VALUES (56, 54, 'VV2');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (56, 1, 'Diz 5 palavras ou mais', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (57, 54, 'VV3');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (57, 1, 'Tem vocabulário de 50 palavras ou mais', 'Água, bola, carro, comer, bolacha, etc');
INSERT INTO model_question (id, id_model_group, ref) VALUES (58, 54, 'VV4');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (58, 1, 'Frases simples com 2 palavras', 'Ex: ir casa; não quero');
INSERT INTO model_question (id, id_model_group, ref) VALUES (59, 54, 'VV5');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (59, 1, 'Frases simples com 3 ou mais palavras', 'Ex: quero mais água');
INSERT INTO model_question (id, id_model_group, ref) VALUES (60, 54, 'VV6');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (60, 1, 'Frases complexas, gramaticamente corretas', 'Ex:Guarda as cartas que agora quero fazer um puzzle');
INSERT INTO model_question (id, id_model_group, ref) VALUES (61, 54, 'VV7');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (61, 1, 'Frases complexas adequadas para a idade', '');


INSERT INTO model_group (id_model, id, id_parent, sequence_number, ref, scale) VALUES (1, 62, 53, 1, 'VT', 'frequency');
INSERT INTO model_group_lang (id_model_group, id_lang, name, description) VALUES (62, 1, 'Clareza', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (63, 62, 'VT1');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (63, 1, 'Parcialmente clara', 'Pode entender o que a criança diz mas outras pessoas não');
INSERT INTO model_question (id, id_model_group, ref) VALUES (64, 62, 'VT2');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (64, 1, 'Geralmente clara -linguagem é entendivel por muitas pessoas', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (65, 62, 'VT3');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (65, 1, 'Constantemente Clara', '');


INSERT INTO model_group (id_model, id, id_parent, sequence_number, ref, scale) VALUES (1, 66, 53, 1, 'VC', 'frequency');
INSERT INTO model_group_lang (id_model_group, id_lang, name, description) VALUES (66, 1, 'Ciclos de Conversação', 'Ex: "Cuidador: "Queres desenhar?" <br /> Criança: yehh! desenhar carro <br /> ( 1 ciclo de conversação) <br /> Cuidador: "Ok! Vou pintar de azul" <br /> Criança: "eu pinto de vermelho" <br /> ( 2 ciclos de conversação)');
INSERT INTO model_question (id, id_model_group, ref) VALUES (67, 66, 'VC1');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (67, 1, 'Mais de 2 ciclos', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (68, 66, 'VC2');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (68, 1, 'Respeita ciclos de conversação', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (69, 66, 'VC3');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (69, 1, 'Inicia dialogos', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (70, 66, 'VC4');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (70, 1, 'Mantém tópico conversa', '');


INSERT INTO model_group (id_model, id, id_parent, sequence_number, ref, scale) VALUES (1, 71, 53, 1, 'VM', 'frequency');
INSERT INTO model_group_lang (id_model_group, id_lang, name, description) VALUES (71, 1, 'Conteúdo da Conversa', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (72, 71, 'VM1');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (72, 1, 'Comunica o que quer ou não quer de forma espontânea', 'Sem que lhe seja solicitado consegue comunicar o que quer ou o que não quer. Por ex: carro vermelho; comer não, etc');
INSERT INTO model_question (id, id_model_group, ref) VALUES (73, 71, 'VM2');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (73, 1, 'Faz comentários simples', 'Ex: olha o cão, gosto desta comida');
INSERT INTO model_question (id, id_model_group, ref) VALUES (74, 71, 'VM3');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (74, 1, 'Faz/responde a perguntas simples', 'Ex: como te chamas? Quem é aquele? Onde está o pai?');
INSERT INTO model_question (id, id_model_group, ref) VALUES (75, 71, 'VM4');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (75, 1, 'Constrói frases originais de forma espontânea', 'Ex: comunica de forma espontanea em vez de repetir frases feitas que ouvir na TV ou num video jogo');
INSERT INTO model_question (id, id_model_group, ref) VALUES (76, 71, 'VM5');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (76, 1, 'Faz comentários complexos', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (77, 71, 'VM6');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (77, 1, 'Explica o que quer clararamente', '');


INSERT INTO model_group (id_model, id, id_parent, sequence_number, ref, scale) VALUES (1, 78, 53, 1, 'VF', 'frequency');
INSERT INTO model_group_lang (id_model_group, id_lang, name, description) VALUES (78, 1, 'Função da Comunicação Verbal', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (79, 78, 'VF1');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (79, 1, 'Para ter as necessidades atendidas', 'Ex: comunica quando quer comer, para abrir uma porta, pede um brinquedo que não consegue chegar');
INSERT INTO model_question (id, id_model_group, ref) VALUES (80, 78, 'VF2');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (80, 1, 'Comunica verbalmente para iniciar ou continuar uma interação', 'Ex: durante uma interação usa linguagem para iniciar ou continuar interação; ex: mais cocegas; cantar musica, atira bola');
INSERT INTO model_question (id, id_model_group, ref) VALUES (81, 78, 'VF3');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (81, 1, 'Comunica para partilhar uma experiência', 'Observa e consegue partilhar experiencias com os outros. Ex: "A mana já chegou"; "olha a consctrução que fiz"');
INSERT INTO model_question (id, id_model_group, ref) VALUES (82, 78, 'VF4');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (82, 1, 'Comunica para partilhar histórias relevantes à conversa', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (83, 78, 'VF5');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (83, 1, 'Comunica para procurar informações pessoais de outros, dentro da conversa', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (84, 78, 'VF6');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (84, 1, 'Comunica para descobrir sobre as experiências internas de outros (pensamentos e sentimentos)', 'Ex: Papá, estás triste?; adoro ir ao parque!');
INSERT INTO model_question (id, id_model_group, ref) VALUES (85, 78, 'VF7');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (85, 1, 'Comunica para partilhar as suas experiências internas (pensamentos e sentimentos)', 'Ex: tenho medo; Estou muito feliz');


INSERT INTO model_group (id_model, id, id_parent, sequence_number, ref, scale) VALUES (1, 86, null, 1, 'F', null);
INSERT INTO model_group_lang (id_model_group, id_lang, name, description) VALUES (86, 1, 'Flexibilidade', '');


INSERT INTO model_group (id_model, id, id_parent, sequence_number, ref, scale) VALUES (1, 87, 86, 1, 'FF', 'confirmation');
INSERT INTO model_group_lang (id_model_group, id_lang, name, description) VALUES (87, 1, 'Flexibilidade', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (88, 87, 'FF1');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (88, 1, 'Permite que o ajudem dentro das atividades interativas rígidas/ repetitivas escolhidas por ele', 'Ex: Se está a construir uma torre permite que lhe chegue os blocos');
INSERT INTO model_question (id, id_model_group, ref) VALUES (89, 87, 'FF2');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (89, 1, 'Permite variações periféricas nas atividades interativas rígidas/ repetitivas escolhidas por ela', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (90, 87, 'FF3');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (90, 1, 'Participa fisicamente na interação', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (91, 87, 'FF4');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (91, 1, 'Participa verbalmente na interação', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (92, 87, 'FF5');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (92, 1, 'Permite variações centrais nas atividades interativas rígidas/ repetitivas escolhidas por ela', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (93, 87, 'FF6');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (93, 1, 'Demonstra interesse pelas atividades dos outros', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (94, 87, 'FF7');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (94, 1, 'Flexível dentro da atividade escolhida por ela', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (95, 87, 'FF8');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (95, 1, 'Permite variações dentro da atividade escolhida por outro', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (96, 87, 'FF9');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (96, 1, 'Divide tempo interativo entre a sua atividade e a atividade do outro', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (97, 87, 'FF10');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (97, 1, 'Flexível dentro de diversos tipos de atividades', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (98, 87, 'FF11');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (98, 1, 'Espontânea dentro de diversos tipos de atividades', '');


INSERT INTO model_group (id_model, id, id_parent, sequence_number, ref, scale) VALUES (1, 99, 86, 1, 'FE', 'confirmation');
INSERT INTO model_group_lang (id_model_group, id_lang, name, description) VALUES (99, 1, 'Lidando com Estímulos Sensoriais', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (100, 99, 'FE1');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (100, 1, 'Responde calmamente em ambientes que oferecem alto grau de suporte', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (101, 99, 'FE2');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (101, 1, 'Lida fácil e calmamente com limites impostos dentro de um ambiente com alto grau de suporte', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (102, 99, 'FE3');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (102, 1, 'Interage facilmente num ambiente com grau médio de suporte', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (103, 99, 'FE4');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (103, 1, 'Com ajuda, consegue lidar com a exposição a diferentes estímulos sensoriais, em ambientes típicos e apropriados para a idade', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (104, 99, 'FE5');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (104, 1, 'Lida fácil e calmamente com quase todas as transições para novos ambiente e situações não estruturados', '');


INSERT INTO model_group (id_model, id, id_parent, sequence_number, ref, scale) VALUES (1, 105, null, 1, 'S', 'problem');
INSERT INTO model_group_lang (id_model_group, id_lang, name, description) VALUES (105, 1, 'Saude', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (106, 105, 'S1');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (106, 1, 'Selectivo na alimentação', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (107, 105, 'S2');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (107, 1, 'Compulsivo na alimentação', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (108, 105, 'S3');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (108, 1, 'Diarreia', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (109, 105, 'S4');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (109, 1, 'Obstipação', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (110, 105, 'S5');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (110, 1, 'Convulções', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (111, 105, 'S6');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (111, 1, 'Controle esfincters', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (112, 105, 'S7');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (112, 1, 'Rotinas rigidas', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (113, 105, 'S8');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (113, 1, 'Hiperactivo', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (114, 105, 'S9');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (114, 1, 'Alterações sono', '');


INSERT INTO model_group (id_model, id, id_parent, sequence_number, ref, scale) VALUES (1, 115, null, 1, 'C', 'problem');
INSERT INTO model_group_lang (id_model_group, id_lang, name, description) VALUES (115, 1, 'Comportamento', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (116, 115, 'C1');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (116, 1, 'Tem noção do perigo', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (117, 115, 'C2');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (117, 1, 'Faz birras', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (118, 115, 'C3');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (118, 1, 'Autoagride-se', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (119, 115, 'C4');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (119, 1, 'Agride outros', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (120, 115, 'C5');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (120, 1, 'Fixação em determinados objectos', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (121, 115, 'C6');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (121, 1, 'Insensivel à dor', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (122, 115, 'C7');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (122, 1, 'Sensível sons', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (123, 115, 'C8');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (123, 1, 'Movimentos repetitivos/estereotipias', '');
INSERT INTO model_question (id, id_model_group, ref) VALUES (124, 115, 'C9');
INSERT INTO model_question_lang (id_model_question, id_lang, title, description) VALUES (124, 1, 'Utiliza expressões estereotipadas e/ou ecolália', '');
