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

if object_id('[notificationServices].[usp_SendMailNotification]') is null
begin

	exec('create procedure [notificationServices].[usp_SendMailNotification] as print ''stub'' ')

end
go

alter procedure [notificationServices].[usp_SendMailNotification] 
(
	  @processID    int
	, @success		bit = null
	, @subject		varchar(80) = null
	, @body			varchar(8000) = null
)
as
begin

	declare @subscriberList varchar(8000)

	
	declare @fieldname    sysname = 'emailAddress'
	declare @delimeter    char(1) = ';'

	set @subscriberList
			  = [notificationServices].[udfn_getProcessContact]
				(
					  @processID  
					, @fieldname 
					, @delimeter
					, @success	
				) 

	if (@subscriberList is not null)
	begin

		exec [Master].[email].[sp_sendMail]

			  @profileName = null
			, @recipients  = @subscriberList
			, @subject     = @subject
			, @body        = @body

	end
	else
	begin

		raiserror('Subscriber List is empty', 16, 1)

	end
end

go

grant execute on [notificationServices].[usp_SendMailNotification] to [public]
go

/*

	exec [notificationServices].[usp_SendMailNotification] 

		  @processID = 1
		, @success   = 1
		, @subject	 = 'DW Job Notification'
  	    , @body		 =  'Job Succeeded'


*/
