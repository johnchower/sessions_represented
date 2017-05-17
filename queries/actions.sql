SELECT 
	TO_CHAR(CONVERT_TIMEZONE('UTC', 'America/Denver', (user_platform_action_date_dim.sql_date_stamp || ' ' || user_platform_action_time_dim.minute_description || ':00')::timestamp), 'YYYY-MM-DD HH24:MI:SS') AS "user_platform_action_facts.timestamp_time",
	user_dimensions.id AS "user_dimensions.id",
	user_platform_action_facts.id AS "user_platform_action_facts.id"
FROM public.user_platform_action_facts AS user_platform_action_facts
INNER JOIN public.user_dimensions AS user_dimensions ON user_platform_action_facts.user_surrogate_key = user_dimensions.surrogate_key
INNER JOIN public.time_dim AS user_platform_action_time_dim ON user_platform_action_facts.time_id = user_platform_action_time_dim.id
INNER JOIN public.date_dim AS user_platform_action_date_dim ON user_platform_action_facts.date_id = user_platform_action_date_dim.id

WHERE (user_platform_action_facts.platform_action = 'FamilyLife - Listened to Broadcast' OR user_platform_action_facts.platform_action = 'Listened to Broadcast on Page') AND (((((user_platform_action_date_dim.sql_date_stamp || ' ' || user_platform_action_time_dim.minute_description || ':00')::timestamp) >= (CONVERT_TIMEZONE('America/Denver', 'UTC', TIMESTAMP '2017-02-01')) AND ((user_platform_action_date_dim.sql_date_stamp || ' ' || user_platform_action_time_dim.minute_description || ':00')::timestamp) < (CONVERT_TIMEZONE('America/Denver', 'UTC', TIMESTAMP '2017-03-01'))))) AND (user_dimensions.account_type = 'End User' OR user_dimensions.account_type = 'Champion User')
ORDER BY 1 DESC
;
