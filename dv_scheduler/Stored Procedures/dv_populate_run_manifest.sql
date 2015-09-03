USE [ODV_Config_Scheduler]
GO
/****** Object:  StoredProcedure [dv_scheduler].[dv_populate_run_manifest]    Script Date: 3/09/2015 1:58:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dv_scheduler].[dv_populate_run_manifest]
(
	@schedule_name		varchar(max)
)
AS
BEGIN
SET NOCOUNT ON

DECLARE		@run_key		int;

-- insert one row for the run into dv_run table
insert into dv_scheduler.dv_run default values;

select @run_key = run_key from dv_scheduler.dv_run where run_key = SCOPE_IDENTITY();

-- insert all tables to be run into the dv_run_manifest table
insert into dv_scheduler.dv_run_manifest (run_key, source_system_name, source_table_schema, source_table_name, source_table_key, source_table_load_type, source_procedure_name, priority, queue)
select @run_key as run_key, src_system.source_system_name, src_table.source_table_schema, src_table.source_table_name, src_table.table_key, schd_src_table.source_table_load_type, src_table.source_procedure_name, schd_src_table.priority, schd_src_table.queue
from dv_scheduler.dv_schedule as schd
inner join dv_scheduler.dv_schedule_source_table as schd_src_table
on schd.schedule_key = schd_src_table.schedule_key
inner join dbo.dv_source_table as src_table
on schd_src_table.source_table_key = src_table.table_key
inner join dbo.dv_source_system as src_system
on src_table.system_key = src_system.system_key
where schedule_name in (select replace(Item,' ','') from dbo.fn_split_strings(@schedule_name,','));

select * from dv_scheduler.dv_run_manifest where run_key = @run_key;


SET NOCOUNT OFF

END;
