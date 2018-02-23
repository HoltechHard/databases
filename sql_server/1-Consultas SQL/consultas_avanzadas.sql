/*
				--- BASE DE DADOS ADVENTURE WORKS ---
*/

use AdventureWorks2012
go

/*
	Construcao de uma tabela derivada
*/

select temporal.SalesOrderID, temporal.CustomerID
from (
	select SalesOrderID, CustomerID
	from Sales.SalesOrderHeader
) as temporal

/*
	Mostrar nome, preco de lista, promedio e diferenca com relacao a
	media de todos os produtos que pertencam a Linha T
*/

select Name, ListPrice, 
	(select avg(ListPrice) from Production.Product) as Promedio,
	ListPrice - (select avg(ListPrice) from Production.Product) as Diferenca
from Production.Product
where ProductLine = 'T'

/*
	Listar as ordens de venda dos clientes que pediram mais de 3 unidades do produto '777'
*/

select oh.SalesOrderID, oh.CustomerID
from Sales.SalesOrderHeader oh
where (select od.OrderQty
	from Sales.SalesOrderDetail od
	where od.ProductID = '777' and 
		od.SalesOrderID = oh.SalesOrderID)>3

/*
	Listar os produtos e o pedido maior realizado até a 
	data de cada produto da tabela SalesOrderDetails
*/

select distinct od.ProductID, od.OrderQty
from Sales.SalesOrderDetail od
where od.OrderQty = (
	select max(od1.OrderQty)
	from Sales.SalesOrderDetail od1
	where od1.ProductID = od.ProductID)
order by od.ProductID asc

--outra forma
select od.ProductID, max(od.OrderQty) as [MaximoPedido]
from Sales.SalesOrderDetail od
group by od.ProductID
order by od.ProductID asc

/*
	Mostrar os nomes dos produtos e suas categorias
*/

select p.Name as [Produto], c.Name as [Categoria]
from Production.Product p
inner join Production.ProductCategory c
on c.ProductCategoryID = p.ProductID

/*
	Mostrar todos os produtos, ainda quando nao se
	tenha feito nenhuma revisao deles
*/

select p.Name as [Produto], pr.ProductReviewID as [Revisao]
from Production.Product p
left outer join Production.ProductReview pr
on p.ProductID = pr.ProductID

/*
	Mostrar todos os produtos, mais descartar os que 
	nao tenham feito alguma revisao sobre eles
*/

select p.Name as [Produto], pr.ProductReviewID as [Revisao]
from Production.Product p
left join Production.ProductReview pr
on p.ProductID = pr.ProductID
where pr.ProductReviewID is not null

/*
	Mostrar todos os vendedores, ainda quando nao pertencam 
	a um territorio
*/

select st.Name as [Territorio], sp.BusinessEntityID as [Vendedor]
from Sales.SalesTerritory st
right outer join Sales.SalesPerson sp
on st.TerritoryID = sp.TerritoryID

/*
	Mostrar todos os vendedores, mais descartar os que nao 
	pertencam a um territorio
*/

select t.Name as [Territorio], p.BusinessEntityID as [Vendedor]
from Sales.SalesTerritory t
right join Sales.SalesPerson p
on t.TerritoryID = p.TerritoryID
where t.TerritoryID is not null


/*
	Mostrar todos os produtos, seja que produtos que nao tenham pedido de venda,
	ou pedidos de venda que nao tenham produtos
*/

select p.Name as [Produto], od.SalesOrderDetailID as [Order]
from Production.Product p
full outer join Sales.SalesOrderDetail od
on p.ProductID = od.ProductID
order by p.Name

/*
	Mostrar todos os vendedores e os territorios
*/

select sp.BusinessEntityID as [Vendedor], st.Name as [Territorio]
from Sales.SalesPerson sp, Sales.SalesTerritory st

/*
	Mostrar o primeiro e ultimo nome do pessoal de recursos humanos
	e de vendas unificado em uma única lista que classifique como
	'RH' <recursos humanos> e 'PV' <pessoal de vendas> e calcule
	os salários
*/

select p.FirstName + ' ' + p.LastName as [Pessoa], 'RH' as [Tipo], 
	hr.SickLeaveHours * hr.VacationHours as [Salario]
from HumanResources.Employee hr
inner join Person.Person p
on p.BusinessEntityID = hr.BusinessEntityID
union (
	select p.FirstName + ' ' + p.LastName as [Pessoa], 'PV' as [Tipo],
		round(pv.CommissionPct * pv.SalesYTD + pv.Bonus, 2) as [Salario]
	from Sales.SalesPerson pv
	inner join Person.Person p
	on pv.BusinessEntityID = p.BusinessEntityID
)
order by [Salario] desc


/*
					--- BASE DE DADOS NORTHWIND ---
*/

use Northwind
go

/*
	Lista de empregados que ordenaram produtos no mes de 
	janeiro ou fevereiro do ano 1997
*/

select distinct(e.FirstName + ' ' + e.LastName) as [Empregado]
from Employees e 
inner join Orders o 
on e.EmployeeID = o.EmployeeID
where datepart(year, o.OrderDate) = '1997' and 
	datepart(month, o.OrderDate) between 1 and 2

/*
	Listar os produtos que nao pertencem a categoria 
	de Beverages ou Condiments
*/

select p.ProductName
from Products p 
inner join Categories c
on c.CategoryID = p.CategoryID
where c.CategoryName != 'Beverages' or c.CategoryName != 'Condiments'

/*
	Listar produtos que pertencem a categorias de 
	Beverages, Condiments ou Confections
*/

select p.ProductName
from Products p
inner join Categories c
on c.CategoryID = p.CategoryID
where c.CategoryName in ('Beverages', 'Condiments', 'Confections')

/*
	Selecionar o nome dos produtos que sao da categoria 'Condiments'	
*/

select p.ProductName
from Products p
where p.CategoryID = (
	select CategoryID
	from Categories c
	where c.CategoryName = 'Condiments')

/*
	Cursor para cadastro do stock de produtos
*/

use AdventureWorks2012
go

--declaracao de variaveis de manipulacao de filas
declare @produto as varchar(50), @stock as smallint
--declaracao do cursor
declare cursor_stock cursor
for
	select p.Name as [Produto], p.SafetyStockLevel as [Stock]
	from Production.Product p
	where p.Class = 'L'
--abrir cursor
open cursor_stock 
--apontar na primeira fila de registros
fetch next from cursor_stock into @produto, @stock
--percorrer linhas do cursor
while(@@FETCH_STATUS = 0)
begin
	--execucao de operacoes
	print(@produto + ' ==> ' + cast(@stock as varchar(10)) + ' ')
	--apontar ao proximo registro
	fetch next from cursor_stock into @produto, @stock
end
--fechar cursor
close cursor_stock
--liberar espaco de memoria do cursor
deallocate cursor_stock
