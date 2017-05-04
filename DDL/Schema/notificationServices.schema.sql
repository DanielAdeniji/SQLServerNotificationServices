use [AdminDB]
go

if schema_id('notificationServices') is null
begin

	exec('create schema [notificationServices] authorization [dbo]; ');

end
go