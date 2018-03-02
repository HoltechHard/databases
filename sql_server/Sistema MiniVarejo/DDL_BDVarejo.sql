use BDVarejo
go

CREATE TABLE CATEGORIA
( 
	id_categoria         int IDENTITY ( 1,1 ) ,
	descricao            varchar(50)  NULL ,
	id_linha             int  NULL ,
	taxa_lucro           decimal(4,2)  NULL 
)
go

ALTER TABLE CATEGORIA
	ADD CONSTRAINT XPKCATEGORIA PRIMARY KEY  CLUSTERED (id_categoria ASC)
go

CREATE TABLE CIDADE
( 
	id_cidade            int IDENTITY ( 1,1 ) ,
	descricao            varchar(50)  NULL ,
	id_estado            int  NULL 
)
go

ALTER TABLE CIDADE
	ADD CONSTRAINT XPKCIDADE PRIMARY KEY  CLUSTERED (id_cidade ASC)
go

CREATE TABLE CLIENTE
( 
	id_empresa           int  NOT NULL ,
	id_cidade            int  NULL 
)
go

ALTER TABLE CLIENTE
	ADD CONSTRAINT XPKCLIENT PRIMARY KEY  CLUSTERED (id_empresa ASC)
go

CREATE TABLE COMPRA
( 
	id_compra            int IDENTITY ( 1000,1 ) ,
	data_compra          datetime  NULL ,
	data_entrega         datetime  NULL ,
	data_recepcao        datetime  NULL ,
	estado               char(1)  NULL ,
	total                decimal(12,2)  NULL ,
	id_empresa           int  NULL 
)
go

ALTER TABLE COMPRA
	ADD CONSTRAINT XPKCOMPRA PRIMARY KEY  CLUSTERED (id_compra ASC)
go

CREATE TABLE DETALHE_COMPRA
( 
	id_compra            int  NOT NULL ,
	id_produto           int  NOT NULL ,
	quantidade           int  NULL ,
	subtotal             decimal(8,2)  NULL 
)
go

ALTER TABLE DETALHE_COMPRA
	ADD CONSTRAINT XPKDETALHE_COMPRA PRIMARY KEY  CLUSTERED (id_compra ASC,id_produto ASC)
go

CREATE TABLE DETALHE_VENDA
( 
	id_produto           int  NOT NULL ,
	id_venda             int  NOT NULL ,
	subtotal             decimal(8,2)  NULL ,
	quantidade           int  NULL ,
	icms                 decimal(4,2)  NULL 
)
go

ALTER TABLE DETALHE_VENDA
	ADD CONSTRAINT XPKDETALHE_PEDIDO PRIMARY KEY  CLUSTERED (id_produto ASC,id_venda ASC)
go

CREATE TABLE EMPRESA
( 
	id_empresa           int IDENTITY ( 100,1 ) ,
	cnpj                 char(20)  NULL ,
	corporacao           varchar(50)  NULL ,
	endereco             varchar(50)  NULL ,
	estado               bit  NULL ,
	tipo                 char(1)  NULL 
)
go

ALTER TABLE EMPRESA
	ADD CONSTRAINT XPKCLIENTE PRIMARY KEY  CLUSTERED (id_empresa ASC)
go

CREATE TABLE ESTADO
( 
	id_estado            int IDENTITY ( 1,1 ) ,
	descricao            varchar(50)  NULL ,
	id_regiao            int  NULL ,
	sigla                char(2)  NULL 
)
go

ALTER TABLE ESTADO
	ADD CONSTRAINT XPKESTADO PRIMARY KEY  CLUSTERED (id_estado ASC)
go

CREATE TABLE FUNCAO
( 
	id_funcao            int IDENTITY ( 1,1 ) ,
	descricao            varchar(50)  NULL 
)
go

ALTER TABLE FUNCAO
	ADD CONSTRAINT XPKFUNCAO PRIMARY KEY  CLUSTERED (id_funcao ASC)
go

CREATE TABLE LINHA_PRODUCAO
( 
	id_linha             int IDENTITY ( 1,1 ) ,
	descricao            varchar(50)  NULL 
)
go

ALTER TABLE LINHA_PRODUCAO
	ADD CONSTRAINT XPKLINHA_PRODUCAO PRIMARY KEY  CLUSTERED (id_linha ASC)
go

CREATE TABLE PAIS
( 
	id_pais              int IDENTITY ( 1,1 ) ,
	nome                 varchar(50)  NULL ,
	taxa_importacao      decimal(4,2)  NULL ,
	total_exportacao     decimal(12, 2)  NULL 
)
go

ALTER TABLE PAIS
	ADD CONSTRAINT XPKPAIS PRIMARY KEY  CLUSTERED (id_pais ASC)
go

CREATE TABLE PRODUTO
( 
	id_produto           int IDENTITY ( 1000,1 ) ,
	nome                 varchar(255)  NULL ,
	stock_minimo         int  NULL ,
	preco_venda          decimal(8,2)  NULL ,
	stock_atual          int  NULL ,
	id_categoria         int  NULL ,
	stock_maximo         int  NULL ,
	preco_compra         decimal(8,2)  NULL 
)
go

ALTER TABLE PRODUTO
	ADD CONSTRAINT XPKPRODUTO PRIMARY KEY  CLUSTERED (id_produto ASC)
go

CREATE TABLE PROVEDOR
( 
	id_empresa           int  NOT NULL ,
	id_pais              int  NULL ,
	custo_frete          decimal(8,2)  NULL ,
	compras              decimal(12, 2)  NULL 
)
go

