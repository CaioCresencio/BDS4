
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
    RETURN BOOLEAN;
    
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
        
        exemplar_ref INT;
        idLeitor INT;
        existe_disponivel INT;
        exception_leitor EXCEPTION;
        exception_pLeitor EXCEPTION;
        exception_disponivel EXCEPTION;
        
    BEGIN
        COMMIT;
        exemplar_ref := 0;
        existe_disponivel := 0;
        
        OPEN cursor_leitor;
        FETCH cursor_leitor INTO aux_leitor;
        IF cursor_leitor%NOTFOUND THEN
            RAISE exception_leitor;
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
            INSERT INTO reserva VALUES(seq_reserva.nextval,SYSDATE,'EM ABERTO',exemplar_ref,id_obra_l,prontuario_func_l,aux_leitor.id_leitor);
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
        AND status = 'EM ANDAMENTO';
        
--        
--        CURSOR cursor_res IS
--        SELECT id_leitor,codigo_exemplar 
--        FROM reserva
--        WHERE codigo_exemplar = codigo_ex
--        AND data_reserva = MIN(data_reserva); 
    
        
        emp_aux cursor_emp%ROWTYPE;
        
        emprestimos_faltando INT;
        
    BEGIN
        COMMIT;
        
        emprestimos_faltando := 0;
        
        SELECT codigo_emp INTO codigo
        FROM emprestimo     
        WHERE codigo_exemplar = codigo_ex
        AND status = 'EM ANDAMENTO'; 
        
        
        SELECT data_emp  INTO data_e
        FROM emprestimo WHERE codigo_exemplar = codigo_ex;
        
          
        INSERT INTO devolucao VALUES(seq_dev.nextval,data_d,codigo,codigo_ex,id_l,prontuario_f);
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
                ROLLBACK;
                DBMS_OUTPUT.PUT_LINE('Emprestimo não existe');
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
            AND codigo_exemplar = cod_exemplar
            AND status = 'EM ABERTO';
        
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
        ELSIF limite_emprestimo(aux_leitor.id_leitor) >= 3 THEN
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


select * from emprestimo;
select * from reserva;
BEGIN 
    biblioteca_admin.emprestimo_procedure(1710125,1,5);
    
END;
/
    
BEGIN 
    biblioteca_admin.registrar_reserva(1,1710052,1);
    
END;
/

select * from reserva;

  SELECT id_leitor,codigo_exemplar 
        FROM reserva
        WHERE codigo_exemplar = 2
        AND data_reserva = MIN(data_reserva);