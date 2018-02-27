use AdventureWorks2012
go

/*
	procedimentos armazenados aplicados a triggers
*/

exec sp_depends @objname = N'Sales.SalesOrderDetail'

exec sp_help 'Sales.iduSalesOrderDetail'

exec sp_helptext 'Sales.iduSalesOrderDetail'

/*
	Criar trigger para controle de cadastro de pessoal de 
	vendas eliminado
*/

select *
into Pessoas
from Sales.SalesPerson

select * from Pessoas

create table Sales.SalesPersonDeleted
(
	codigo		int identity(1,1) primary key,
	data_hora	datetime,
	pessoa		varchar(50),
	registros	int
)

select * from Sales.SalesPersonDeleted
go

drop trigger trg_person_deleted
go

create trigger trg_person_deleted
on Pessoas
for delete
as
	insert into Sales.SalesPersonDeleted(data_hora, pessoa, registros)
	values(getdate(), '', @@ROWCOUNT)
go

select * from Pessoas
delete from Pessoas where CommissionPct = 0.01
delete from Pessoas where BusinessEntityID = 274
select * from Sales.SalesPersonDeleted
go
