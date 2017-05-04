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

/*

	drop function [notificationServices].[udfn_processContact]

*/

if object_id('[notificationServices].[udfn_getProcessContact]') is null
begin

	exec('create function [notificationServices].[udfn_getProcessContact]() returns varchar(8000) as begin return (1/0) end')

end
go


/*

	exec sp_help '[notificationServices].[vw_processContact]'

	select * from [notificationServices].[vw_processContact]

*/

alter function [notificationServices].[udfn_getProcessContact]
(
	  @processID    int
	, @fieldname    sysname = 'emailAddress'
	, @delimeter    char(1) = ';'
	, @success		bit = null

)
returns varchar(8000)
as
begin

	declare @result varchar(8000)

	; with cte
	(
		[value]
	)
	as
	(
		select 
				case
					when @fieldname = 'contact' then vwPC.[contactName]
					else vwPC.[emailAddress]
				end
		
		from   [notificationServices].[vw_processContact] vwPC
	
		where  vwPC.[processID] = @processID

		and    (

						   (
								    ( vwPC.[subscribedSuccessful] = 1 )
								
								and ( @success = 1 )

							)

	
					or			

						   (
								    ( vwPC.[subscribedFailure] = 1 )
								
								and ( @success = 0 )

							)

					or (
							( @success is null )

					  )


				)
	
	)

		select @result
				= STUFF
				  (
					  (
						  SELECT @delimeter + ' ' + [value] 
						  from   cte
						  FOR XML PATH('')
					  )
					  , 1
			   		  , 1
					  , ''
				  )

	return (@result)

end
go


/*


	declare @processID    int = 1
	declare @fieldname    sysname = 'emailAddress'
	declare @delimeter    varchar(30) = ';'

	declare @sucess		  bit = 1


	select
			[subscription]
			  = [notificationServices].[udfn_getProcessContact]
				(
					  @processID  
					, @fieldname 
					, @delimeter
					, @sucess	
				) 



*/