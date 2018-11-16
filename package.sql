
CREATE OR REPLACE PACKAGE biblioteca_admin AS
    -- Retorna o status do leitor.
    FUNCTION status_leitor(
        prontuario_l INT
    )
    RETURN VARCHAR2;
    
    -- Retorna o status do exemplar.
    FUNCTION status_exemplar(
        cod_exemplar INT
    )
    RETURN VARCHAR2;
    
    -- Realiza uma reserva.
    PROCEDURE registrar_reserva(
        id_obra_l INT,prontuario_l INT,prontuario_func_l INT
    );
    -- Realiza devolução
    PROCEDURE gera_devolucao(
        codigo_ex INT, data_d DATE, id_l INT, prontuario_f INT    
    );
    

END biblioteca_admin;
/
CREATE OR REPLACE PACKAGE BODY biblioteca_admin AS
-------------- STATUS DO EXEMPLAR
    FUNCTION status_exemplar(
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
    END status_exemplar;
    


-------------- STATUS LEITOR
    FUNCTION status_leitor(
          prontuario_l INT
    )
    RETURN VARCHAR2
    IS
        retorno VARCHAR2(30);
    BEGIN
            
        SELECT  status INTO retorno
        FROM leitor WHERE prontuario = prontuario_l;
        RETURN retorno;
            
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('Nenhum leitor encontrado com o prontuario: '|| prontuario_l);
                RETURN 'INVALIDO';
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE(SQLCODE);
                DBMS_OUTPUT.PUT_LINE(SQLERRM);
                RETURN NULL; 
    END status_leitor;
    

------------- REGISTRAR RESERVA
    PROCEDURE registrar_reserva(
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
    END registrar_reserva;
        
 ----------- DEVOLUÇÃO
    PROCEDURE gera_devolucao(
       codigo_ex INT, data_d DATE, id_l INT, prontuario_f INT    
    )
    IS  
        exception_emprestimo EXCEPTION;
        codigo INT;
        data_e DATE;
        
        CURSOR cursor_emp IS
        SELECT codigo_emp, status
        FROM emprestimo 
        WHERE  id_leitor =  id_l
        AND status = 'EM ABERTO';
        
        emp_aux cursor_emp%ROWTYPE;
        
        emprestimos_faltando INT;
    BEGIN
        COMMIT;
        
        emprestimos_faltando := 0;
        
        SELECT codigo_emp INTO codigo
        FROM emprestimo     
        WHERE codigo_exemplar = codigo_ex
        AND status = 'EM ABERTO'; 
        
        SELECT data_emp  INTO data_e
        FROM emprestimo WHERE codigo_exemplar = codigo_ex;
        
          
        INSERT INTO devolucao VALUES(seq_dev.nextval,data_d,codigo_ex,id_l,prontuario_f);
        UPDATE exemplar SET status = 'DISPONIVEL' WHERE codigo_exemplar = codigo_ex;
        UPDATE emprestimo SET status = 'FECHADO' WHERE codigo_exemplar = codigo_ex;
        
        OPEN cursor_emp;
            LOOP
                FETCH cursor_emp INTO emp_aux;
                EXIT WHEN cursor_emp%NOTFOUND;
                
                IF MONTHS_BETWEEN(data_d,data_e) < 1 THEN
                    emprestimos_faltando := emprestimos_faltando +1;
                END IF;
        
                
            END LOOP;
        CLOSE cursor_emp;
        
        IF emprestimos_faltando >= 1 THEN
            UPDATE leitor SET status = 'BLOQUEADO' WHERE id_leitor = id_l;
        ELSE 
            UPDATE leitor SET status = 'DISPONIVEL' WHERE id_leitor = id_l;
        END IF;
       
        COMMIT;
        
        EXCEPTION 
        
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('Emprestimo não existe');
            WHEN others THEN
                DBMS_OUTPUT.PUT_LINE(SQLCODE);
                DBMS_OUTPUT.PUT_LINE(SQLERRM);
    END gera_devolucao;
END biblioteca_admin;
/
set serveroutput on;
DECLARE 

 teste VARCHAR2(30);
BEGIN 
    biblioteca_admin.registrar_reserva(1,1710052 ,1);
END;
/
BEGIN
    biblioteca_admin.gera_devolucao(2,'22-11-2018',1,1);
END;
/
SELECT * FROM RESERVA;
SELECT * FROM leitor;
SELECT * FROM emprestimo;
INSERT INTO emprestimo VALUES(6,'20-11-2018','19-11-2018','EM ABERTO',2,1,1);