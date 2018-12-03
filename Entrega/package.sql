
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
    
    --Verifica se o prontuario do funcionario existe.
    FUNCTION existe_funcionario(
        pront_func INT
    )
    --Verifica se o leitor existe
    RETURN BOOLEAN;
       FUNCTION existe_leitor(
        id_l INT
    )
    RETURN BOOLEAN;
    
    --PROCEDURE limpa_reserva;
    PROCEDURE limpa_reserva;
    
    --Retorna a quantidade de exemplares emprestado(EM ANDAMENTO) do leitor.
    FUNCTION limite_emprestimo(
        leitor_id INT
    )
    RETURN INT;
    
    -- Realiza uma reserva.
    PROCEDURE registrar_reserva(
        id_obra_l INT,prontuario_l INT,prontuario_func_l INT
    );
    
    -- Realiza devolução
    PROCEDURE gera_devolucao(
        codigo_ex INT, data_d DATE, id_l INT, prontuario_f INT    
    );
    
    -- Realiza um emprestimo.
    PROCEDURE emprestimo_procedure(
        prontuario_leitor INT,
        prontuario_funcionario INT,
        cod_exemplar INT
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
        
        SELECT status INTO retorno
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
    
------------- LIMITE DE EMPRESTIMO
    FUNCTION limite_emprestimo(
        leitor_id INT
    )
    RETURN INT
    IS
        retorno INT;
    BEGIN
    
        SELECT count(*) INTO retorno
        FROM emprestimo
        WHERE id_leitor = leitor_id
        AND status = 'EM ANDAMENTO';
    
        RETURN retorno;
    END limite_emprestimo;
    
------------- EXISTE FUNCIONARIO
    FUNCTION existe_funcionario(
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
    END existe_funcionario;
    
------------- EXISTE LEITOR
    FUNCTION existe_leitor(
        id_l INT
    )
    RETURN boolean
    IS
        teste int;
    BEGIN
    
        SELECT id_l into teste
        FROM leitor WHERE id_leitor = id_l;
    
        RETURN true;
    
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RETURN false; 
    END existe_leitor;
    
    
    
    
    
------------------------- LIMPA RESERVA (3 dias)
    PROCEDURE limpa_reserva
    IS
        CURSOR cursor_reserva IS
        SELECT codigo_reserva, id_leitor,id_obra, data_reserva, codigo_exemplar
        FROM reserva
        WHERE status = 'CONCLUIDA';
        
        res_aux cursor_reserva%ROWTYPE;
        dif INT;
        
    BEGIN
        OPEN cursor_reserva;
        
        LOOP
            FETCH cursor_reserva INTO res_aux;
            EXIT WHEN cursor_reserva%NOTFOUND;
            
            dif := SYSDATE - res_aux.data_reserva;
            
            IF dif > 3 THEN
                UPDATE reserva 
                SET status = 'CANCELADA'
                WHERE codigo_reserva = res_aux.codigo_reserva;
                
                UPDATE exemplar 
                SET status = 'DISPONIVEL'
                WHERE codigo_exemplar = res_aux.codigo_exemplar;
            
            END IF;
        END LOOP;
    END limpa_reserva;
        
------------- REGISTRAR RESERVA
    PROCEDURE registrar_reserva(
        id_obra_l INT,prontuario_l INT,prontuario_func_l INT
    )
    IS
        status_l VARCHAR2(30);
        
        CURSOR cursor_leitor IS
        SELECT id_leitor FROM leitor
        WHERE prontuario = prontuario_l;
        
        CURSOR cursor_disponivel IS
        SELECT id_obra, codigo_exemplar
        FROM exemplar
        WHERE id_obra = id_obra_l
        AND status = 'DISPONIVEL';
        
        aux_disponivel cursor_disponivel%ROWTYPE;
        
        aux_leitor cursor_leitor%ROWTYPE;
        
        idLeitor INT;
        exception_leitor EXCEPTION;
        exception_pLeitor EXCEPTION;
        exception_disponivel EXCEPTION;
        funcionarioE EXCEPTION;
        
    BEGIN
        COMMIT;
        
        OPEN cursor_leitor;
        FETCH cursor_leitor INTO aux_leitor;
        
        IF cursor_leitor%NOTFOUND THEN
            RAISE exception_leitor;
        END IF;
        
        IF NOT existe_funcionario(prontuario_func_l) THEN
            RAISE funcionarioE;
        END IF;
        status_l := status_leitor(prontuario_l);
        
        IF status_l = 'BLOQUEADO' THEN
            RAISE exception_pLeitor;
        END IF;
        CLOSE cursor_leitor;
        
        OPEN cursor_disponivel;
        FETCH cursor_disponivel INTO aux_disponivel;
        
        IF cursor_disponivel%FOUND THEN
            RAISE exception_disponivel;
        ELSE
            INSERT INTO reserva VALUES(seq_reserva.nextval,SYSDATE,'EM ABERTO',id_obra_l,prontuario_func_l,aux_leitor.id_leitor, null);
            DBMS_OUTPUT.PUT_LINE('Reserva efetuada com sucesso!');
        END IF;
            
        COMMIT;
       
        CLOSE cursor_disponivel;
            
        EXCEPTION 
            WHEN exception_leitor THEN
                ROLLBACK;
                DBMS_OUTPUT.PUT_LINE('Prontuario de leitor invalido');
            WHEN exception_pLeitor THEN
                ROLLBACK;
                DBMS_OUTPUT.PUT_LINE('Leitor bloqueado');
            WHEN exception_disponivel THEN
                DBMS_OUTPUT.PUT_LINE('Ainda possui exemplares disponiveis!');
                ROLLBACK;
            WHEN funcionarioE THEN
                ROLLBACK;
                DBMS_OUTPUT.PUT_LINE('Funcionario nao registrado!');
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
        
        CURSOR cursor_emp IS
        SELECT codigo_emp, status, data_dev
        FROM emprestimo 
        WHERE  codigo_exemplar = codigo_ex
        AND id_leitor = id_l
        AND status = 'EM ANDAMENTO';
        
        CURSOR cursor_reserva IS
        SELECT codigo_reserva, id_leitor
        FROM reserva
        WHERE id_obra = (SELECT id_obra
                         FROM exemplar
                         WHERE codigo_exemplar = codigo_ex)
        AND data_reserva = (SELECT MIN(data_reserva)
                            FROM reserva
                            WHERE id_obra = (SELECT id_obra
                                             FROM exemplar
                                             WHERE codigo_exemplar = codigo_ex))
        AND status = 'EM ABERTO';

        emp_aux cursor_emp%ROWTYPE;
        res_aux cursor_reserva%ROWTYPE;
        
        emprestimoE EXCEPTION;
        funcionarioE EXCEPTION;
        leitorE EXCEPTION;
        pront_leitor INT;
        
    BEGIN
        COMMIT; 
        OPEN cursor_emp;
        FETCH cursor_emp INTO emp_aux;
        
        IF NOT existe_leitor(id_l) THEN
            RAISE leitorE;
        END IF;
        
        IF cursor_emp%NOTFOUND THEN
            RAISE emprestimoE;
        END IF;
    
        IF NOT existe_funcionario(prontuario_f) THEN
            RAISE funcionarioE;
        END IF;
                    
        IF data_d > emp_aux.data_dev THEN
            UPDATE leitor 
            SET status = 'BLOQUEADO' 
            WHERE id_leitor = id_l;
        END IF;
        
        INSERT INTO devolucao VALUES(seq_dev.nextval,emp_aux.data_dev,emp_aux.codigo_emp,codigo_ex,id_l,prontuario_f);
        
        UPDATE emprestimo 
        SET status = 'CONCLUIDO' 
        WHERE codigo_emp = emp_aux.codigo_emp;
        
        DBMS_OUTPUT.PUT_LINE('Devolu��o realizada com sucesso!');
        
        OPEN cursor_reserva;
        FETCH cursor_reserva INTO res_aux;
        
        IF cursor_reserva%FOUND THEN
            UPDATE exemplar 
            SET status = 'RESERVADO' 
            WHERE codigo_exemplar = codigo_ex;
            
            UPDATE reserva 
            SET status = 'CONCLUIDA', data_reserva = SYSDATE
            WHERE codigo_reserva = res_aux.codigo_reserva;
            
            UPDATE reserva 
            SET codigo_exemplar = codigo_ex
            WHERE codigo_reserva = res_aux.codigo_reserva;
            
            SELECT prontuario INTO pront_leitor
            FROM leitor
            WHERE id_leitor = res_aux.id_leitor;
            
            DBMS_OUTPUT.PUT_LINE('Leitor com o prontuario: ' || pront_leitor || ' dever� retirar o livro reservado em 3 dias!');
            
        ELSE
            UPDATE exemplar 
            SET status = 'DISPONIVEL' 
            WHERE codigo_exemplar = codigo_ex;
        END IF;
          
        CLOSE cursor_emp;
        CLOSE cursor_reserva;
       
        COMMIT;
        
        EXCEPTION 
            WHEN NO_DATA_FOUND THEN
                ROLLBACK;
                DBMS_OUTPUT.PUT_LINE('Emprestimo não existe');
            WHEN funcionarioE THEN
                ROLLBACK;
                DBMS_OUTPUT.PUT_LINE('Funcionario nao encontrado!');
            WHEN leitorE THEN
                ROLLBACK;
                DBMS_OUTPUT.PUT_LINE('Leitor nao encontrado!');
            WHEN emprestimoE THEN
                ROLLBACK;
                DBMS_OUTPUT.PUT_LINE('Emprestimo nao encontrado!');
            WHEN others THEN
                ROLLBACK;
                DBMS_OUTPUT.PUT_LINE(SQLCODE);
                DBMS_OUTPUT.PUT_LINE(SQLERRM);
    END gera_devolucao;
    

 ----------- EMPRESTIMO
    PROCEDURE emprestimo_procedure(
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
            AND id_obra = (SELECT id_obra
                           FROM exemplar
                           WHERE codigo_exemplar = cod_exemplar)
            AND status = 'CONCLUIDA';
        
        aux_reserva cursor_reserva%ROWTYPE;
        
        leitor_erro EXCEPTION;
        leitor_bloaqueado EXCEPTION;
        exemplar_erro EXCEPTION;
        funcionario_erro EXCEPTION;
        reservado_por_outro EXCEPTION;
        exemplar_emprestado EXCEPTION;
        limite_emp EXCEPTION;
        
        retorno_exm varchar2(30);
        datadev date;
        
    BEGIN
        COMMIT;
        OPEN cursor_leitor;
        
        FETCH cursor_leitor into aux_leitor;
        
        IF cursor_leitor%NOTFOUND THEN
            RAISE leitor_erro;
        ELSIF aux_leitor.status = 'BLOQUEADO' THEN
            RAISE leitor_bloaqueado;
        ELSIF limite_emprestimo(aux_leitor.id_leitor) >= 5 THEN
            RAISE limite_emp;
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
                    SET status = 'FECHADA'
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
            ROLLBACK; 
            DBMS_OUTPUT.PUT_LINE('Nenhum leitor encontrado com o prontuario: '|| prontuario_leitor);
        WHEN leitor_bloaqueado THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Leitor esta bloqueado!');
        WHEN limite_emp THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Leitor j� possui o limite de exemplares emprestado!');
        WHEN exemplar_erro THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Nenhum exemplar foi encontrado. Condigo invalido');
        WHEN exemplar_emprestado THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Exemplar j� esta emprestado! Tente outro exemplar.');
        WHEN funcionario_erro THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Nenhum funcionario encontrado com o prontuario: '|| prontuario_funcionario);
        WHEN reservado_por_outro THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Exemplar reservado por outro leitor!');
    END emprestimo_procedure;
    
    
END biblioteca_admin;
/

SET SERVEROUTPUT ON;

BEGIN 
    biblioteca_admin.emprestimo_procedure(1710052,1,5);
END;
/
 
    
BEGIN 

    biblioteca_admin.emprestimo_procedure(1710125,1,1);
    biblioteca_admin.emprestimo_procedure(1710052,1,2);
    biblioteca_admin.emprestimo_procedure(1710052,1,3);
    biblioteca_admin.emprestimo_procedure(1710125,1,4); 
    biblioteca_admin.emprestimo_procedure(1710324,1,5);
    biblioteca_admin.emprestimo_procedure(1710324,1,7);
END;
/
    
    select * from leitor;

BEGIN 
    biblioteca_admin.registrar_reserva(1,1710157,1);
    
    --biblioteca_admin.gera_devolucao(3,SYSDATE,1,1);
    --biblioteca_admin.emprestimo_procedure(1710125,1,1);   
    --biblioteca_admin.limpa_reserva;
END;
/

BEGIN 
    --biblioteca_admin.registrar_reserva(1,1710157,1);
    
    --biblioteca_admin.gera_devolucao(1,SYSDATE,2,1);
    --biblioteca_admin.emprestimo_procedure(1710157,1,1);   
    --biblioteca_admin.limpa_reserva;
END;
/

select * from reserva;
select * from obra_literaria;
select * from leitor;
select * from exemplar;
select * from emprestimo;
select * from devolucao;
select * from obra_literaria;

delete from reserva;
delete from emprestimo;
delete from devolucao;


UPDATE exemplar SET STATUS = 'DISPONIVEL';
update reserva set data_reserva = SYSDATE+1 WHERE ID_LEITOR = 2;
update emprestimo set status = 'CONCLUIDA' where codigo_emp = 2;
update reserva set data_reserva = SYSDATE-4, status = 'CONCLUIDA' WHERE ID_LEITOR = 5;
