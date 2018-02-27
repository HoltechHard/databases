use BDBiblioteca
go

/*
	Dados do banco de dados BDBilbioteca
*/

--tabela editorial

select * from editorial

insert into editorial values
('Atlas'), ('Agir'), ('Ateliê Editorial	'), ('Átomo & Alínea'), ('Betânia'),
('Brasiliense'), ('Companhia das Letras'), ('Ed. da FGV'), ('Ediouro'), ('Editora Campus')

--tabela autor

create table tbl_nacionalidade
(
	codigo int identity(1,1),
	nome varchar(30)
)

insert into tbl_nacionalidade(nome) values
('Peru'), ('Brasil'), ('Argentina'), ('Uruguai'), ('Paraguai'),
('Colombia'), ('Venezuela'), ('Equador'), ('Bolivia'), ('Chile')

select * from tbl_nacionalidade

declare @i int, @min_nac int, @max_nac int
set @i=1
set @min_nac = (select min(codigo) from tbl_nacionalidade)
set @max_nac = (select max(codigo) from tbl_nacionalidade)

while @i<500
begin
	insert into autor(nome, sobrenome, nacionalidade, qualificacao)
	values((select Nombres from HidrandinaOLTP_VF.dbo.Cliente where idCliente = @i), 
			(select ApellidoPaterno from HidrandinaOLTP_VF.dbo.Cliente where idCliente = @i),
			(select nome from tbl_nacionalidade where codigo = round(@min_nac + rand()* (@max_nac - @min_nac - 1), 0)),
			(select round(1 + rand() * (5 - 1 - 1), 0)))
	set @i = @i +1
end

select * from autor

--tabela leitor

declare @il int, @min_cent int, @max_cent int, @min_dec int, @max_dec int
set @il = 1
set @min_cent = 100
set @max_cent = 999
set @min_dec = 10
set @max_dec = 99

while @il <= 10000
begin
	insert into leitor(cpf, nome, sobrenome, telefone, celular, estado)
	values((select cast(round(@min_cent + rand() * (@max_cent - @min_cent - 1), 0) as char(3)) + '.' + 
			cast(round(@min_cent + rand() * (@max_cent - @min_cent - 1), 0) as char(3)) + '.' + 
			cast(round(@min_cent + rand() * (@max_cent - @min_cent - 1), 0) as char(3)) + '-' + 
			cast(round(@min_dec + rand() * (@max_dec - @min_dec - 1), 0) as char(2))), -- cpf
			(select Nombres from HidrandinaOLTP_VF.dbo.Cliente where idCliente = 1000 + @il),
			(select ApellidoPaterno from HidrandinaOLTP_VF.dbo.Cliente where idCliente = 1000 + @il),
			(select cast(round(@min_dec + rand() * (@max_dec - @min_dec - 1), 0) as char(2)) + '-' + 
				cast(round(@min_cent + rand() * (@max_cent - @min_cent - 1), 0) as char(3)) + '-' + 
				cast(round(@min_cent + rand() * (@max_cent - @min_cent - 1), 0) as char(3))), --telefone
			(select cast(round(@min_dec + rand() * (@max_dec - @min_dec - 1), 0) as char(2)) + '-' + 
				cast(round(@min_cent + rand() * (@max_cent - @min_cent - 1), 0) as char(3)) + '-' + 
				cast(round(@min_cent + rand() * (@max_cent -  @min_cent - 1), 0) as char(3))), 4
	)
	set @il = @il + 1
end

--cursor para atualizar dados de leitor

/*
	atributos especiais de leitor
	estado => 
	(1) castigado com prestimo fora do prazo 
	(2) leitor com prestimo indefinido
	(3) leitor com livro emprestado
	(4) leitor habilitado
*/

--delarar variaveis
declare @ixt int
declare @cpf char(15)

--declarar cursor
declare cursor_dat_leitor cursor
for 
	select cpf
	from leitor

--abrir cursor
open cursor_dat_leitor

