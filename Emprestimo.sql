CREATE OR REPLACE PROCEDURE emprestimo_procedure(
    prontuario_leitor INT,
    prontuario_funcionario INT,
    cod_exemplar INT
)

IS
    CURSOR cursor_leitor IS
        SELECT id_leitor, status, tempo_emprestimo
        FROM leitor
        JOIN categoria_leitor
        USING(codigo_categoria)
        WHERE prontuario = prontuario_leitor;
    
    aux_leitor cursor_leitor%ROWTYPE;
    
    CURSOR cursor_reserva IS
        SELECT codigo_reserva, data_reserva, prontuario_func
        FROM reserva
        WHERE id_leitor =  (SELECT id_leitor
                            FROM leitor
                            WHERE prontuario = prontuario_leitor)
        AND codigo_exemplar = cod_exemplar
        AND status = 'EM ABERTO';
    
    aux_reserva cursor_reserva%ROWTYPE;
    
    leitor_erro EXCEPTION;
    leitor_bloaqueado EXCEPTION;
    exemplar_erro EXCEPTION;
    funcionario_erro EXCEPTION;
    reservado_por_outro EXCEPTION;
    exemplar_emprestado EXCEPTION;
    
    retorno_exm varchar2(30);
    datadev date;
    
BEGIN
    COMMIT;
    OPEN cursor_leitor;
    
    FETCH cursor_leitor into aux_leitor;
    
    IF cursor_leitor%NOTFOUND THEN
        RAISE leitor_erro;
    ELSIF aux_leitor.status = 'Bloqueado' THEN
        RAISE leitor_bloaqueado;
    END IF;
    
    retorno_exm := status_exemplar(cod_exemplar);
    
    IF retorno_exm = 'EMPRESTADO' THEN
        RAISE exemplar_emprestado;
    ELSIF retorno_exm = 'INVALIDO' THEN
        RAISE exemplar_erro;
    ELSIF retorno_exm = 'RESERVADO' THEN
        OPEN cursor_reserva;
        FETCH cursor_reserva INTO aux_reserva;
            IF cursor_reserva%NOTFOUND THEN
                RAISE reservado_por_outro;
            ELSE
                UPDATE reserva
                SET status = 'CONCLUIDA'
                WHERE codigo_reserva = aux_reserva.codigo_reserva;
            END IF;
    END IF;
    
    if not existe_funcionario(prontuario_funcionario) then
        RAISE funcionario_erro;
    END IF;
    
    datadev := SYSDATE + aux_leitor.tempo_emprestimo;
    
    INSERT INTO emprestimo values (seq_emprestimo.nextval, datadev, SYSDATE, 'EM ANDAMENTO',cod_exemplar, aux_leitor.id_leitor, prontuario_funcionario);
    DBMS_OUTPUT.PUT_LINE('Emprestado com sucesso!');
    
    UPDATE exemplar
    SET status = 'EMPRESTADO'
    WHERE codigo_exemplar = cod_exemplar;
    
    CLOSE cursor_leitor;

EXCEPTION
    WHEN leitor_erro THEN
        DBMS_OUTPUT.PUT_LINE('Nenhum leitor encontrado com o prontuario: '|| prontuario_leitor);
    WHEN leitor_bloaqueado THEN
        DBMS_OUTPUT.PUT_LINE('Leitor esta bloqueado!');
    WHEN exemplar_erro THEN
        DBMS_OUTPUT.PUT_LINE('Nenhum exemplar foi encontrado. Condigo invalido');
    WHEN exemplar_emprestado THEN
        DBMS_OUTPUT.PUT_LINE('Exemplar já esta emprestado! Tente outro exemplar.');
    WHEN funcionario_erro THEN
        DBMS_OUTPUT.PUT_LINE('Nenhum funcionario encontrado com o prontuario: '|| prontuario_funcionario);
    WHEN reservado_por_outro THEN
        DBMS_OUTPUT.PUT_LINE('Exemplar reservado por outro leitor!');
END;
/
        
CREATE OR REPLACE FUNCTION status_exemplar(
    cod_exemplar INT
)
RETURN VARCHAR2
IS
    retorno VARCHAR2(30);
BEGIN

    SELECT status INTO retorno
    FROM exemplar WHERE codigo_exemplar = cod_exemplar;

    RETURN retorno;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'INVALIDO'; 
END;
/

CREATE OR REPLACE FUNCTION existe_funcionario(
    pront_func INT
)
RETURN boolean
IS
    teste int;
BEGIN

    SELECT prontuario_func into teste
    FROM funcionario WHERE prontuario_func = pront_func;

    RETURN true;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN false; 
END;
/
BEGIN
    emprestimo_procedure(1710052, 1, 5);
END;
/


SELECT * FROM LEITOR;
SELECT * FROM FUNCIONARIO;
select * from emprestimo;
select * from exemplar;
select * from reserva;

insert into reserva values(seq_reserva.nextval, SYSDATE,'EM ABERTO', 5, 2, 2);
UPDATE exemplar
    SET status = 'RESERVADO'
    WHERE codigo_exemplar = 5;

set SERVEROUTPUT on;