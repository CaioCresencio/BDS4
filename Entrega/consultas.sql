-- Consulta 9
CREATE OR REPLACE VIEW obras_emprestadas AS
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
WHERE e.status = 'EM ANDAMENTO'
ORDER BY c.descricao ;

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
JOIN obra_literaria o 
USING (id_obra)
JOIN leitor l
USING (id_leitor)
WHERE r.status = 'FECHADA';


--12

SELECT o.titulo_obra, e.data_emp AS Data_Emprestimo, e.data_dev AS Data_Prevista, d.data_dev AS Data_Devolucao
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
SET SERVEROUTPUT ON;
DECLARE
    nome VARCHAR2(30);
    emprestados INT;
    total INT;
    reservado INT;
    disponivel INT;
BEGIN
    
    nome := 'Java como Programar';
    
    SELECT COUNT(e.status) INTO emprestados
    FROM obra_literaria o
    JOIN exemplar e1
    USING(id_obra)
    LEFT JOIN emprestimo e
    USING (codigo_exemplar)
    WHERE e.status = 'EM ANDAMENTO'
    GROUP BY (o.titulo_obra)
    HAVING o.titulo_obra = nome;
    
    SELECT COUNT(e.status) INTO total
    FROM obra_literaria o
    JOIN exemplar e
    USING(id_obra)
    GROUP BY (o.titulo_obra)
    HAVING o.titulo_obra = nome;
    
    SELECT COUNT(r.status) INTO reservado
    FROM obra_literaria o
    JOIN exemplar e
    USING(id_obra)
    JOIN reserva r
    USING (codigo_exemplar)
    GROUP BY (o.titulo_obra)
    HAVING o.titulo_obra = nome;
    
    disponivel := total - reservado - emprestados;    
    
    DBMS_OUTPUT.PUT_LINE('Obra: ' || nome ||' Total disponivel: ' || disponivel || ' Reservados: '
    || reservado ||' Emprestados: ' || emprestados ||' Total de exemplares: ' || total);
    
END;
/

