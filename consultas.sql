-- Consulta 9
CREATE VIEW obras_emprestadas AS
SELECT c.descricao, l.nome, o.titulo_obra, codigo_exemplar, e.data_emp, e.data_dev
FROM categoria_literaria c
JOIN obra_literaria o
USING (codigo_categoria)
JOIN  exemplar 
USING (id_obra)
JOIN emprestimo e
USING (codigo_exemplar)
JOIN leitor l
USING (id_leitor)
WHERE e.status = 'EM ANDAMENTO';

SELECT * FROM obras_emprestadas;

--10
SELECT l.nome, l.telefone,l.email, e.data_emp, e.data_dev
FROM emprestimo e
JOIN leitor l
USING (id_leitor)
WHERE e.status = 'EM ANDAMENTO'
AND data_dev < SYSDATE;
 
--11


SELECT l.nome, l.telefone, l.email, o.titulo_obra
FROM reserva r
JOIN exemplar 
USING (codigo_exemplar)
JOIN obra_literaria o 
USING (id_obra)
JOIN leitor l
USING (id_leitor)
WHERE r.status = 'EM ABERTO';


--12

SELECT o.titulo_obra, e.data_emp, e.data_dev, d.data_dev
FROM emprestimo e
JOIN exemplar
USING (codigo_exemplar)
JOIN obra_literaria o
USING (id_obra)
JOIN leitor l
USING (id_leitor)
LEFT JOIN devolucao d
USING (codigo_emp)
WHERE nome = 'Caio'
;

--13 

SELECT o.titulo_obra, COUNT(codigo_exemplar)
FROM obra_literaria o
JOIN exemplar e1
USING(id_obra)
JOIN emprestimo e
USING (codigo_exemplar)
WHERE e.status = 'EM ANDAMENTO'
GROUP BY (o.titulo_obra)
HAVING o.titulo_obra = 'Java como Programar'
;


select * from obra_literaria;
select * from exemplar;
SELECT * FROM emprestimo;