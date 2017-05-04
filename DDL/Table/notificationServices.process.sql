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

if object_id('[notificationServices].[process]') is not null
begin

	set noexec on;

end
go

/*

	drop table [notificationServices].[process];

	
/*

	drop table [notificationServices].[process];

	exec sp_help '[notificationServices].[process]'

*/

*/

create table [notificationServices].[process]
(

	  [id] int not null
			identity(1,1)

	, [processName] sysname not null

	, [active]      bit     not null
		constraint [constraintDefaultNSProcessActive]
			default (1)

	, [addedBy]		sysname not null

		constraint [constraintDefaultNSProcessAddedBy]
			default SYSTEM_USER 

	, [addedOn]     datetime not null

		constraint [constraintDefaultNSProcessAddedOn]
			default getutcdate()

	, constraint [constraintPrimaryKeyProcess]
			primary key
			(
				[id]
			)

	, constraint [constraintUniqueNSProcessName]
			unique
			(
				[processName]
			)

)
go


set noexec off
go

