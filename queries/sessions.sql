SELECT 
	TO_CHAR(CONVERT_TIMEZONE('UTC', 'America/Denver', (session_duration_date_dim.sql_date_stamp || ' ' || session_duration_time_dim.minute_description || ':00')::timestamp), 'YYYY-MM-DD HH24:MI:SS') AS "session_duration_fact.timestamp_time",
	session_duration_fact.duration AS "session_duration_fact.duration",
	user_dimensions.id AS "user_dimensions.id",
	session_duration_fact.id AS "session_duration_fact.id"
FROM looker_scratch.LR$5MR82AA3KNFAUD541KVCD_session_duration_fact AS session_duration_fact
INNER JOIN public.user_dimensions AS user_dimensions ON session_duration_fact.user_surrogate_key = user_dimensions.surrogate_key
INNER JOIN public.time_dim AS session_duration_time_dim ON session_duration_fact.time_id = session_duration_time_dim.id
INNER JOIN public.date_dim AS session_duration_date_dim ON session_duration_fact.date_id = session_duration_date_dim.id

WHERE (session_duration_fact.category = 'Default') AND (user_dimensions.account_type = 'End User')
ORDER BY 1 DESC
