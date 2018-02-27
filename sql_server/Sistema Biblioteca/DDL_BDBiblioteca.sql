use BDBiblioteca
go

/*
			--- DDL DO BANCO DE DADOS BDBiblioteca ---
*/

CREATE TABLE AUTOR
( 
	id_autor             int IDENTITY ( 1000,1 ) ,
	nome                 varchar(50)  NULL ,
	sobrenome            varchar(50)  NULL ,
	nacionalidade        varchar(50)  NULL ,
	qualificacao         int  NULL 
)
go

ALTER TABLE AUTOR
	ADD CONSTRAINT XPKAUTOR PRIMARY KEY  CLUSTERED (id_autor ASC)
go

CREATE TABLE DETALHE_LIVRO
( 
	id_livro             int  NOT NULL ,
	id_autor             int  NOT NULL 
)
go

ALTER TABLE DETALHE_LIVRO
	ADD CONSTRAINT XPKDETALHE_LIVRO PRIMARY KEY  CLUSTERED (id_livro ASC,id_autor ASC)
go

CREATE TABLE EDITORIAL
( 
	id_editorial         int IDENTITY ( 1000,1 ) ,
	descricao            varchar(50)  NULL 
)
go

ALTER TABLE EDITORIAL
	ADD CONSTRAINT XPKEDITORIAL PRIMARY KEY  CLUSTERED (id_editorial ASC)
go

CREATE TABLE EMPRESTIMO
( 
	id_emprestimo        char(10)  NOT NULL ,
	id_exemplar          char(8)  NOT NULL ,
	estado               int  NULL ,
	data_emprestimo      datetime  NULL ,
	tipo                 int  NULL ,
	data_devolucao       datetime  NULL ,
	data_entrega         datetime  NULL ,
	id_livro             int  NOT NULL ,
	cpf                  char(15)  NULL 
)
go

ALTER TABLE EMPRESTIMO
	ADD CONSTRAINT XPKEMPRESTIMO PRIMARY KEY  CLUSTERED (id_emprestimo ASC,id_exemplar ASC,id_livro ASC)
go

CREATE TABLE EXEMPLAR
( 
	id_exemplar          char(8)  NOT NULL ,
	disponibilidade      int  NULL ,
	estado               int  NULL ,
	id_livro             int  NOT NULL ,
	data_compra          datetime  NULL 
)
go

ALTER TABLE EXEMPLAR
	ADD CONSTRAINT XPKEXEMPLAR PRIMARY KEY  CLUSTERED (id_exemplar ASC,id_livro ASC)
go

CREATE TABLE LEITOR
( 
	cpf                  char(15)  NOT NULL ,
	nome                 varchar(50)  NULL ,
	sobrenome            varchar(50)  NULL ,
	endereco             varchar(50)  NULL ,
	telefone             char(15)  NULL ,
	celular              char(15)  NULL ,
	email                varchar(50)  NULL ,
	estado               int  NULL 
)
go

ALTER TABLE LEITOR
	ADD CONSTRAINT XPKLEITOR PRIMARY KEY  CLUSTERED (cpf ASC)
go

CREATE TABLE LIVRO
( 
	id_livro             int IDENTITY ( 1000,1 ) ,
	id_editorial         int  NULL ,
	isbn                 char(13)  NULL ,
	titulo               varchar(50)  NULL ,
	paginas              int  NULL 
)
go

ALTER TABLE LIVRO
	ADD CONSTRAINT XPKLIVRO PRIMARY KEY  CLUSTERED (id_livro ASC)
go

ALTER TABLE DETALHE_LIVRO
	ADD CONSTRAINT R_2 FOREIGN KEY (id_livro) REFERENCES LIVRO(id_livro)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
go

ALTER TABLE DETALHE_LIVRO
	ADD CONSTRAINT R_3 FOREIGN KEY (id_autor) REFERENCES AUTOR(id_autor)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
go

ALTER TABLE EMPRESTIMO
	ADD CONSTRAINT R_8 FOREIGN KEY (id_exemplar,id_livro) REFERENCES EXEMPLAR(id_exemplar,id_livro)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
go

ALTER TABLE EMPRESTIMO
	ADD CONSTRAINT R_10 FOREIGN KEY (cpf) REFERENCES LEITOR(cpf)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
go

ALTER TABLE EXEMPLAR
	ADD CONSTRAINT R_9 FOREIGN KEY (id_livro) REFERENCES LIVRO(id_livro)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
go

ALTER TABLE LIVRO
	ADD CONSTRAINT R_6 FOREIGN KEY (id_editorial) REFERENCES EDITORIAL(id_editorial)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
go
