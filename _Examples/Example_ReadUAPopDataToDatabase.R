
# -------------------------------------------------------------------------
# Examples - Read in Census ACS data to SQL database
# BHC
# 2023-09-01
# -------------------------------------------------------------------------

require("RPostgreSQL")
require("tidyverse")

# Establish database connection -------------------------------------------


# Setup connection with database
con <- dbConnect("PostgreSQL", dbname = "themines",
                 host = "127.0.0.1", port = 5432,
                 user = "benclaassen", password = "")
# Test connection
dbGetQuery(con, 'SELECT * FROM states_info')

# -------------------------------------------------------------------------
# Example 1 - Fill 'states_info' table
# -------------------------------------------------------------------------



# Read csv with states info
setwd("/Users/benclaassen/Documents/_Workshop/_Code Utilities/SQL/_Examples Data")
states <- read.csv("States_Info.csv")

# Drop first three rows because these were entered manually
states <- states[-c(1:3), ]
states # Starts with Arkansas

# Manually write first row of data as new rows in table
dbGetQuery(con, "
  INSERT INTO states_info (state_id, state_name, state_abbrev)
    VALUES (5, 'Arkansas', 'AR');
  ")

dbGetQuery(con, 'SELECT * FROM states_info')

# Drop row added manually
states <- states[-1,]
states # Should start with California


## Format remaining data to add at once
# Add quotes to character values (cols 2,3)


states[,2] <- sapply(states[,2], function(x) {paste0("'", x, "'")} )
states[,3] <- sapply(states[,3], function(x) {paste0("'", x, "'")} )
states


dataToAdd_values <- "VALUES "
for(i in 1:dim(states)[1]) {
  dataToAdd_values <- paste0(dataToAdd_values, "(", paste(states[i,], collapse= ", "), "), ")
}

# Substitute last comma for a semicolon
dataToAdd_values <- sub("), $", ");", dataToAdd_values)
dataToAdd_values

dataToAdd <- paste0(
  "INSERT INTO states_info (state_id, state_name, state_abbrev) ",
  dataToAdd_values
)
dataToAdd


# Add all remaining rows at once
dbGetQuery(con, dataToAdd)

dbGetQuery(con, 'SELECT * FROM states_info')

## SUCCESSFUL



# -------------------------------------------------------------------------
# Example 2 - Create new table
# -------------------------------------------------------------------------

# Create new table
dbGetQuery(con, 
'
  CREATE TABLE states (
    rowid               bigserial,      -- Unique row ID
    state_geoid         int,            -- State GeoID
    state_name          varchar(44),    -- State name
    st_var_id           varchar(30),    -- Variable ID for state
    st_var_name         varchar(100),   -- Variable name
    st_var_est          numeric,        -- variable estimate
    st_var_moe          numeric,        -- variable margin of error (MOE)
    st_var_source       varchar(100),   -- Variable source; e.g. "Census ACS"
    st_var_year         int,            -- Variable year for UA; e.g.: "2020"
    st_var_otherspecs   varchar(100)    -- Variable specifications for state other than source and year; e.g.: "5yr ests"
);
')

dbGetQuery(con, 'SELECT * FROM states')

# -------------------------------------------------------------------------
# Example 3 - Add data with estimates and MOEs from CSV
# -------------------------------------------------------------------------


## Data file location
# /Users/benclaassen/Documents/_Mines/AllData/_RawDataDownloads/Census/ACS 2020 5yr/Urban Areas/Age and Sex

## File
# ACSST5Y2020.S0101-Data.csv

## Variable names
# GEO_ID
# S0101_C01_001E
# S0101_C01_001M
