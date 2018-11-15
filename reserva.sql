SET SERVEROUTPUT ON;


-- Confere se o leitor está bloqueado ou não
CREATE OR REPLACE FUNCTION status_leitor(
    prontuario_l INT
)
RETURN VARCHAR2
IS
    retorno VARCHAR2(30);
BEGIN
    
    SELECT  status INTO retorno
    FROM leitor WHERE prontuario = prontuario_l;
    DBMS_OUTPUT.PUT_LINE(retorno);
    RETURN retorno;
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Nenhum leitor encontrado com o prontuario: '|| prontuario_l);
            RETURN 'INVALIDO';
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(SQLCODE);
            DBMS_OUTPUT.PUT_LINE(SQLERRM);
            RETURN NULL; 
END;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE(status_leitor(1710052));
END;
/


-- Confere se o exemplar está bloqueado ou não
CREATE OR REPLACE FUNCTION status_exemplar(
    cod_exemplar INT
)
RETURN VARCHAR2
IS
    retorno VARCHAR2(30);
BEGIN
    
    SELECT  status INTO retorno
    FROM exemplar WHERE codigo_exemplar = cod_exemplar;
        
    RETURN retorno;
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Nenhum exemplar foi encontrado');
            RETURN 'INVALIDO';
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(SQLCODE);
            DBMS_OUTPUT.PUT_LINE(SQLERRM);
            RETURN 'INVALIDO'; 
END;
/



-- RESERVA

CREATE OR REPLACE PROCEDURE registrar_reserva(
    id_obra_l INT,prontuario_l INT,prontuario_func_l INT
)
IS
    status_l VARCHAR2(30);
    CURSOR cursor_exemplar IS
    SELECT status, codigo_exemplar FROM obra_literaria
    JOIN exemplar USING(id_obra)
    WHERE id_obra = id_obra_l;
    
    aux_exemp cursor_exemplar%ROWTYPE;
    exemplar_ref INT;
    idLeitor INT;
    existe_disponivel INT;
    exception_leitor EXCEPTION;
    exception_pLeitor EXCEPTION;
BEGIN
    COMMIT;
    exemplar_ref := 0;
    existe_disponivel := 0;
    
    SELECT id_leitor INTO idLeitor
    FROM leitor WHERE prontuario = prontuario_l;
    IF SQL%NOTFOUND THEN
        RAISE exception_leitor;
    END IF;
    
    status_l := status_leitor(prontuario_l);
    
    IF status_l = 'BLOQUEADO' THEN
        RAISE exception_pLeitor;
    END IF;
    
    OPEN cursor_exemplar;
        LOOP
            FETCH cursor_exemplar INTO aux_exemp;
            EXIT WHEN cursor_exemplar%NOTFOUND;
            
            exemplar_ref := aux_exemp.codigo_exemplar;
            
            IF aux_exemp.status = 'DISPONIVEL' THEN    
                existe_disponivel := 1;
                EXIT;
            END IF;
           
        END LOOP;
        
        IF existe_disponivel = 1 THEN
            DBMS_OUTPUT.PUT_LINE('Ainda possui exemplares disponiveis! Você tem até 3 dias uteis para emprestalo!');
            INSERT INTO reserva VALUES(seq_reserva.nextval,SYSDATE,'EM ABERTO',exemplar_ref,prontuario_func_l,idLeitor);
            UPDATE exemplar SET status = 'RESERVADO' WHERE codigo_exemplar = exemplar_ref;
        ELSE
            INSERT INTO reserva VALUES(seq_reserva.nextval,SYSDATE,'EM ABERTO',exemplar_ref,prontuario_func_l,idLeitor);
            UPDATE exemplar SET status = 'RESERVADO' WHERE codigo_exemplar = exemplar_ref;
            DBMS_OUTPUT.PUT_LINE('Reserva efetuada com sucesso!');
        END IF;
        
    COMMIT;
    CLOSE cursor_exemplar;
    
        
    EXCEPTION 
        WHEN exception_leitor THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Prontuario de leitor invalido');
        WHEN exception_pLeitor THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Leitor bloqueado');
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE(SQLCODE);
            DBMS_OUTPUT.PUT_LINE(SQLERRM);

END;
/

BEGIN
    registrar_reserva(1,1710052,1);
END;
/
delete from reserva;
select * from reserva;

select * from obra_literaria;

select * from leitor;
update leitor set status = 'BLOQUEADO' where id_leitor = 1;

select * from funcionario;

SELECT status,codigo_exemplar
FROM obra_literaria JOIN exemplar
USING(id_obra);

SELECT * FROM EXEMPLAR;

UPDATE exemplar SET status = 'DISPONIVEL' WHERE id_obra = 1;




    