﻿CREATE PROC [dbo].[dv_source_table_update] 
    @table_key int,
    @system_key int,
    @source_table_schema varchar(128),
    @source_table_name varchar(128),
    @source_table_load_type varchar(50)
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  
	
	BEGIN TRAN

	UPDATE [dbo].[dv_source_table]
	SET    [system_key] = @system_key, [source_table_schema] = @source_table_schema, [source_table_name] = @source_table_name, [source_table_load_type] = @source_table_load_type
	WHERE  [table_key] = @table_key
	
	-- Begin Return Select <- do not remove
	SELECT [table_key], [system_key], [source_table_schema], [source_table_name], [source_table_load_type], [version_number], [updated_by], [update_date_time]
	FROM   [dbo].[dv_source_table]
	WHERE  [table_key] = @table_key	
	-- End Return Select <- do not remove

	COMMIT