--posicionar apontador no primeiro registro
fetch next from cursor_dat_leitor into @cpf

--percurso pelos registros
while(@@FETCH_STATUS = 0)
begin
	set @ixt = (select 1 + rand() * (99 - 1 - 1))

	if(@ixt%25 = 0)
	begin
		update leitor set estado = 1
		where cpf = @cpf
	end

	if(@ixt%100 = 0)
	begin
		update leitor set estado = 2
		where cpf = @cpf
	end

	if(@ixt%10 = 0)
	begin
		update leitor set estado = 3
		where cpf = @cpf
	end

	--posicionar apontador ao proximo registro
	fetch next from cursor_dat_leitor into @cpf
end

--fechar cursor
close cursor_dat_leitor

--liberar espaco de memoria para o cursor
deallocate cursor_dat_leitor

select * from leitor

--tabela livro

declare @ixl int, @min_edi int, @max_edi int
set @ixl = 1
set @min_edi = (select min(id_editorial) from editorial)
set @max_edi = (select max(id_editorial) from editorial)

while @ixl <=1000
begin
	insert into livro(id_editorial, isbn, paginas)
	values((select id_editorial from editorial where id_editorial = 
		round(@min_edi + rand() * (@max_edi - @min_edi - 1), 0)),
		(select cast(round(1000000000000 + rand() * (9999999999999 - 1000000000000 - 1), 0) as char(13))),
		(select round(100 + rand() * (500 - 100 - 1), 0)))
	set @ixl = @ixl + 1
end

select * from livro

--tabela detalhe_livro

declare @idl int, @min_livro int, @max_livro int, @min_autor int, @max_autor int
set @idl = 1
set @min_livro = (select min(id_livro) from livro)
set @max_livro = (select max(id_livro) from livro)
set @min_autor = (select min(id_autor) from autor)
set @max_autor = (select max(id_autor) from autor)

while @idl<=4000
begin
	insert into detalhe_livro(id_livro, id_autor)
	values(round(@min_livro + rand() * (@max_livro - @min_livro - 1), 0), 
			round(@min_autor + rand() * (@max_autor - @min_autor - 1), 0))
	set @idl = @idl + 1
end

select * from detalhe_livro

--tabela exemplar

declare @ixe int, @max_ixe int, @cant int, @control int
set @ixe = (select min(id_livro) from livro)
set @max_ixe = (select max(id_livro) from livro)

while @ixe<= @max_ixe
begin
	-- aleatorizando quantidade de exemplares x livro
	set @cant = round(1 + rand() * (20 - 1 - 1), 0) 
	set @control = 1
	while @control <= @cant
	begin
		insert into exemplar(id_exemplar, data_compra, disponibilidade, estado, id_livro)
		values('E' + cast(@ixe as char(4)) + '-' + substring('00' + cast(@control as char(2)), 3, 4), 
				cast(cast(round(2000 + rand() * (2017-2000-1), 0) as char(4)) + '-' + 
					cast(round(1 + rand() * (12-1-1), 0) as char(2)) + '-' + 
					cast(round(1 + rand() * (28-1-1), 0) as char(2)) as date), 2, 1, @ixe)
		set @control = @control + 1
	end
	set @ixe = @ixe + 1
end

--cursor para atualizar dados de exemplar

/*
	atributos de exemplar
	- disponibilidade =>  1 (emprestado) | 2 (disponivel)
	- estado => 1 (bom estado) | 2 (manchado) | 3 (rasgado) | 4 (perdido)
*/

--declaracao de variaveis
declare @ind int
declare @id_exemplar char(8)
set @ind = 1

--declaracao de cursor
declare cursor_dat_exemplar cursor
for 
	select id_exemplar
	from exemplar

--abrir cursor
open cursor_dat_exemplar

--posicionar apontador ao primeiro registro
fetch next from cursor_dat_exemplar into @id_exemplar

