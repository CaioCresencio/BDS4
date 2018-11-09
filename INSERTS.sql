-- CATEGORIA LITERARIA
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

-- OBRA

INSERT INTO obra_literaria
(id_obra,isbn,qtd_exemplares,nrm_edicao,data_publicacao,editora,titulo_obra,categoria_obra)
VALUES(seq_obraLiteraria.nextval,'123ACD',5,1,'25-05-2003','Sabugosa','Java como Programar',1);

INSERT INTO obra_literaria
(id_obra,isbn,qtd_exemplares,nrm_edicao,data_publicacao,editora,titulo_obra,categoria_obra)
VALUES(seq_obraLiteraria.nextval,'321DCA',3,3,'20-09-2001','Sabugosa NEW','PHP como sofrer',1);
