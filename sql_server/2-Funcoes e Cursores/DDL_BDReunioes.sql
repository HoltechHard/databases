use BDReunioes
go

CREATE TABLE DESCRICAO
( 
	id_descricao         int identity(1,1) NOT NULL ,
	descricao            varchar(50)  NULL 
)
go

ALTER TABLE DESCRICAO
	ADD CONSTRAINT XPKDESCRICAO PRIMARY KEY  CLUSTERED (id_descricao ASC)
go

CREATE TABLE REUNIAO
( 
	id_reuniao           int identity(1,1) NOT NULL ,
	assunto              varchar(50)  NULL ,
	lugar                varchar(50)  NULL ,
	comeco               datetime  NULL ,
	final                datetime  NULL ,
	todo_dia             bit  NULL ,
	importancia          varchar(10)  NULL ,
	privado              bit  NULL ,
	comentarios          varchar(500)  NULL ,
	id_descricao         int  NULL ,
	id_usuario           char(10)  NULL 
)
go

ALTER TABLE REUNIAO
	ADD CONSTRAINT XPKREUNIAO PRIMARY KEY  CLUSTERED (id_reuniao ASC)
go

CREATE TABLE USUARIO
( 
	id_usuario           char(10)  NOT NULL ,
	nome                 varchar(50)  NULL ,
	sobrenome            varchar(50)  NULL ,
	data_nascimento      datetime  NULL ,
	email                varchar(50)  NULL ,
	senha                varchar(50)  NULL ,
	empresa              varchar(50)  NULL ,
	telefone             char(15)  NULL ,
	perfil               text  NULL ,
	mostrar_perfil       bit  NULL ,
	data_inscricao       datetime  NULL 
)
go

ALTER TABLE USUARIO
	ADD CONSTRAINT XPKUSUARIO PRIMARY KEY  CLUSTERED (id_usuario ASC)
go

ALTER TABLE REUNIAO
	ADD CONSTRAINT R_1 FOREIGN KEY (id_descricao) REFERENCES DESCRICAO(id_descricao)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
go

ALTER TABLE REUNIAO
	ADD CONSTRAINT R_2 FOREIGN KEY (id_usuario) REFERENCES USUARIO(id_usuario)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
go

/*
	Gerar automáticamente UsuarioID com a data atual e um 
	número correlativo
*/

if(object_id('dbo.fn_usuario_id', 'FN') is not null)
	drop function dbo.fn_usuario_id
go

create function fn_usuario_id(@hoje datetime)
	returns char(10)
as 
begin
	declare @usuario_id char(10)
	declare @prefixo char(8)
	declare @count int

	declare @existe bit

	set @count = 1
	set @existe = 1
	set @prefixo = cast(datepart(year, @hoje) as char(4)) + 
				right('00' + cast(datepart(month, @hoje) as char(2)), 2) + 
				right('00' + cast(datepart(day, @hoje) as char(2)), 2)

	--declaracao do cursor
	declare cursor_usuario_id cursor
	for 
		select id_usuario
		from usuario 
		where id_usuario like @prefixo + '%'
	
	--abrir cursor
	open cursor_usuario_id

	--posicionar apontador em primeiro registro
	fetch next from cursor_usuario_id into @usuario_id

	--recorrer os registros
	while(@existe = 1)
	begin
		if(@usuario_id = @prefixo + right('0' + cast(@count as char(2)), 2))
			set @count = @count + 1
		else
		begin
			set @existe = 0
			set @usuario_id = @prefixo + right('0' + cast(@count as char(2)), 2)
		end
		--posicionar apontador ao seguinte registro
		fetch next from cursor_usuario_id into @usuario_id
	end
	--fechar cursor
	close cursor_usuario_id
	--liberar a memoria do cursor
	deallocate cursor_usuario_id
	return @usuario_id
end

/*
	Restricoes default tabela reuniao
*/

alter table reuniao
add constraint df_reuniao_todo_dia default(0) for todo_dia

alter table reuniao
add constraint df_reuniao_importancia default('Normal') for importancia

alter table reuniao
add constraint df_reuniao_privado default(1) for privado

/*
	Restricoes default tabela usuario
*/

alter table usuario
add constraint df_usuario_id default(dbo.fn_usuario_id(getdate())) for id_usuario

alter table usuario
add constraint df_mostrar_perfil default(1) for mostrar_perfil

alter table usuario
add constraint df_data_inscricao default(getdate()) for data_inscricao
go

/*
	procedimento armazenado para controle de usuarios -
	listado de reunioes
*/

create procedure sp_listar_reunioes
(
	@codigo int
)
as
begin
	select r.id_reuniao as [Id], u.nome + ' ' + u.sobrenome as [Usuario], d.descricao as [Descricao],
	r.lugar as [Lugar], r.comeco as [Comeco], r.final as [Final], r.importancia as [Importancia]
from reuniao r
inner join descricao d
on r.id_descricao = d.id_descricao
inner join usuario u
on r.id_usuario = u.id_usuario
where r.id_reuniao = @codigo
end
go

if(object_id('dbo.fn_usuario_id', 'FN') is not null)
	drop function dbo.fn_usuario_id
go

create function fn_usuario_id(@hoje datetime)
	returns char(10)
as
begin	
	declare @usuario_id char(10)
	declare @count int
	declare @band bit
	declare @prefixo char(8)

	set @band = 1
	set @count = 1
	set @prefixo = cast(datepart(year, @hoje) as char(4)) + 
		right('00' + cast(datepart(month, @hoje) as char(2)), 2) + 
		right('00' + cast(datepart(day, @hoje) as char(2)), 2)

	if(@usuario_id = @prefixo + right('0' + cast(@count as char(2)), 2))
		set @count = @count +1
	else
	begin
		set @band = 0
		set @usuario_id = @prefixo + right('0' + cast(@count as char(2)), 2)
	end
	return @usuario_id	
end
go
