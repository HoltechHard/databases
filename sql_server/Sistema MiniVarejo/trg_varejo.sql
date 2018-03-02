use BDVarejo
go

/*
	TRIGGERS PARA REGRAS DE NEGÓCIO DE VENDAS, COMPRAS E FOLHA DE PAGAMENTO
*/

/*
	REGRA DE NEGOCIO DE VENDAS
	---------------------------
- ao insertar um detalhe_venda: 
	- atualizar subtotal do detalhe_venda
	detalhe_venda.subtotal = (1 + detalhe_venda.icms/100) * (produto.preco_venda * detalhe_venda.quantidade)
	- atualizar stock do produto
	if(detalhe_venda.quantidade <= produto.stock_atual)
		produto.stock_atual = produto.stock_atual - detalhe_venda.quantidade
				where produto.id_produto = detalhe_venda.id_produto
	if(produto.stock_atual < produto.stock_minimo)
		mensagem: 'será necessario realizar compras para manter o stock'
	- atualizar total da venda
	vendas.total = vendas.total [inicializa em 0.0] + detalhe_venda.subtotal 
					where detalhe_venda.id_venda = venda.id_venda	
	
- ao atualizar vendas:
	vendedor.vendas = vendedor.vendas [inicializa em 0.0] + vendas.total
					where vendedor.id_vendedor = vendas.id_vendedor	
	[01 do mes do getdate()]
	vendedor.salario_total = vendedor.salario_fixo
	[01 do mes até ultimo dia do mes]	
	if(vendedor.vendas < vendedor.meta) 
		vendedor.salario_total = vendedor.salario_fixo + 
			(vendedor.comissao/100) * vendedor.meta
	else
		vendedor.salario_total = vendedor.salario_fixo + 
			(vendedor.comissao/100) * vendedor.meta + (vendedor.bonificacao/100) * (vendedor.salario_fixo)
				 
*/

--trigger com ocorrencias ao insertar detalhe_venda

if(object_id('trg_dvenda_i','tr') is not null)
	drop trigger trg_dvenda_i
go

create trigger trg_dvenda_i
on detalhe_venda
for insert
as
begin
	--calcular subtotal no detalhe_venda
	update detalhe_venda set subtotal = (p.preco_venda * dv.quantidade) * (1 + dv.icms/100)
	from detalhe_venda dv
	inner join produto p
	on dv.id_produto = p.id_produto
	where dv.id_venda in (select id_venda from inserted) and 
		dv.id_produto in (select id_produto from inserted)

	--diminuir stock_atual do produto
	declare @stock_atual int, @stock_min int, @quantidade int
	set @stock_atual = (select stock_atual from produto p
						inner join inserted i 
						on p.id_produto = i.id_produto)
	set @stock_min = (select stock_minimo from produto p 
						inner join inserted i 
						on p.id_produto = i.id_produto)
	set @quantidade = (select quantidade from inserted)
	
	if(@quantidade <= @stock_atual)
	begin
		set @stock_atual = @stock_atual - @quantidade		
		update produto set stock_atual = @stock_atual
		from produto p 
		inner join inserted i
		on p.id_produto = i.id_produto				

		if(@stock_atual < @stock_min)
			print('Advertencia! É necessário aumentar as existencias do produto')
	end
	else
	begin
		raiserror('A quantidade pedida excede as existencias do produto', 10, 1)
		rollback transaction		
	end
end
go

--trigger com ocorrencias ao atualizar detalhe_venda
if(object_id('trg_dvenda_u', 'tr') is not null)
	drop trigger trg_dvenda_u
go

create trigger trg_dvenda_u
on detalhe_venda
for update
as
begin
	declare @subt decimal(8,2)
	set @subt = (select subtotal from inserted)

	--atualizar total de vendas do vendedor
	update vendas set total = total + @subt
	from vendas v
	inner join inserted i 
	on v.id_venda = i.id_venda

end

--trigger com ocorrencias ao atualizar vendas
if(object_id('trg_vendas_u', 'tr') is not null)
	drop trigger trg_vendas_u
go

