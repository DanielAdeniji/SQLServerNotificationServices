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

if object_id('[notificationServices].[vw_processContact]') is null
begin

	exec('create view [notificationServices].[vw_processContact] as select 1/0 as [shell] ')

end
go


/*

	exec sp_help '[notificationServices].[vw_processContact]'

	select * from [notificationServices].[vw_processContact]

*/

alter view [notificationServices].[vw_processContact]
as

	select 
			[processID] 
				= tblNSP.id

			, [processName]	
				= tblNSP.[processName]

			, [contactID] 
				= tblNSC.[id]

			, [contactName]	
				= tblNSC.[contactName]

			, [emailAddress]	
				= tblNSC.[emailAddress]


			, tblNSPC.[subscribedSuccessful]
		
			, tblNSPC.[subscribedFailure]
		
			--, [subscribedFailureNOT]
			--	= ~ tblNSPC.[subscribedFailure]

	from   [notificationServices].[process] tblNSP


	inner join [notificationServices].[processContact] tblNSPC
			on tblNSP.id = tblNSPC.[processID]



	inner join [notificationServices].[contact] tblNSC

			on tblNSPC.[contactID] = tblNSC.[id]


	where  tblNSP.[active] = 1

	and   tblNSC.[active] = 1
	
	and   tblNSPC.[active] = 1

go