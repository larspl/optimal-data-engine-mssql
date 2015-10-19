﻿CREATE PROC [dv_scheduler].[dv_schedule_source_table_insert] 
     @schedule_name				varchar(128)
	,@source_system_name		varchar(50)
	,@source_table_schema		varchar(128)
    ,@source_table_name			varchar(128)
    ,@source_table_load_type	varchar(50)
	,@priority					varchar(50)
	,@queue						VARCHAR(50)
	,@release_number			int
AS
BEGIN 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  
	
	BEGIN TRAN
	
	declare @release_key					int
	       ,@schedule_key					int
	       ,@source_table_key				int
		   ,@source_table_qualified_name	varchar(512)
	       ,@rc								int
	select @release_key = [release_key] from [dv_release].[dv_release_master] where [release_number] = @release_number
	set @rc = @@rowcount
	if @rc <> 1 
		RAISERROR('Release Number %i Does Not Exist', 16, 1, @release_number)
		else
			begin
			select @schedule_key = [schedule_key] from [dv_scheduler].[dv_schedule] 
				where [schedule_name] = @schedule_name
				  and is_cancelled <> 1
			set @rc = @@rowcount
			if @rc <> 1 
				RAISERROR('Schedule Name %s Does Not Exist', 16, 1, @schedule_name)
				else
					begin
					select @source_table_qualified_name = quotename(@source_system_name) + '.' + quotename(@source_table_schema) + quotename(@source_table_name)
					select @source_table_key = [source_table_key] 
					from [dbo].[dv_source_system] s
					inner join [dbo].[dv_source_table] st
					on s.[source_system_key] = st.[system_key]
					where s.[source_system_name]	= @source_system_name
					  and st.[source_table_schema]	= @source_table_schema
					  and [source_table_name]		= @source_table_name
					set @rc = @@rowcount
					if @rc <> 1 
						RAISERROR('Source Table %s Does Not Exist', 16, 1, @source_table_qualified_name)
						else
							INSERT INTO [dv_scheduler].[dv_schedule_source_table] ([schedule_key] ,[source_table_key] ,[source_table_load_type] ,[priority] ,[queue] ,[release_key])
							 VALUES (@schedule_key ,@source_table_key,@source_table_load_type,@priority,@queue,@release_key)
					end
			end
	-- Begin Return Select <- do not remove

	SELECT [schedule_source_table_key]
		  ,[schedule_key]
		  ,[source_table_key]
		  ,[source_table_load_type]
		  ,[release_key]
		  ,[priority]
		  ,[queue]
		  ,[version_number]
		  ,[updated_by]
		  ,[updated_datetime]
	  FROM [dv_scheduler].[dv_schedule_source_table]
 	WHERE  [schedule_source_table_key] = SCOPE_IDENTITY()
	-- End Return Select <- do not remove
               
	COMMIT
       RETURN SCOPE_IDENTITY()
END