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
	, @body			nvarchar(4000) = null
	, @profileName  sysname = null output
)
as
begin

	declare @subscriberList varchar(8000)

	
	declare @fieldname    sysname = 'emailAddress'
	declare @delimeter    char(1) = ';'

	declare @profileID	  int

	declare @username     sysname

	/*
		Get current user
	*/
	set @username = SYSTEM_USER

	set @subscriberList
			  = [notificationServices].[udfn_getProcessContact]
				(
					  @processID  
					, @fieldname 
					, @delimeter
					, @success	
				) 

	/*
		Get Profile ID - Private
	*/
	if (@profileName is null)
	begin

		select 
				top 1
				  @profileID = tblSMP.profile_id
				, @profileName = tblSMP.[name]

		from  [msdb].[dbo].[sysmail_profile] tblSMP

		inner join [msdb].[dbo].[sysmail_principalprofile] tblSMPP

			on tblSMP.[profile_id] = tblSMPP.profile_id

		inner join [sys].[database_principals] tblSDP

			on tblSMPP.principal_sid = tblSDP.[sid]

		where tblSDP.[name]	= @username

		order by
				tblSMPP.is_default desc


	end


	/*
		Get Profile ID - Public
	*/
	if (@profileName is null)
	begin

		select 
				top 1
				  @profileID = tblSMP.profile_id
				, @profileName = tblSMP.[name]

		from  [msdb].[dbo].[sysmail_profile] tblSMP

		inner join [msdb].[dbo].[sysmail_principalprofile] tblSMPP

			on tblSMP.[profile_id] = tblSMPP.profile_id

		inner join [sys].[database_principals] tblSDP

			on tblSMPP.principal_sid = tblSDP.[sid]

		where tblSDP.[name]	in ( 'guest', 'public')

		order by
				tblSMPP.is_default desc


	end


	if (@subscriberList is not null)
	begin

		exec [Master].[email].[sp_sendMail]

			  @profileName = @profileName
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
