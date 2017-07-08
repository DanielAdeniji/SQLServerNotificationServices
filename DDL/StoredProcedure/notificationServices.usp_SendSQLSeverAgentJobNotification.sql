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

	drop function [notificationServices].[usp_SendSQLSeverAgentJobNotification] 

*/

if object_id('[notificationServices].[usp_SendSQLSeverAgentJobNotification]') is null
begin

	exec('create procedure [notificationServices].[usp_SendSQLSeverAgentJobNotification] as print ''stub'' ')

end
go

alter procedure [notificationServices].[usp_SendSQLSeverAgentJobNotification] 
(
	    @processID      int
	  , @job			sysname
	  , @subject		sysname = null

)
as
begin

	declare @profileID	  int
	declare @profileName  sysname = null

	declare @RC			  int

	declare @success	  bit = null
			
	declare @body		  nvarchar(4000) = null

	declare @strLog		 nvarchar(600)	

	declare @FORMAT_JOB_NOT_REGISTERED varchar(600);
	declare @FORMAT_JOB_NOT_RAN varchar(600);

	set @FORMAT_JOB_NOT_REGISTERED = 'Did not find matching entries in [msdb].[dbo].[sysjobs] for Job ''%s'' ';
	set @FORMAT_JOB_NOT_RAN = 'Did not find matching entries in [msdb].[dbo].[sysjobhistory] for Job ''%s'' ';

	if not exists
	(
		select *
		from   [msdb].[dbo].sysjobs tblSJ
		where  tblSJ.[name] = @job
	)
	begin

		exec master.dbo.xp_sprintf
				    @strLog output
				 , @FORMAT_JOB_NOT_REGISTERED
				 , @job

		raiserror(@strLog, 16,1)

		return (-2)

	end

	select 
			  @success  = itvf.runStatus
			, @body = itvf.[formattedMessage]
			, @subject = coalesce
							(
								  @subject
								, @job
							)
	from   [master].[notificationServices].[itvf_JobHistoryInfoLastRun] 
			(
				  @job
				, default
			) itvf

	if (@body is null)
	begin

		exec master.dbo.xp_sprintf
				    @strLog output
				 , @FORMAT_JOB_NOT_RAN
				 , @job

		raiserror(@strLog, 16,1)

		return (-1)

	end

	EXECUTE @RC = [notificationServices].[usp_SendMailNotification] 
					    @processID
					  , @success
					  , @subject
					  , @body
					  , @profileName = @profileName output

	print '@profileName :- ' + isNull(@profileName, '')


end

go

grant execute on [notificationServices].[usp_SendMailNotification] to [public]
go


/*

	declare @processID int
	declare @job sysname

	set @processID =1
	set @job = 'Redwood ICON DatabaseMgmt'

	begin tran

		exec [notificationServices].[usp_SendSQLSeverAgentJobNotification] 
				   @processID =  @processID
				 , @job = @job

	rollback tran


*/

