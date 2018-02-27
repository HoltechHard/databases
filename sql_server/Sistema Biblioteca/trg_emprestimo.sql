/*
	TRIGGER PARA EFETIVAR EMPRESTIMOS DE LIVROS
*/

create trigger trg_emprestar
on emprestimo
for insert
as
begin
	declare @estado int
	declare @disponibilidade int
	
	set @estado = (
		select l.estado from leitor l
		inner join inserted i
		on i.cpf = l.cpf)
	set @disponibilidade = (
		select e.disponibilidade from exemplar e
		inner join inserted i
		on i.id_exemplar = e.id_exemplar)
	
	--estados leitor: [1] castigado | [2] indefinido | [3] com livro emprestado | [4] habilitado
	--estados disponibilidade: [1] emprestado | [2] disponivel

	if(@estado = 4 and @disponibilidade = 2)
	begin
		--atualizar estado leitor ==> [4] habilitado a [3] livro emprestado
		update leitor set estado = 3
		from leitor l
		inner join inserted i 
		on l.cpf = i.cpf
		--atualizar disponibilidade de exemplar ==> [2] disponibilidade | [1] emprestado
		update exemplar set disponibilidade = 1
		from exemplar e
		inner join inserted i 
		on e.id_exemplar = i.id_exemplar
	end
	else
	begin
		if(@disponibilidade = 1)
		begin
			raiserror('o exemplar nao esta disponivel', 10, 1)
			rollback transaction
		end

		if(@estado = 3)
		begin
			raiserror('o leitor possui livro emprestado', 10,  1)
			rollback transaction
		end

		if(@estado = 1)
		begin
			raiserror('o leitor esta castigado', 10, 1)
			rollback transaction
		end
	end		
end
go


/*
	TRIGGER PARA REALIZAR DEVOLUCAO DE LIVROS
*/

create trigger trg_devolver
on emprestimo
for update
as
begin
	declare @estado_livro int
	declare @data_devolucao datetime
	declare @data_entregado datetime

	set @estado_livro = (select estado from inserted)
	set @data_devolucao = (select data_devolucao from inserted)
	set @data_entregado = (select data_entrega from inserted)

	--estado do livro: [1] bom estado | [2] manchado | [3] rasgado | [4] perdido

	if(@estado_livro = 1)
	begin
		--livro devolvido atualiza disponibilidade: [1] emprestado => [2] disponivel
		update exemplar set disponibilidade = 2
		from exemplar e
		inner join inserted i 
		on e.id_exemplar = i.id_exemplar		

		--livro devolvido dentro da data de devolucao
		if(@data_entregado <= @data_devolucao)
		begin
			--leitor passa a estado de habilitado: [3] com livro emprestado ==> [4] habilitado
			update leitor set estado = 4
			from leitor l
			inner join inserted i 
			on l.cpf = i.cpf							
		end

		--livro devolvido fora da data de devolucao
		else
		begin
			--leitor passa a estado de castigado: [3] com livro emprestado ==> [1] castigado
			update leitor set estado = 1
			from leitor l
			inner join inserted i 
			on l.cpf = i.cpf
		end

		--livro devolvido atualiza estado: [1] bom estado | [2] manchado | [3] rasgado | [4] perdido 		
		update exemplar set estado = @estado_livro
		from inserted i
		inner join exemplar e
		on e.id_exemplar = i.id_exemplar
	end
	
	--tentativa de devolver livros em mal estado
	else
	begin
		raiserror('nao esta permitido entregar livros em mal estado', 10, 1)
		rollback transaction
	end

end

