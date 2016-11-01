DECLARE @messageSourceType TABLE (id INT, [message_source_type] VARCHAR(250))
INSERT INTO @messageSourceType
VALUES(10, N'Entry APIs, such as T-SQL and CLR Stored procedures')
       ,(20, N'External process used to run package (ISServerExec.exe)')
       ,(30, N'Package-level objects')
       ,(40, N'Control Flow tasks')
       ,(50, N'Control Flow containers')
       ,(60, N'Data Flow task')
DECLARE @messageType TABLE (id INT, [message_type] VARCHAR(250))
INSERT INTO @messageType
VALUES (-1, N'Unknown')
       ,(10, N'Pre-validate')
       ,(20, N'Post-validate')
       ,(30, N'Pre-execute')
       ,(40, N'Post-execute')
       ,(50, N'StatusChange')
       ,(60, N'Progress')
       ,(70, N'Information')
       ,(80, N'VariableValueChanged')
       ,(90, N'Diagnostic')
       ,(100, N'QueryCancel')
       ,(110, N'Warning')
       ,(120, N'Error')
       ,(130, N'TaskFailed')
       ,(140, N'DiagnosticEx')
       ,(200, N'Custom')
       ,(400, N'NonDiagnostic')

SELECT     opmsg.[message_time],
           mt.[message_type],
           st.[message_source_type],  
           eventmsg.[package_name],
           opmsg.[message], 
           eventmsg.[event_name],    
           eventmsg.[subcomponent_name],
           eventmsg.[package_path],
           eventmsg.[execution_path]
FROM      SSISDB.[internal].[operation_messages] opmsg 
LEFT JOIN @messageSourceType st
       ON opmsg.[message_source_type] = st.id
LEFT JOIN @messageType mt
       ON opmsg.[message_type] = mt.id
LEFT JOIN  SSISDB.[internal].[event_messages] eventmsg  
           ON opmsg.[operation_message_id] = eventmsg.[event_message_id]
WHERE eventmsg.[event_name] NOT IN ('OnPostExecute','OnPostValidate','OnPreExecute','OnPreValidate','OnInformation','OnWarning')
AND package_name = 'DDS_Load_FactInventory'
AND opmsg.[message_time] >= DATEADD(DAY,-7,GETDATE())
ORDER BY opmsg.[message_time] DESC
