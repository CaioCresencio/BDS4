SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE gera_devolucao(
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
                DBMS_OUTPUT.PUT_LINE('AQUI');
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
END;
/

BEGIN
    gera_devolucao(3,'17-11-2018',1,1);
END;
/
INSERT INTO emprestimo VALUES (seq_emprestimo.nextval,'16-11-2018','15-11-2018','EM ABERTO',4,1,1);

select * from emprestimo;
delete from emprestimo;
delete from devolucao;
select * from devolucao;
select * from leitor;
SELECT * FROM EXEMPLAR;
SELECT * FROM RESERVA;