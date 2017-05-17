proj_root <- rprojroot::find_root(
  rprojroot::has_dirname("sessions_represented")
)

suppressMessages(library(dplyr))
suppressMessages(library(optparse))

if (!interactive()){
  optionList <-   list(
    optparse::make_option(
      opt_str =  "--output_directory"
    , type = "character"
    , default = "output"
    , help = "Relative path to directory where output csvs go"
    )
  , optparse::make_option(
      opt_str =  "--csv_directory"
    , type = "character"
    , default = "data"
    , help = "Relative path to directory where input csvs go"
    )
  )
  opt_parser <- optparse::OptionParser(option_list = optionList)
  opt <- optparse::parse_args(opt_parser)
  output_directory <- paste0(
    proj_root
    , "/"
    , opt$output_directory
    , "/"
  )
  csv_directory <- paste0(
    proj_root
    , "/"
    , opt$csv_directory
    , "/"
  )
  use_cache <- opt$use_cache
} else {
  output_directory <- paste0(
    proj_root
    , "/"
    , "output"
    , "/"
  )
  csv_directory <- paste0(
    proj_root
    , "/"
    , "data"
    , "/"
  )
}

csv_name_list <- dir(csv_directory) %>% {
  gsub(pattern = ".csv", replacement = "", x = .)
}

csv_data_list <- csv_directory %>% {
  paste0(., dir(.))
} %>%
lapply(FUN = function(path) {
  read.csv(path, stringsAsFactors = F) 
})

names(csv_data_list) <- csv_name_list

# Preprocessing
actions <- csv_data_list$actions %>%
  mutate(
    pa_time = strftime(
      user_platform_action_facts.timestamp_time
    , format = "%Y-%m-%d %H:%M:%S"
    )
  , user_id = user_dimensions.id
  , pa_id = user_platform_action_facts.id
  )

sessions <- csv_data_list$sessions %>%
  filter(user_dimensions.id %in% actions$user_id) %>%
  mutate(
    start_time = strftime(
      session_duration_fact.timestamp_time
    , format = "%Y-%m-%d %H:%M:%S"
    )
  , user_id = user_dimensions.id
  , duration = session_duration_fact.duration
  , session_id = session_duration_fact.id
  )

sessions$end_time <- 
  as.POSIXct(sessions$start_time) + sessions$duration 

# Calculation
cat("\nJoining sessions dataset to actions dataset.\n")
starttime <- Sys.time()
session_join <- sessions %>%
  inner_join(actions, by = "user_id")
endtime <- Sys.time()
endtime - starttime

cat("\nFiltering joined dataset.\n")
starttime <- Sys.time()
session_pa_correspondence <- session_join %>%
  filter(
    pa_time <= end_time
  , pa_time >= start_time
  )
endtime <- Sys.time()
endtime - starttime

distinct_sessions <- session_pa_correspondence %>%
  filter(duration <= 3 * 60 * 60) %>%
  distinct(user_id, session_id, duration)

radio_session_summary <- distinct_sessions %>%
  summarise(
    count_distinct_sessions = length(unique(session_id))
  , count_distinct_users = length(unique(user_id))
  , avg_session_length = mean(duration)
  , avg_monthly_time_on_app_seconds = 
      count_distinct_sessions * avg_session_length / count_distinct_users
  )

# Write results
write.csv(
  distinct_sessions
, file = paste0(output_directory, "distinct_sessions.csv")
, row.names = F
)
write.csv(
  radio_session_summary
, file = paste0(output_directory, "radio_session_summary.csv")
, row.names = F
)
