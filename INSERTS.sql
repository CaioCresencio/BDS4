
-- CATEGORIA LITERARIA

DELETE FROM categoria_literaria;

INSERT INTO categoria_literaria 
(codigo_categoria,descricao,tempo_emprestimo)
VALUES(seq_catLiteraria.nextval,'Livro',7);

INSERT INTO categoria_literaria 
(codigo_categoria,descricao,tempo_emprestimo)
VALUES(seq_catLiteraria.nextval,'Revista',5);

INSERT INTO categoria_literaria 
(codigo_categoria,descricao,tempo_emprestimo)
VALUES(seq_catLiteraria.nextval,'Jornal',10);

INSERT INTO categoria_literaria 
(codigo_categoria,descricao,tempo_emprestimo)
VALUES(seq_catLiteraria.nextval,'Relatório técnico',4);

INSERT INTO categoria_literaria 
(codigo_categoria,descricao,tempo_emprestimo)
VALUES(seq_catLiteraria.nextval,'Trabalho acadêmico',2);

SELECT * FROM categoria_literaria;
-- OBRA
DELETE obra_literaria;

INSERT INTO obra_literaria
(id_obra,isbn,qtd_exemplares,nrm_edicao,data_publicacao,editora,titulo_obra,codigo_categoria)
VALUES(seq_obraLiteraria.nextval,'123ACD',5,1,'25-05-2003','Sabugosa','Java como Programar',1);

INSERT INTO obra_literaria
(id_obra,isbn,qtd_exemplares,nrm_edicao,data_publicacao,editora,titulo_obra,codigo_categoria)
VALUES(seq_obraLiteraria.nextval,'321DCA',3,3,'20-09-2001','Sabugosa NEW','PHP como sofrer',1);

INSERT INTO obra_literaria
(id_obra,isbn,qtd_exemplares,nrm_edicao,data_publicacao,editora,titulo_obra,codigo_categoria)
VALUES(seq_obraLiteraria.nextval,'456DBA',2,5,'15-02-2012','Sabugosa NEW','C como sofrer, a revolta!',1);

INSERT INTO obra_literaria
(id_obra,isbn,qtd_exemplares,nrm_edicao,data_publicacao,editora,titulo_obra,codigo_categoria)
VALUES(seq_obraLiteraria.nextval,'333BBA',4,1,'21-10-2015','IFSP','Jogos educacionais',5);

SELECT * FROM obra_literaria;
SELECT * FROM exemplar;
--  Autores 
DELETE  FROM autor;

INSERT INTO autor (id_autor,nome) VALUES (seq_autor.nextval,'Geovaldo');
INSERT INTO autor (id_autor,nome) VALUES (seq_autor.nextval,'Aroudo');
INSERT INTO autor (id_autor,nome) VALUES (seq_autor.nextval,'Luperaldo');
INSERT INTO autor (id_autor,nome) VALUES (seq_autor.nextval,'Auvidor');
INSERT INTO autor (id_autor,nome) VALUES (seq_autor.nextval,'Chimbinha');

SELECT * FROM autor;
-- Lista autores
DELETE FROM lista_autores;

INSERT INTO lista_autores(id_autor,id_obra) VALUES(1,1);
INSERT INTO lista_autores(id_autor,id_obra) VALUES(3,1);
INSERT INTO lista_autores(id_autor,id_obra) VALUES(1,2);
INSERT INTO lista_autores(id_autor,id_obra) VALUES(2,2);
INSERT INTO lista_autores(id_autor,id_obra) VALUES(4,2);
INSERT INTO lista_autores(id_autor,id_obra) VALUES(1,3);
INSERT INTO lista_autores(id_autor,id_obra) VALUES(1,4);

SELECT * FROM lista_autores;
-- CATEGORIA LEITOR
DELETE FROM categoria_leitor;

INSERT INTO categoria_leitor (codigo_categoria,descricao,tempo_emprestimo)
VALUES (seq_categoriaLeitor.nextval,'Aluno de curso técnico',15);

INSERT INTO categoria_leitor (codigo_categoria,descricao,tempo_emprestimo)
VALUES (seq_categoriaLeitor.nextval,'Aluno de graduação',15);

INSERT INTO categoria_leitor (codigo_categoria,descricao,tempo_emprestimo)
VALUES (seq_categoriaLeitor.nextval,'Professor',30);

INSERT INTO categoria_leitor (codigo_categoria,descricao,tempo_emprestimo)
VALUES (seq_categoriaLeitor.nextval,'Funcionário',30);

INSERT INTO categoria_leitor (codigo_categoria,descricao,tempo_emprestimo)
VALUES (seq_categoriaLeitor.nextval,'Usuário externo',7);

SELECT * FROM categoria_leitor;

-- RG
INSERT INTO rg (id_rg,numero,estado) VALUES(seq_rg.nextval,1234,'SP');
INSERT INTO rg (id_rg,numero,estado) VALUES(seq_rg.nextval,2345,'SP');
INSERT INTO rg (id_rg,numero,estado) VALUES(seq_rg.nextval,3456,'SP');

-- Leitor

INSERT INTO leitor(id_leitor,nome,cidade,estado,telefone,prontuario,data_nascimento,email,status,id_rg,codigo_categoria)
VALUES (seq_leitor.nextval,'Caio','São Carlos','SP',123456,1710052,'29-06-1998','caio@gmail.com','DISPONIVEL',1,2);

INSERT INTO leitor(id_leitor,nome,cidade,estado,telefone,prontuario,data_nascimento,email,status,id_rg,codigo_categoria)
VALUES (seq_leitor.nextval,'Frodinho','São Carlos','SP',121256,1710125,'10-02-1999','frodinho@gmail.com','DISPONIVEL',2,2);

INSERT INTO leitor(id_leitor,nome,cidade,estado,telefone,prontuario,data_nascimento,email,status,id_rg,codigo_categoria)
VALUES (seq_leitor.nextval,'Diego','São Carlos','SP',42216,1710324,'05-02-1989','diego@gmail.com','DISPONIVEL',3,2);
SELECT * FROM leitor;


-- Funcionario 


INSERT INTO funcionario(prontuario_func,endereco,data_nascimento,telefone,nome)
VALUES (seq_func.nextval,'Paschoal de melo', '25-03-1987',12585,'Rupertson');

INSERT INTO funcionario(prontuario_func,endereco,data_nascimento,telefone,nome)
VALUES (seq_func.nextval,'Avenida dom pedro I', '15-05-1887',0000,'Lucas');


INSERT INTO funcionario(prontuario_func,endereco,data_nascimento,telefone,nome)
VALUES (seq_func.nextval,'Paschoal de melo 3', '22-01-1287',14445,'Geosvaldo');


INSERT INTO funcionario(prontuario_func,endereco,data_nascimento,telefone,nome)
VALUES (seq_func.nextval,'Paschoal de melo 2', '05-02-1687',12585,'Aclanildo');


INSERT INTO funcionario(prontuario_func,endereco,data_nascimento,telefone,nome)
VALUES (seq_func.nextval,'Esquina de frente', '06-06-1666',4444,'Mestre dos magos');