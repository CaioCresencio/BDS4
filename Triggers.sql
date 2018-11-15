--dropar a base porque mudei os status do exemplar para string (disponivel, emprestado);
CREATE OR REPLACE TRIGGER cadastra_exemplar
    AFTER INSERT ON obra_literaria FOR EACH ROW
BEGIN
    FOR i IN 1..:NEW.qtd_exemplares LOOP
        INSERT INTO exemplar VALUES(seq_exemplar.nextval, 'DISPONIVEL', :NEW.id_obra);
    END LOOP;
END;
/