ALTER TABLE PROVEDOR
	ADD CONSTRAINT XPKPROVEDOR PRIMARY KEY  CLUSTERED (id_empresa ASC)
go

CREATE TABLE REGIAO
( 
	id_regiao            int IDENTITY ( 1,1 ) ,
	descricao            varchar(30)  NULL 
)
go

ALTER TABLE REGIAO
	ADD CONSTRAINT XPKREGIAO PRIMARY KEY  CLUSTERED (id_regiao ASC)
go

CREATE TABLE SUCURSAL
( 
	id_sucursal          int IDENTITY ( 10,1 ) ,
	nome                 varchar(50)  NULL ,
	endereco             varchar(50)  NULL ,
	id_cidade            int  NULL 
)
go

ALTER TABLE SUCURSAL
	ADD CONSTRAINT XPKSUCURSAL PRIMARY KEY  CLUSTERED (id_sucursal ASC)
go

CREATE TABLE VENDAS
( 
	id_venda             int IDENTITY ( 1000,1 ) ,
	data                 datetime  NULL ,
	id_vendedor          int  NULL ,
	total                decimal(12,2)  NULL ,
	id_empresa           int  NULL 
)
go

ALTER TABLE VENDAS
	ADD CONSTRAINT XPKPEDIDO PRIMARY KEY  CLUSTERED (id_venda ASC)
go

CREATE TABLE VENDEDOR
( 
	id_vendedor          int IDENTITY ( 10,1 ) ,
	meta                 decimal(12,2)  NULL ,
	vendas               decimal(12,2)  NULL ,
	nome                 varchar(50)  NULL ,
	sobrenome            varchar(50)  NULL ,
	id_funcao            int  NULL ,
	cpf                  char(18)  NULL ,
	id_sucursal          int  NULL ,
	salario_fixo         decimal(8,2)  NULL ,
	comissao             decimal(4,2)  NULL ,
	bonificacao          decimal(4,2)  NULL ,
	salario_total        decimal(8,2)  NULL 
)
go

ALTER TABLE VENDEDOR
	ADD CONSTRAINT XPKVENDEDOR PRIMARY KEY  CLUSTERED (id_vendedor ASC)
go

ALTER TABLE CATEGORIA
	ADD CONSTRAINT R_12 FOREIGN KEY (id_linha) REFERENCES LINHA_PRODUCAO(id_linha)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
go

ALTER TABLE CIDADE
	ADD CONSTRAINT R_7 FOREIGN KEY (id_estado) REFERENCES ESTADO(id_estado)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
go

ALTER TABLE CLIENTE
	ADD CONSTRAINT R_20 FOREIGN KEY (id_empresa) REFERENCES EMPRESA(id_empresa)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
go

ALTER TABLE CLIENTE
	ADD CONSTRAINT R_21 FOREIGN KEY (id_cidade) REFERENCES CIDADE(id_cidade)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
go

ALTER TABLE COMPRA
	ADD CONSTRAINT R_24 FOREIGN KEY (id_empresa) REFERENCES PROVEDOR(id_empresa)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
go

ALTER TABLE DETALHE_COMPRA
	ADD CONSTRAINT R_25 FOREIGN KEY (id_compra) REFERENCES COMPRA(id_compra)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
go

ALTER TABLE DETALHE_COMPRA
	ADD CONSTRAINT R_26 FOREIGN KEY (id_produto) REFERENCES PRODUTO(id_produto)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
go

ALTER TABLE DETALHE_VENDA
	ADD CONSTRAINT R_2 FOREIGN KEY (id_produto) REFERENCES PRODUTO(id_produto)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
go

ALTER TABLE DETALHE_VENDA
	ADD CONSTRAINT R_3 FOREIGN KEY (id_venda) REFERENCES VENDAS(id_venda)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
go

ALTER TABLE ESTADO
	ADD CONSTRAINT R_6 FOREIGN KEY (id_regiao) REFERENCES REGIAO(id_regiao)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
go

ALTER TABLE PRODUTO
	ADD CONSTRAINT R_5 FOREIGN KEY (id_categoria) REFERENCES CATEGORIA(id_categoria)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
go

ALTER TABLE PROVEDOR
	ADD CONSTRAINT R_19 FOREIGN KEY (id_empresa) REFERENCES EMPRESA(id_empresa)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
go

ALTER TABLE PROVEDOR
	ADD CONSTRAINT R_23 FOREIGN KEY (id_pais) REFERENCES PAIS(id_pais)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
go

ALTER TABLE SUCURSAL
	ADD CONSTRAINT R_8 FOREIGN KEY (id_cidade) REFERENCES CIDADE(id_cidade)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
go

ALTER TABLE VENDAS
	ADD CONSTRAINT R_1 FOREIGN KEY (id_vendedor) REFERENCES VENDEDOR(id_vendedor)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
go

ALTER TABLE VENDAS
	ADD CONSTRAINT R_22 FOREIGN KEY (id_empresa) REFERENCES CLIENTE(id_empresa)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
go

ALTER TABLE VENDEDOR
	ADD CONSTRAINT R_4 FOREIGN KEY (id_funcao) REFERENCES FUNCAO(id_funcao)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
go

ALTER TABLE VENDEDOR
	ADD CONSTRAINT R_9 FOREIGN KEY (id_sucursal) REFERENCES SUCURSAL(id_sucursal)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
go
