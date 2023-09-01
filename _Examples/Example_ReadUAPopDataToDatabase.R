
# -------------------------------------------------------------------------
# Examples - Read in Census ACS data to SQL database
# BHC
# 2023-09-01
# -------------------------------------------------------------------------



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
  CREATE TABLE urbanareas (
    rowid               int,            -- Unique row ID
    urbanarea_geoid     varchar(44),    -- Urban Area GeoID
    ua_var_id           char(2)         -- Variable ID for UA
    ua_var_name         x -- Variable name
    ua_var_source       x -- Variable source; e.g. "Census ACS"
    ua_var_year         x -- Variable year for UA; e.g.: "2020"
    ua_var_otherspecs   x -- Variable specifications for UA other than source and year; e.g.: "5yr ests"
    ua_var_est          x -- variable estimate
    ua_var_moe          x -- variable margin of error (MOE)
);
')


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