--percorrer os registros
while(@@FETCH_STATUS = 0)
begin
	if(@ind%5 = 0)
	begin
		update exemplar set disponibilidade = 1
		where id_exemplar = @id_exemplar
	end

	if(@ind%7 = 0)
	begin
		update exemplar set estado = 2
		where id_exemplar = @id_exemplar
	end		

	if(@ind%11 = 0)
	begin
		update exemplar set estado = 3
		where id_exemplar = @id_exemplar
	end
	
	if(@ind%101 = 0)
	begin
		update exemplar set estado = 4
		where id_exemplar = @id_exemplar
	end
	
	set @ind = @ind + 1

	--posicionar apontador a seguinte registro
	fetch next from cursor_dat_exemplar into @id_exemplar
end

--fechar cursor
close cursor_dat_exemplar
--liberar espaco de memoria do cursor
deallocate cursor_dat_exemplar

select * from exemplar

--tabela emprestimo

--tipo de emprestimo: [1] leitura em sala || [2] leitura domicilio

select * from emprestimo

select * from exemplar where disponibilidade = 1 --emprestado
select * from exemplar where disponibilidade = 2 --disponivel

select * from leitor where estado = 3 --possui livro emprestado
select * from leitor where estado = 4 --habilitado

/*
	cadastrar livros emprestados [1] sala | [2] domicilio
*/

--declaracao de variaveis
declare @iem int, @alt int, @exem char(8), @leit char(15), @datax datetime, @add int
set @iem = 1

--percurso pelos registros
while(@iem <= 500000)
begin
	set @alt = (select round(1 + rand() * (99-1-1), 0))

	--exemplar esta emprestado neste momento para leitura em sala
	if(@alt%10 = 0)
	begin
		--exemplar esta em condicao de emprestado
		set @exem = (select top 1 id_exemplar from exemplar where disponibilidade = 1 order by newid())
		--leitor possui um livro emprestado
		set @leit = (select top 1 cpf from leitor where estado = 3 order by newid())

		insert into emprestimo(id_emprestimo, id_exemplar, tipo, estado, 
			data_emprestimo, data_devolucao, data_entrega, id_livro, cpf)
		values(cast(100000 + @iem as char(6)) + '-' +cast(@alt as char(2)), @exem, 1, 
			(select estado from exemplar where id_exemplar = @exem), getdate(), getdate(), null, 
			(select id_livro from exemplar where id_exemplar = @exem), @leit)
	end

	--exemplar foi emprestado no passado para leitura a domicilio e ja voi devolvido
	if(@alt%4 = 0)
	begin
		--exemplar que atualmente está disponivel mais que no passado foi emprestado
		set @exem = (select top 1 id_exemplar from exemplar where disponibilidade = 2 order by newid())
		--leitor que está em estado habilitado mais que no passado esteve com livro emprestado
		set @leit = (select top 1 cpf from leitor where estado = 4 order by newid())
		--geracao de uma data aleatoria
		set @datax = cast(cast(round(2010 + rand() * (2017-2010-1), 0) as char(4)) + '-' +
			cast(round(1 + rand() * (12-1-1), 0) as char(2)) + '-' + 
			cast(round(1 + rand() * (28-1-1), 0) as char(2)) as datetime)
		--adicionar dias aleatorios para definir data de entrega
		set @add = round(1 + rand() * (21-1-1), 0)		

		insert into emprestimo(id_emprestimo, id_exemplar, tipo, estado, 
			data_emprestimo, data_devolucao, data_entrega, id_livro, cpf)
		values(cast(cast(100000 + @iem as char(6)) + '-' + cast(@alt as char(2)) as char(10)), @exem, 2, 
			(select estado from exemplar where id_exemplar = @exem), 
			 @datax, (select dateadd(day, 21, @datax)), (select dateadd(day, @add, @datax)), 
			 (select id_livro from exemplar where id_exemplar = @exem), @leit)		
	end

	set @iem = @iem + 1
end
go

select * from emprestimo

--pequena modificao para poder ter um indice autoincrementavel tabela exemplar

alter table exemplar
add indice int identity(1,1)
