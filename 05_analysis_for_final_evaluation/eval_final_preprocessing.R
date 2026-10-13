# RESEARCHER MENTORING PROGRAM FOR EARLY CAREER RESEARCHERS (2025)
# PREPROCESSING DATA SCRIPT FOR THE FINAL EVALUATION
# JEN BEAUDRY

#### LOAD LIBRARY ####

library(here)
library(tidyverse)

source(here("..", "functions", "read_qualtrics.R"))
source(here("..", "functions", "meta_rename.R"))


#### LOAD DATA ####

# mentor data with labels

df_tor <- here::here("00_data", "raw_data", "eval_final_mentor.csv") %>%
  read_qualtrics(legacy = FALSE) %>%
  select(-c("start_date":"user_language", "follow_up", "sc0")) %>% 
  filter(!is.na(meetings_w_mentee)) %>% # all cases without responses did not answer this first question
  mutate(id = 1:n()) %>% 
  relocate(id, .before = meetings_w_mentee)


# mentee data with labels

df_tee <- here::here("00_data", "raw_data", "eval_final_mentee.csv") %>%
  read_qualtrics(legacy = FALSE) %>%
  select(-c("start_date":"user_language", "follow_up", "sc0")) %>% 
#  filter(meetings_w_mentor != "sdf") %>% # remove the test data
  mutate(id = 1:n()) %>% 
  relocate(id, .before = meetings_w_mentor)


# load metadata for mentors
meta_tor <- read_csv(here::here("00_data", "raw_data", "metadata_eval_final_mentor.csv"),
                     col_types = cols(.default = "c"),
                     lazy = FALSE) %>%
  filter(old_variable != "NA") # remove the instruction variables


# load metadata for mentees
# force it to read all columns as characters because it wasn't
meta_tee <- read_csv(here::here("00_data", "raw_data", "metadata_eval_final_mentee.csv"), 
                     col_types = cols(.default = "c"), lazy = FALSE) %>% 
  filter(old_variable != "NA") # remove the instruction variables


##### RECODE VARIABLES #####

# recode variable labels according to metadata for mentor data

df_tor <- meta_rename(df = df_tor, metadata = meta_tor, old = old_variable, new = new_variable)

# recode variable labels according to metadata for mentee data

df_tee <- meta_rename(df = df_tee, metadata = meta_tee, old = old_variable, new = new_variable)  



# create a role variable for the two tibbles

df_tor$role <- "mentor"
df_tee$role <- "mentee"


# change the type of variables to characters [breaddrumb: I don't think I need this]

# df_tee <- df_tee %>% 
#   mutate_if(is.numeric, as.character)
# 
# df_tor <- df_tor %>% 
#   mutate_if(is.numeric, as.character)


### RECODE VALUES & CASES ###

# Need to recode certain values for consistency
# This is the simplest way to do that (search for the values in the entire dataset that match and recode them)

# df_tor [df_tor == "about 8 times I think"] <- "8"
# df_tor [df_tor == "Around 4 total. We had scheduled for every 6 weeks, but had to cancel/reschedule several"] <- "4" # be conservative
# df_tor [df_tor == "3?"] <- "3" # be conservative
# df_tor [df_tor == "at least 12 times we did try to meet fortnightly"] <- "12"
# df_tor [df_tor == "~10 times"] <- "10"
# 
# 
# df_tee [df_tee == "6 (I think!)"] <- "6"
# df_tee [df_tee == "3-Apr"] <- "3" # be conservative
# df_tee [df_tee == "10 approx"] <- "10"
# df_tee [df_tee == "approximately 6"] <- "6"
# df_tee [df_tee == "four"] <- "4"

#df_tor [df_tor == "â€™"] <- "'"

##### JOIN THE TIBBLES #####

#combine the mentor and mentee tibbles into one

df <- full_join(df_tor, df_tee) %>% 
  relocate (role, .after = id)


#### WRITE DATA ####

# when done preprocessing, write the data to new files
# row.names gets rid of the first column from the dataframe.
# for now, I'm saving the combined data. I don't think I need the separated data frames.

# write.csv(df_tor, here::here("processed data", "eval_mid_mentor_preprocessed.csv"), row.names = FALSE)

# write.csv(df_tee, here::here("processed data", "eval_mid_mentee_preprocessed.csv"), row.names = FALSE)

write.csv(df, here::here("00_data", "processed_data", "eval_final_combined_preprocessed.csv"), row.names = FALSE, 
          fileEncoding = "UTF-8")
