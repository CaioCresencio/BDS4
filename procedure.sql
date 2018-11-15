SET SERVEROUTPUT ON;
-- Cadastro: categoria de leitor
CREATE OR REPLACE PROCEDURE cadastra_categoria_leitor(
    descric VARCHAR2, temp_emprestimo INT
)

IS 
BEGIN
    COMMIT;
	INSERT INTO categoria_leitor(codigo_categoria,descricao,tempo_emprestimo)
	VALUES  (seq_categoriaLeitor.nextval,descric,temp_emprestimo);
    DBMS_OUTPUT.PUT_LINE('Categoria de leitor Cadastrada com sucesso!');
    COMMIT;
END;
/

-- Cadastro: categoria de obra

CREATE OR REPLACE PROCEDURE cadastra_categoria_literaria(
    cod_categoria INT, descric VARCHAR2, temp_emprestimo INT
)
IS
BEGIN
    COMMIT;
	INSERT INTO categoria_literaria (codigo_categoria,descricao,tempo_emprestimo)
	VALUES  (seq_catLiteraria.nextval,descric,temp_emprestimo);
    DBMS_OUTPUT.PUT_LINE('Categoria literaria Cadastrada com sucesso!');
    COMMIT;
END;
/

-- Cadastro: funcionario

CREATE OR REPLACE PROCEDURE cadastrar_funcionario(
    prontuario_f INT,nome_func VARCHAR2, ende VARCHAR2,tel INT, data_nasc DATE
)
IS
    CURSOR cursor_func IS
    SELECT prontuario_func FROM funcionario
    WHERE prontuario_func = prontuario_f;
    
BEGIN
    COMMIT;
    OPEN cursor_func;
        IF SQL%NOTFOUND THEN
            INSERT INTO funcionario (prontuario_func,endereco,data_nascimento,telefone,nome)
            VALUES (prontuario_f,ende,data_nasc,tel,nome_func);
            DBMS_OUTPUT.PUT_LINE('Funcionario cadastrado com sucesso!');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Funcionario já cadastrado!');        
        END IF;

    CLOSE cursor_func;
    COMMIT;
END;
/



-- Cadastro de leitor 

BEGIN 
    cadastro_leitor('caio','teste','sp',333,10252,'26-05-1858','canelada',2,23225,'AT');
END;
/

select * from rg;

SELECT * FROM leitor;
CREATE OR REPLACE PROCEDURE cadastro_leitor(
    nome_l VARCHAR2, cidade_l VARCHAR2, estado_l VARCHAR2, tel INT,
    prontuario_l INT,data_nasc DATE, email_l VARCHAR2, codigo_cat INT, rg_l INT,
    estado_rg VARCHAR2
)
IS 
    CURSOR cursor_rg IS
    SELECT numero FROM
    rg WHERE numero = rg_l;
    
    CURSOR cursor_leitor IS
    SELECT prontuario FROM leitor
    WHERE prontuario = prontuario_l;

   
    
    erro_leitor EXCEPTION;
    
BEGIN
    COMMIT;
    OPEN cursor_rg;
    OPEN cursor_leitor;
    
    
    IF cursor_rg%NOTFOUND THEN
        INSERT INTO rg (id_rg,numero,estado) 
        VALUES(seq_rg.nextval,rg_l, estado_rg);
        
        IF cursor_leitor%NOTFOUND THEN
            INSERT INTO leitor(id_leitor,nome,cidade,estado,telefone,prontuario,data_nascimento,
            email,id_rg,codigo_categoria) 
            VALUES (seq_leitor.nextval,nome_l,cidade_l,estado_l,tel,prontuario_l,data_nasc,email_l,seq_rg.currval,codigo_cat);
        ELSE
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Prontuario já existente');
        END IF;
    ELSE
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('RG já cadastrado');
    END IF;
    
    CLOSE cursor_leitor;
    CLOSE cursor_rg;
    
    COMMIT;
END;



