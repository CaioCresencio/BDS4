
CREATE TABLE funcionario (
    prontuario_func INT PRIMARY KEY,
    endereco VARCHAR2(70) NOT NULL,
    data_nascimento DATE NOT NULL,
    telefone INT NOT NULL,
    nome VARCHAR2(50) NOT NULL);
    
CREATE SEQUENCE seq_catLiteraria
nocycle
start with 1
increment by 1
maxvalue 99999;

CREATE TABLE categoria_literaria(
    codigo INT PRIMARY KEY,
    descricao VARCHAR2(70) NOT NULL,
    tempo_emprestimo INT NOT NULL);
    
CREATE TABLE lista_autores(
    id_lista INT PRIMARY KEY);
    
CREATE TABLE lista_palavras(
    id_lista INT PRIMARY KEY);
    
CREATE TABLE palavra_chave(
    id_palavra INT PRIMARY KEY,
    conteudo VARCHAR2(20)NOT NULL,
    id_lista INT NOT NULL,
    FOREIGN KEY (id_lista) REFERENCES lista_palavras(id_lista));

CREATE TABLE autor(
    id_autor INT PRIMARY KEY,
    nome VARCHAR2(50) NOT NULL,
    id_lista INT NOT NULL,
    FOREIGN KEY (id_lista) REFERENCES lista_autores(id_lista));
    

CREATE TABLE obra_literaria(
    id_obra INT PRIMARY KEY,
    isbn VARCHAR2(50) NOT NULL,
    qtd_exemplares INT NOT NULL,
    nrm_edicao INT NOT NULL,
    data_publicacao DATE NOT NULL,
    editora VARCHAR2(50) NOT NULL,
    titulo_obra VARCHAR2(50) NOT NULL,
    categoria_obra INT NOT NULL,
    id_lista_palavras INT NOT NULL,
    id_lista_autores INT NOT NULL,
    FOREIGN KEY (categoria_obra) REFERENCES categoria_literaria(codigo),
    FOREIGN KEY (id_lista_palavras) REFERENCES lista_autores(id_lista),
    FOREIGN KEY (id_lista_autores) REFERENCES lista_autores(id_lista)
    );
    
CREATE TABLE categoria_leitor(
    codigo_categoria INT PRIMARY KEY,
    descricao VARCHAR2(100) NOT NULL,
    tempo_emprestimo INT NOT NULL
    );
    
CREATE TABLE RG (
    numero INT PRIMARY KEY,
    estado INT NOT NULL
    );
    
CREATE TABLE leitor(
    id_leitor INT PRIMARY KEY,
    nome VARCHAR2(100) NOT NULL,
    estado INT NOT NULL,
    telefone INT NOT NULL,
    prontuario INT NOT NULL,
    data_nascimento DATE NOT NULL,
    email VARCHAR2(40) NOT NULL,
    rg INT NOT NULL,
    FOREIGN KEY (rg) REFERENCES rg(numero)
    );
    
CREATE TABLE exemplar(
    codigo_exemplar INT PRIMARY KEY,
    status INT NOT NULL,
    id_obra INT NOT NULL,
    FOREIGN KEY (id_obra) REFERENCES obra_literaria (id_obra));
    
CREATE TABLE reserva (
    codigo_reserva INT PRIMARY KEY,
    data_reserva DATE NOT NULL,
    codigo_exemplar INT NOT NULL,
    prontuario_func INT NOT NULL,
    id_leitor INT NOT NULL,
    FOREIGN KEY (prontuario_func) REFERENCES funcionario(prontuario_func),
    FOREIGN KEY (id_leitor) REFERENCES leitor(id_leitor)
    ); 