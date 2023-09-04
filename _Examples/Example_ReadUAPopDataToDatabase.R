
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
# /Users/benclaassen/Documents/_Mines/Data_MAIN/_RawDownloads/Census/ACS 2020 5yr/States/Age and Sex
# /Users/benclaassen/Documents/_Mines/Data_MAIN/_RawDownloads/Census/ACS 2020 5yr/States/Median Income

## File
# ACSST5Y2020.S0101-Data.csv
# ACSST5Y2020.S1903-Data.csv

## Variable names
# GEO_ID
# S0101_C01_001E - Total Pop, Est
# S0101_C01_001M - Total Pop, MOE
# S1903_C03_001E - Median income, Est
# S1903_C03_001M - Median income, MOE


# Total pop ---------------------------------------------------------------
setwd("/Users/benclaassen/Documents/_Mines/Data_MAIN/_RawDownloads/Census/ACS 2020 5yr/States/Age and Sex")
pop1 <- read.csv("ACSST5Y2020.S0101-Data.csv") # Read data

pop2 <- pop1 %>% select(GEO_ID, NAME, S0101_C01_001E, S0101_C01_001M) # Select cols

names(pop2) <- c("GEO_ID", "StateName", "TotalPop_Est", "TotalPop_MOE") # Rename cols
head(pop2)
pop2 <- pop2[-1,] # Drop ACS names
head(pop2)

pop2$Id <- gsub("0400000US", "", pop2$GEO_ID) # Create integer ID col

# Change class of est, moe, and id
sapply(pop2[,3:5], class)
pop2[,3:5] <- sapply(pop2[,3:5], as.numeric)
sapply(pop2[,3:5], class)

# Check [pop2]
summary(pop2)
head(pop2)

# Assign all NA's in MOE cols to be equal to 0
pop3 <- pop2 %>% mutate(TotalPop_MOE = replace_na(TotalPop_MOE, 0))
summary(pop3)
head(pop3)


dbGetQuery(con, "SELECT * FROM states")


setwd("/Users/benclaassen/Documents/_Mines/Data_MAIN/_RawDownloads/Census/ACS 2020 5yr/States/Median Income")
inc1 <- read.csv("ACSST5Y2020.S1903-Data.csv") # Read data

inc2 <- inc1 %>% select(GEO_ID, NAME, S1903_C03_001E, S1903_C03_001M) # Select cols

names(inc2) <- c("GEO_ID", "StateName", "MedianIncome_Est", "MedianIncome_MOE") # Rename cols
head(inc2)
inc2 <- inc2[-1,] # Drop ACS names
head(inc2)


inc2$Id <- gsub("0400000US", "", inc2$GEO_ID) # Create integer ID col

# Change class of est, moe, and id
sapply(inc2[,3:5], class)
inc2[,3:5] <- sapply(inc2[,3:5], as.numeric)
sapply(inc2[,3:5], class)

# Check [inc2]
summary(inc2)
head(inc2)

# Assign all NA's in MOE cols to be equal to 0
inc3 <- inc2 %>% mutate(MedianIncome_MOE = replace_na(MedianIncome_MOE, 0))
summary(inc3)
head(inc3)

# -------------------------------------------------------------------------

pop4 <- pop3 %>% select(Id, StateName, TotalPop_Est, TotalPop_MOE)
inc4 <- inc3 %>% select(Id, StateName, MedianIncome_Est, MedianIncome_MOE)

head(pop4)
sapply(pop4, class)

head(inc4)
sapply(inc4, class)


# -------------------------------------------------------------------------
# -------------------------------------------------------------------------
# Test variables
dbConnection = con
sqlTableName = "states"
dataFrameToAdd = pop4[, c(1,3,4)]
names(dataFrameToAdd)[2] <- "TotalPop"
variableID = "S0101_C01_001"
dataSource = "Census ACS"
dataYear = "2020"
dataOtherSpecs = "5yr"
variableName = ""

# -------------------------------------------------------------------------



