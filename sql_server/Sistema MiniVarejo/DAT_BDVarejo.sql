/*
	Dados do banco de dados BDVarejo
*/

use BDVarejo
go

-- Tabela Pais

declare @i_pais int, @al_taxa decimal(4,2)
set @i_pais = 1

while @i_pais<= (select max(id_pais) from pais)
begin
	set @al_taxa = round(10 + rand() * (60-10), 2)
	update pais set taxa_importacao = @al_taxa
	where id_pais = @i_pais
	
	set @i_pais = @i_pais + 1
end

select * from pais

-- Tabela Regiao

insert into regiao(descricao)
select distinct região from Hoja1$

select * from Regiao

-- Tabela Estado

insert into estado(descricao, sigla, id_regiao)
select h.Estado, h.Sigla, r.id_regiao from Hoja1$ h
inner join regiao r
on r.descricao = h.Região

select * from estado

-- Tabela Cidade

insert into cidade(descricao, id_estado)
select h.Capital, e.id_estado from Hoja1$ h
inner join estado e
on e.descricao = h.Estado

select * from cidade

-- Tabela Sucursal

declare @i_sucursal int
set @i_sucursal = 1

while @i_sucursal <= 200
begin
	insert into sucursal(nome, id_cidade)
	values('LOC-' + right('000' + cast(@i_sucursal as char(3)), 3), 
		(select top 1 id_cidade from cidade order by newid()))
			
	set @i_sucursal = @i_sucursal + 1
end

select * from sucursal

-- Tabela Funcao

insert into funcao(descricao) values
('Gerente'), ('Supervisor'), ('Operador'), ('Técnico'), ('Estagio'), ('Trainee')

select * from funcao

-- Tabela Vendedor

insert into vendedor(nome, sobrenome)
select top 100 Nombres, ApellidoPaterno + ' ' + ApellidoMaterno 
from HidrandinaOLTP_VF.dbo.cliente

--atualizacao de dados segundo regras do negocio usando cursor
/*
	funcao  ---		meta	  ---  salario_fixo		--- comissao    --- bonificacao
	[1-2]		 [100 000]		   [15 000]				2% * vendas		10% * salario
	[3-4]		 [25 000]		   [5 000]				1%				7%
	[5-6]		 [5 000]           [1 500]				0.5%			5%
*/

declare @i_vendedor int, @al_funcao int, @meta decimal(8,2), @cpf char(18), 
	@al_sucursal int, @salario_fixo decimal(7,2)

--declarar cursor
declare cursor_vendedor cursor
for
	select id_vendedor from vendedor

--abrir cursor
open cursor_vendedor

--apontar cursor ao primeiro registro
fetch next from cursor_vendedor into @i_vendedor

--percurso pela tabela vendedor
while(@@FETCH_STATUS = 0)
begin
	set @al_funcao = (select top 1 id_funcao from funcao order by newid())
	set @al_sucursal = (select top 1 id_sucursal from sucursal order by newid())

	update vendedor set id_funcao = @al_funcao, id_sucursal = @al_sucursal, 
		cpf = cast(round(100 + rand() * (999-100-1), 0) as char(3)) + '.' +
			cast(round(100 + rand() * (999-100-1), 0) as char(3)) + '.' + 
			cast(round(100 + rand() * (999-100-1), 0) as char(3)) + '-' + '0' +
			cast(round(0 + rand() * (9-0-1), 0) as char(1))
	where id_vendedor = @i_vendedor

	if(@al_funcao = 1 or @al_funcao = 2)
	begin
		--meta e salario fixo com minimos establecidos + [10, 30]% do valor
		update vendedor set meta = 100000 * (1 + round(10 + rand() * (30-10-1), 0)/100),
			salario_fixo = 15000 * (1 + round(10 + rand() * (30-10-1), 0)/100), 
			comissao = 2, bonificacao = 10
		where id_vendedor = @i_vendedor
	end

	if(@al_funcao = 3 or @al_funcao = 4)
	begin
		--meta e salario fixo com minimos estabelecidos + [10, 30]% do valor
		update vendedor set meta = 25000 * (1 + round(10 + rand() * (30-10-1), 0)/100),
			salario_fixo = 5000 * (1 + round(10 + rand() * (30-10-1), 0)/100),
			comissao = 1, bonificacao = 7
		where id_vendedor = @i_vendedor
	end

	if(@al_funcao = 5 or @al_funcao = 6)
	begin
		--meta e salario fixo com minimos estabelecidos + [5, 10]% do valor
		update vendedor set meta = 5000 * (1 + round(5 + rand() * (10-5-1), 0)/ 100),
			salario_fixo = 1500 * (1 + round(5 + rand() * (10-5-1), 0)/100),
			comissao = 0.5, bonificacao = 5
		where id_vendedor = @i_vendedor
	end
	
	fetch next from cursor_vendedor into @i_vendedor
end

--fechar cursor 
close cursor_vendedor
--liberar espaco de memoria de cursor
deallocate cursor_vendedor