create trigger trg_vendas_u
on vendas
for update
as
begin
	declare @t_vend decimal(12, 2), @meta decimal(12,2), @vendas decimal(12, 2)
	set @t_vend = (select grupo.vendas from
					(select v.id_vendedor, sum(v.total) as [vendas]
					from vendas v
					inner join inserted i 
					on v.id_vendedor = i.id_vendedor
					where v.id_vendedor = i.id_vendedor
					group by v.id_vendedor) as grupo)	
	
	update vendedor set vendas = @t_vend
	from vendedor v
	inner join inserted i 
	on v.id_vendedor = i.id_vendedor

	--atualizar salario_total do vendedor
	set @meta = (select v.meta from vendedor v
				  inner join inserted i
				  on v.id_vendedor = i.id_vendedor)
	set @vendas = (select v.vendas from vendedor v
					inner join inserted i
					on v.id_vendedor = i.id_vendedor)
	if(@vendas<=@meta)
	begin
		update vendedor set salario_total = salario_fixo + (comissao/100) * vendas
		from vendedor v
		inner join inserted i 
		on v.id_vendedor = i.id_vendedor
	end
	else
	begin
		update vendedor set salario_total = salario_fixo + (comissao/100) * vendas + 
								(bonificacao/100) * salario_fixo
		from vendedor v
		inner join inserted i 
		on v.id_vendedor = i.id_vendedor
	end
end
go

--constaint default para tabela vendas
alter table vendas
add constraint DF_data default(getdate()) for data

alter table vendas
add constraint DF_total default(0.0) for total

--constraint default para tabela detalhe_venda
alter table detalhe_venda
add constraint DF_subtotal default(0.0) for subtotal

alter table detalhe_venda
add constraint DF_icms default(17.0) for icms

/*
		--- fase de testes dos triggers de vendas do BDVarejo ---
*/


select * from vendas
select * from detalhe_venda

--venda [1000]
select * from vendas

insert into vendas(id_vendedor, id_empresa)
values(10, 128)

--detalhe_venda [1000]
select * from detalhe_venda

insert into detalhe_venda(id_venda, id_produto, quantidade)
values(1000, 1001, 40)

insert into detalhe_venda(id_venda, id_produto, quantidade)
values(1000, 1002, 10)

--venda [1001]
select * from vendas

insert into vendas(id_vendedor, id_empresa)
values(11, 145)

--detalhe_venda [1001]
select * from detalhe_venda

insert into detalhe_venda(id_venda, id_produto, quantidade)
values(1001, 1001, 25)

insert into detalhe_venda(id_venda, id_produto, quantidade)
values(1001, 1002, 15)

--vendas [1002]
select * from vendas

insert vendas(id_vendedor, id_empresa)
values(11, 130)

--detalhe_venda [1002]
select * from detalhe_venda

insert into detalhe_venda(id_venda, id_produto, quantidade)
values(1002, 1003, 31)

insert into detalhe_venda(id_venda, id_produto, quantidade)
values(1002, 1004, 7)

-- Venda [1003]
select * from vendas

insert into vendas(id_vendedor, id_empresa)
values(12, 109)

-- detalhe_venda [1003]
select * from detalhe_venda order by id_venda asc, id_produto asc

insert into detalhe_venda(id_venda, id_produto, quantidade)
values(1003, 1001, 26)

insert into detalhe_venda(id_venda, id_produto, quantidade)
values(1003, 1004, 30)

insert into detalhe_venda(id_venda, id_produto, quantidade)
values(1003, 1005, 25)

insert into detalhe_venda(id_venda, id_produto, quantidade)
values(1003, 1006, 17)

insert into detalhe_venda(id_venda, id_produto, quantidade)
values(1003, 1007, 240)


/*
	REGRA DE NEGOCIO DE COMPRAS
	----------------------------
- ao insertar um detalhe_compra
	- atualizar subtotal do detalhe_compra
		if(produto.stock_atual + detalhe_compra.quantidade <= produto.stock_maximo)
		detalhe_compra.subtotal = detalhe_compra.subtotal + 
			detalhe_compra.quantidade * produto.preco_compra
		else
			mensagem 'compra excede a capacidade de stock_maximo'
	- atualizar o stock_atual do produto
		produto.stock_atual = produto.stock_atual + detalhe_compra.quantidade

- ao atualizar um detalhe_compra
	- atualizar compra
		if(compra.data_entrega >= compra.data_recepcao)
			compra.total = [(compra.total + subtotal) + custo_frete] * (1 + taxa_importacao/100)
			where compra.id_compra = detalhe_compra.id_compra

- ao atualizar compra
	- atualizar provedor
		provedor.compras = sum(total) from compras 
			where compras.id_empresa = provedor.id_empresa and estado = 1

- ao atualizar provedor
	- atualizar pais
	pais.total_exportacao = sum(compras) from provedor
		where pais.id_pais = provedor.id_pais
*/


--trigger com ocorrencias ao insertar detalhe_compra

if(object_id('trg_dcompra_i', 'tr') is not null)
	drop trigger trg_dcompra_i
go