sql_addCensusDataToDatabase <- function(dbConnection, sqlTableName, dataFrameToAdd, variableID, variableName = "", dataSource, dataYear, dataOtherSpecs) {
  ## DATA FRAME MUST HAVE 3 COLS
  # [1] ID
  # [2] Estimate
  # [3] MOE
  
  ## Check for errors -----------------------------------------------------
  
  # [dbConnection] must be a "PostgreSQLConnection", else throw error
  if(class(dbConnection) != 'PostgreSQLConnection') {
    stop("ERROR: [dbConnection] must be a useable database connection")
  }
  
  # [sqlTableName] must be a string, and must exist in the database represented by [dbConnection]
  if( class(sqlTableName) == "character" ){
    
    # Check if given table exists
    ifTableExists <- dbGetQuery(dbConnection,
      paste0("SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = '", sqlTableName, "');" )      
    )
    
    # Convert to logical
    ifTableExists <- as.logical(ifTableExists)
    
    # If table doesn't exist, exit function
    if( !ifTableExists ) {
      stop( paste0("ERROR: Table '", sqlTableName, "' does not exist in [dbConnection]") )
    }
      
  } else {
    stop("ERROR: [sqlTableName] must be a character")
  }
  
  # [dataFrameToAdd] must be a dataframe, else throw error
  if(class(dataFrameToAdd) != "data.frame") {
    stop("ERROR: [dataFrameToAdd] must be a data.frame")
  }
  # If [dataFrameToAdd] does not have 3 column, throw error
  if(dim(dataFrameToAdd)[2] != 3) {
    stop("ERROR: Dataset must have 3 columns: {ID, Estimate, MOE}")
  }
  
  
  
  ## Change inputs to strings if not currently ----------------------------
  
  # Convert [dataSource] to string if it is not already
  if(class(dataSource) != "character") {
    dataSource <- as.character(dataSource)
  }
  # Convert [dataYear] to string if it is not already
  if(class(dataYear) != "character") {
    dataYear <- as.character(dataYear)
  }
  # Convert [dataOtherSpecs] to string if it is not already
  if(class(dataOtherSpecs) != "character") {
    dataOtherSpecs <- as.character(dataOtherSpecs)
  }
  

  # -----------------------------------------------------------------------
  # Transform data.frame into format for SQL input
  ### dbGetQuery(con, "
  ###   INSERT INTO states_info (state_id, state_name, state_abbrev)
  ###   VALUES (5, 'Arkansas', 'AR') ( , , );
  ### ")
  
  
  # Convert character values in data.frame to be in quotes ----------------
  # Find columns that have character formats
  characterVarsList <- as.vector(
    which(sapply(dataFrameToAdd, function(x) {class(x)}) == "character")
  )
  
  # Add quotes to observations for each column that are characters
  for(c in characterVarsList) {
    dataFrameToAdd[,c] <- sapply(dataFrameToAdd[,c], function(x) {paste0("'", x, "'")} )
  }


  # Prepare values for SQL formatting -------------------------------------
  if(variableName == "") {
    variableName = names(dataFrameToAdd)[2]
  }
  
  # Create list of values to insert ---------------------------------------
  dataToAdd_values <- "VALUES "
  
  for(i in 1:dim(dataFrameToAdd)[1]) {
    dataToAdd_values <- paste0(dataToAdd_values, "(", paste(dataFrameToAdd[i,], collapse= ", "), "), ") # Collapse rows to: "(, , , ),"
  }

# Substitute last comma for a semicolon
dataToAdd_values <- sub("), $", ");", dataToAdd_values)


dataToAdd <- paste0(
  "INSERT INTO ", sqlTableName, " (state_geoid, state_name, st_var_id, ) ",
  # "INSERT INTO states_info (state_id, state_name, state_abbrev) ",
  dataToAdd_values
)
dataToAdd

# -------------------------------------------------------------------------
# -------------------------------------------------------------------------

set connection
pull table 
print table names
print [dataFrameToAdd] names
ask user to confirm names match
convert [dataFrameToAdd] to sql format
write [dataFrameToAdd] to table
close db connection


# -------------------------------------------------------------------------
# -------------------------------------------------------------------------


  
}
## get sql col name ->
dbGetQuery(con, 'SELECT * FROM states')