-- Tabela empresa

insert into empresa(corporacao, estado, tipo)
select Empresa, 1, case Tipo
	when 'Pessoal' then 'P'
	when 'Comercial' then 'C' end
from empresasx$

--cursor para insertar cnpj
declare @i_emp int, @al_cnpj char(20)
set @i_emp = (select min(id_empresa) from empresa)

while(@i_emp<= (select max(id_empresa) from empresa))
begin
	set @al_cnpj = cast(round(10 + rand() * (999-10-1) , 0) as char(3)) + '.' + 
		cast(round(100 + rand() * (999-100-1), 0) as char(3)) + '.' + 
		cast(round(100 + rand() * (999-100-1), 0) as char(3)) + '/' + '00' + 
		cast(round(10 + rand() * (99-10-1), 0) as char(2)) + '-' + '0' +
		cast(round(1 + rand() * (9-1-1), 0) as char(1))
	
	update empresa set cnpj = @al_cnpj
	where id_empresa = @i_emp

	set @i_emp = @i_emp + 1
end

select * from empresa


-- Tabela Cliente
-- Empresas de tipo C => [Cliente]

insert into cliente(id_empresa)
select id_empresa from empresa
where tipo = 'C'

--cursor para atualizar cliente
declare @i_cli int, @i_cid int

declare cursor_cliente cursor
for
	select id_empresa from cliente

open cursor_cliente

fetch next from cursor_cliente into @i_cli

while(@@FETCH_STATUS = 0)
begin
	set @i_cid = (select top 1 id_cidade from cidade order by newid())

	update cliente set id_cidade = @i_cid
	where id_empresa = @i_cli

	fetch next from cursor_cliente into @i_cli
end

close cursor_cliente
deallocate cursor_cliente

select * from cliente


--Tabela Provedor
-- Empresas de tipo P => [Provedor]

insert into provedor(id_empresa)
select id_empresa from empresa
where tipo = 'P'

select * from provedor

--cursor para atualizar provedor

declare @i_prov int, @al_pai int, @frete decimal(8,2)

declare cursor_provedor cursor
for
	select id_empresa from provedor

open cursor_provedor

fetch next from cursor_provedor into @i_prov

while(@@FETCH_STATUS = 0)
begin
	set @al_pai = (select top 1 id_pais from pais where id_pais<30 order by newid())
	set @frete = round(2500 + rand() * (7500-2500-1), 2)

	update provedor set id_pais = @al_pai, custo_frete = @frete
	where id_empresa = @i_prov

	fetch next from cursor_provedor into @i_prov
end

close cursor_provedor
deallocate cursor_provedor

select * from provedor

-- Tabela Linha de producao

insert into linha_producao(descricao)
select distinct Category from orders$

select * from linha_producao

-- Tabela Categoria

insert into categoria(descricao, id_linha)
select distinct o.[Sub-Category], l.id_linha from orders$ o
inner join linha_producao l
on l.descricao = o.Category

--cursor para atualizar taxa_lucro em categoria
declare @i_categoria int, @al_lucro decimal(4,2)

declare cursor_categoria cursor
for
	select id_categoria from categoria

open cursor_categoria
fetch next from cursor_categoria into @i_categoria

while(@@FETCH_STATUS = 0)
begin
	set @al_lucro = round(10 + rand() * (40-10-1), 0)
	update categoria set taxa_lucro = @al_lucro
	where id_categoria = @i_categoria

	fetch next from cursor_categoria into @i_categoria
end

close cursor_categoria
deallocate cursor_categoria

select * from categoria

-- Tabela Produto

insert into produto(nome, id_categoria)
select distinct o.[Product Name], c.id_categoria from orders$ o
inner join categoria c
on c.descricao = o.[Sub-Category]

--cursor para atualizar produto
declare @i_produto int, @stock_min int, @stock_max int, 
	@preco_compra decimal(8, 2), @preco_venda decimal(8, 2), @taxa decimal(4,2)

declare cursor_produto cursor
for 
	select id_produto from produto

open cursor_produto
fetch next from cursor_produto into @i_produto

while(@@FETCH_STATUS = 0)
begin
	set @stock_min = round(50 + rand() * (100-50-1), 0)
	set @stock_max = round(400 + rand() * (500-400-1), 0)
	set @preco_compra = round(25 + rand() * (400-25-1), 2)
	set @taxa = (select c.taxa_lucro from categoria c
				 inner join produto p
				 on p.id_categoria = c.id_categoria
				 where p.id_produto = @i_produto)
	set @preco_venda = @preco_compra * (1 + @taxa/100)

	update produto set stock_minimo = @stock_min, stock_maximo = @stock_max, 
		stock_atual = @stock_max, preco_compra = @preco_compra, preco_venda = @preco_venda
	where id_produto = @i_produto

	fetch next from cursor_produto into @i_produto
end
close cursor_produto
deallocate cursor_produto

select * from produto
