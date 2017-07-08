use [master]
go

/*
	drop function [dbo].[udfn_getJobHistoryInfoLastRun];
*/

if object_id('[dbo].[udfn_getJobHistoryInfoLastRun]') is not null
begin

	drop function [dbo].[udfn_getJobHistoryInfoLastRun]
end
go

if object_id('[notificationServices].[udfn_getJobHistoryInfoLastRun]') is null
begin

	exec('create function [notificationServices].[udfn_getJobHistoryInfoLastRun]() returns bit begin return (1/0) end ');
end
go


alter function [notificationServices].[udfn_getJobHistoryInfoLastRun]
(
	  @jobName sysname
	, @datetimeformat smallint = 100
) 
returns nvarchar(4000)
begin

	return
	(

		select top 1
				FORMATMESSAGE
						(
							  + 'SQL Server Instance :- %s ' + char(13) + char(10)
							  +	'Job :- %s' + char(13) + char(10)
							  + 'Start Date :- %s' + char(13) + char(10)
							  + 'Run Status :- %s' + char(13) + char(10)
							  + 'Duration (HH:MM:SS) :- %s' + char(13) + char(10)
							  + 'SQL Message ID :- %i' + char(13) + char(10)
							  + 'SQL Message :- %s' + char(13) + char(10)
							, cast(serverproperty('servername') as sysname)
							, tblSJ.[name]
							, convert
								(
									  varchar(30)
									, msdb.dbo.agent_datetime(tblSJH.run_date, tblSJH.run_time)
									, @datetimeformat
								)
							, case (run_status)
									when 0 then 'Failed'
									when 1 then 'Succeeded'
									when 2 then 'Retry'
									when 3 then 'Canceled'
							  end

							--, tblSJH.run_duration
							, CAST(run_duration/10000 as varchar)  + ':' 
					   			+ CAST(run_duration/100%100 as varchar) + ':'
								+ CAST(run_duration%100 as varchar)
							, tblSJH.sql_message_id
							, tblSJH.[message]

						)

		from   msdb.[dbo].sysjobs tblSJ

		inner join msdb.[dbo].sysjobhistory tblSJH

				on tblSJ.[job_id] = tblSJH.[job_id]

		where tblSJ.[name] = @jobName

		and   tblSJH.[step_id] = 0

		order by
				tblSJH.[instance_id] desc

	)


	
end


go

grant execute on [notificationServices].[udfn_getJobHistoryInfoLastRun] to [public]
go


/*

	declare @jobName sysname

	set @jobName = 'CallCenterDataLoad'
	--set @jobName = 'DatabaseBackup - USER_DATABASES - LOG'

	print [dbo].[udfn_getJobHistoryInfoLastRun]
			(
				  @jobName
				, default
			)

*/