create trigger trg_dcompra_i
on detalhe_compra 
for insert
as
begin
	declare @stock_at int, @stock_max int, @qtd_compra int

	set @stock_at = (select stock_atual from produto p
					 inner join inserted i 
					 on p.id_produto = i.id_produto)
	set @stock_max = (select p.stock_maximo from produto p
					  inner join inserted i
					  on p.id_produto = i.id_produto)
	set @qtd_compra = (select quantidade from inserted)					

	if(@stock_at + @qtd_compra <= @stock_max)
	begin		
		--atualizacao do stock de produtos
		update produto set stock_atual = stock_atual + @qtd_compra
		from produto p 
		inner join inserted i 
		on p.id_produto = i.id_produto
		
		--atualizacao do subtotal
		update detalhe_compra set subtotal = subtotal + dc.quantidade * p.preco_compra
		from detalhe_compra dc
		inner join produto p
		on dc.id_produto = p.id_produto
		where dc.id_compra in (select id_compra from inserted) and
			  dc.id_produto in (select id_produto from inserted)
	end

	else
	begin
		raiserror('A compra excede a capacidade máxima de stock do produto', 10, 1)
		rollback transaction
	end
end

--trigger com ocorrencias ao atualizar detalhe_compra

if(object_id('trg_dcompra_u', 'tr') is not null)
	drop trigger trg_dcompra_u
go

create trigger trg_dcompra_u
on detalhe_compra
for update
as
begin	
	declare @d_entrega datetime, @d_recepcao datetime, @subt decimal(8, 2)

	set @d_entrega = (select c.data_entrega from compra c
					   inner join inserted i 
					   on c.id_compra = i.id_compra)
	set @d_recepcao = (select c.data_recepcao from compra c
						inner join inserted i 
						on c.id_compra = i.id_compra)
	set @subt = (select subtotal from inserted)	

	if(@d_entrega>= @d_recepcao)
	begin
		update compra set total = total + (@subt + pr.custo_frete) * (1 + p.taxa_importacao/100)
		from compra c
		inner join inserted i 
		on c.id_compra = i.id_compra
		inner join provedor pr
		on c.id_empresa = pr.id_empresa
		inner join pais p
		on pr.id_pais = p.id_pais
	end
	else
	begin
		raiserror('A compra feita com atraso nao é admitida', 10, 1)
		rollback transaction
	end	
end

--trigger com ocorrencias ao atualizar compras

if(object_id('trg_compras_u', 'tr') is not null)
	drop trigger trg_compras_u
go

create trigger trg_compras_u
on compra
for update
as
begin
	declare @t_prov decimal(12, 2)	
	set @t_prov = (
		select grupo.compras from 
			(select c.id_empresa, sum(c.total) as [compras]
			from compra c 
			inner join inserted i 
			on c.id_compra = i.id_compra
			inner join provedor pr
			on c.id_empresa = pr.id_empresa
			where c.id_empresa = i.id_empresa
			group by c.id_empresa) as grupo)

	update provedor set compras = @t_prov
	from provedor pr
	inner join inserted i 
	on pr.id_empresa = i.id_empresa
end

-- trigger com ocorrencias ao atualizar provedor

if(object_id('trg_provedor_u', 'tr') is not null)
	drop trigger trg_provedor_u
go

create trigger trg_provedor_u
on provedor 
for update
as
begin
	declare @t_exp decimal(12, 2)

	set @t_exp = (select grupo.compras from 
		(select pr.id_pais, sum(pr.compras) as [compras]
		from provedor pr
		inner join inserted i 
		on pr.id_empresa = i.id_empresa
		inner join pais p 
		on p.id_pais = pr.id_pais
		where pr.id_empresa = i.id_empresa
		group by pr.id_pais) as grupo)

	update pais set total_exportacao = @t_exp * p.taxa_importacao
	from pais p 
	inner join inserted i
	on p.id_pais = i.id_pais
end

--constraint para total_exportacao de um pais
alter table pais
add constraint DF_cexportacao default(0.0) for total_exportacao

--constraint para compras do provedor
alter table provedor
add constraint DF_ccompras default(0.0) for compras

--constraint para total de compras
alter table compra
add constraint DF_ctotal default(0.0) for total

--constraint para estado da compra
alter table compra 
add constraint DF_cestado default(1) for estado

--constraint para subtotal do detalhe_compra
alter table detalhe_compra
add constraint DF_csubtotal default(0.0) for subtotal

/*
			--- fase de testes dos triggers de compras do BDVarejo ---
*/

-- compra [1000]
select * from compra

insert into compra(data_compra, data_entrega, data_recepcao, id_empresa)
values(dateadd(day, -10, getdate()), getdate(), dateadd(day, -5, getdate()), 154)

--detalhe_compra [1000]
select * from detalhe_compra

insert into detalhe_compra(id_compra, id_produto, quantidade)
values(1000, 1001, 20)

insert into detalhe_compra(id_compra, id_produto, quantidade)
values(1000, 1002, 7)
