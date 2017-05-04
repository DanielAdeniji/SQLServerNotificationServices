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

if object_id('[notificationServices].[processContact]') is not null
begin

	set noexec on;

end
go


/*

	drop table [notificationServices].[processContact];

	exec sp_help '[notificationServices].[processContact]'

	select * from[notificationServices].[processContact]
		
*/

create table [notificationServices].[processContact]
(

	  [id] int not null
			identity(1,1)

	, [processID] int not null

	, [contactID] int not null

	, [active]      bit     not null
		constraint [constraintDefaultNSProcessContactActive]
			default (1)

	, [subscribedSuccessful] bit     not null
		constraint [constraintDefaultNSProcessContactSubscribedSuccessful]
			default (1)


	, [subscribedFailure] bit     not null
		constraint [constraintDefaultNSProcessContactSubscribedFailure]
			default (1)

	, [addedBy]		sysname not null

		constraint [constraintDefaultNSProcessContactAddedBy]
			default SYSTEM_USER 

	, [addedOn]     datetime not null

		constraint [constraintDefaultNSProcessContactAddedOn]
			default getutcdate()

	, constraint [constraintPrimaryKeyProcessContact]
			primary key
			(
				  [processID]
				, [contactID]
			)

	, constraint [constraintForeignKeyProcess]
			foreign key
			(
				  [processID]
			)
			references [notificationServices].[process]
			(
			  [id]
			)
			on delete cascade
			on update cascade


	, constraint [constraintForeignKeyContact]
			foreign key
			(
				  [contactID]
			)
			references [notificationServices].[contact]
			(
			  [id]
			)
			on delete cascade
			on update cascade

)
go


set noexec off
go

