set noexec off;
set nocount on;
go

use [AdminDB]
go

if schema_id('notificationServices') is null
begin

	exec('create schema [notificationServices] authorization [dbo]; ');

end
go

if object_id('[notificationServices].[contact]') is not null
begin

	set noexec on;

end
go

/*

	drop table [notificationServices].[contact];

	exec sp_help '[notificationServices].[contact]'

*/

create table [notificationServices].[contact]
(

	  [id] int not null
			identity(1,1)

	, [contactName] sysname not null

	, [emailAddress] sysname not null

	, [active]      bit     not null
		constraint [constraintDefaultNScontactActive]
			default (1)

	, [addedBy]		sysname not null

		constraint [constraintDefaultNScontactAddedBy]
			default SYSTEM_USER 

	, [addedOn]     datetime not null

		constraint [constraintDefaultNScontactAddedOn]
			default getutcdate()

	, constraint [constraintPrimaryKeyContact]
			primary key
			(
				[id]
			)

	, constraint [constraintUniqueNSContactName]
			unique
			(
				[contactName]
			)


	, constraint [constraintUniqueNSEmailAddress]
			unique
			(
				[emailAddress]
			)

)
go


set noexec off
go
