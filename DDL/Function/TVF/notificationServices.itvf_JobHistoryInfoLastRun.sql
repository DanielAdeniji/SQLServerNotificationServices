use [master]
go

/*
	drop function [dbo].[itvf_JobHistoryInfoLastRun];
*/
if object_id('[dbo].[itvf_JobHistoryInfoLastRun]') is null
begin

	exec('create function [dbo].[itvf_JobHistoryInfoLastRun]() returns table as return ( select [shell] = 1/0 ) ');

end
go

alter function [dbo].[itvf_JobHistoryInfoLastRun]
(
	  @jobName sysname
	, @datetimeformat smallint = 100
) 
returns table
as
return
	(
		select top 1

				 [sqlInstance]
					= cast(serverproperty('servername') as sysname)

			   , [jobName] = tblSJ.[name]

			   , [stepName] = tblSJH.step_name

			   , [runStatus] = tblSJH.run_status

			   , [runStatusAsString]
					= case (run_status)
						when 0 then 'Failed'
						when 1 then 'Succeeded'
						when 2 then 'Retry'
						when 3 then 'Canceled'
					  end

			   , [sqlMessageID] = tblSJH.sql_message_id

			   , [runDateTime] = [msdb].dbo.agent_datetime
                                ( 
                                      tblSJH.[run_date]
                                    , tblSJH.[run_time]
                                )

			   , [runDuration] = tblSJH.[run_duration]

			   , [runDurationAsString]
						=    CAST(run_duration/10000 as varchar)  + ':' 
					   	   + CAST(run_duration/100%100 as varchar) + ':'
						   + CAST(run_duration%100 as varchar)
 
			   , [message] = tblSJH.[message]

			   , [formattedMessage]
					= FORMATMESSAGE
					(
						    'SQL Server Instance :- %s ' + char(13) + char(10)
						  + 'Job :- %s' + char(13) + char(10)
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

						--, @runDurationAsString
						, case (tblSJH.run_status)

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

		and   (
					-- last recorder run
					--   ( tblSJH.[step_id] = 0 )

					-- current run
					( tblSJH.[instance_id] =

						(

							select max(tblSJH_Inner.[instance_id])
							from   msdb.[dbo].sysjobhistory tblSJH_Inner
							where  tblSJH.[job_id]
										= tblSJH_Inner.[job_id]

						)

					)
			  )

		order by
				tblSJH.[instance_id] desc



	)
go


grant select on [dbo].[itvf_JobHistoryInfoLastRun] to [public]
go

/*

	declare @jobName sysname

	--set @jobName = 'CallCenterDataLoad'
	--set @jobName = 'DatabaseBackup - USER_DATABASES - LOG'

	set @jobName = 'Test Email'

	select *
	from   [dbo].[itvf_JobHistoryInfoLastRun]
			(
				  @jobName
				, default
			) itvf

*/