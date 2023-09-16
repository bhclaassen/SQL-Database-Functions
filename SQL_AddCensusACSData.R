
# Has all but check if data already exists --------------------------------
# Implementing now

# -------------------------------------------------------------------------
# -------------------------------------------------------------------------
# Test variables

# 
# require("RPostgreSQL")
# require("tidyverse")

# Setup connection with database
# con <- dbConnect("PostgreSQL", dbname = "themines",
#                  host = "127.0.0.1", port = 5432,
#                  user = "benclaassen", password = "")
# Test connection
# head(
#   dbGetQuery(con, 'SELECT * FROM states_info')
# )
# 

# -------------------------------------------------------------------------
# Example with population write -------------------------------------------
# 
# setwd("/Users/benclaassen/Documents/_Mines/Data_MAIN/_RawDownloads/Census/ACS 2020 5yr/States/Age and Sex")# setwd("/Users/benclaassen/Documents/_Mines/Data_MAIN/_Ra# # setwd("/Users/benclaassen/Documents/_Mines/Data_MAIN/_RawDownloads/Census/ACS 2020 5yr/States/Age and Sex
# pop1 <- read.csv("ACSST5Y2020.S0101-Data.csv") # Read data
# pop2 <- pop1 %>% select(GEO_ID, NAME, S0101_C01_001E, S0101_C01_001M) # Select cols
# 
# 
# names(pop2) <- c("GEO_ID", "StateName", "TotalPop_Est", "TotalPop_MOE") # Rename cols
# head(pop2)
# pop2 <- pop2[-1,] # Drop ACS names
# head(pop2)
# 
# pop2$Id <- gsub("0400000US", "", pop2$GEO_ID) # Create integer ID col
# 
# # Change class of est, moe, and id
# sapply(pop2[,3:5], class)pop2[,3:5] <- sapply(pop2[,3:5], as.numeric)s
# 
# apply(pop2[,3:5], class)
# 
# # Check [pop2]
# summary(pop2)
# head(pop2)
# 
# # Assign all NA's in MOE cols to be equal to 0
# pop3 <- pop2 %>% mutate(TotalPop_MOE = replace_na(TotalPop_MOE, 0))
# summary(pop3)
# head(pop3)
# 
# 
# pop4 <- pop3 %>% select(Id, StateName, TotalPop_Est, TotalPop_MOE)
# 
# head(pop4)
# sapply(pop4, class)
# 
# 
# pop5 <- pop4[,c(1:2)]
# head(pop5)
# names(pop5) <- c("state_geoid", "state_name")
# 
# pop5$st_var_id <- "S0101_C01_001"
# pop5$st_var_name <- "TotalPopulation"
# pop5$st_var_est <- pop4[,3]
# pop5$st_var_moe <- pop4[,4]
# 
# pop5$st_var_source <- "Census ACS"
# pop5$st_var_year <- 2020
# pop5$st_var_otherspecs <- "5yr estimates"
# 
# head(pop5)
# 




# -------------------------------------------------------------------------

# rowid
# state_geoid
# state_name
# st_var_id
# st_var_name
# st_var_est
# st_var_moe
# st_var_source
# st_var_year
# st_var_otherspecs

# -------------------------------------------------------------------------
# inc1 <- read.csv("ACSST5Y2020.S1903-Data.csv") # Read data
# 
# inc2 <- inc1 %>% select(GEO_ID, NAME, S1903_C03_001E, S1903_C03_001M) # Select cols
# 
# names(inc2) <- c("GEO_ID", "StateName", "MedianHHIncome_Est", "MedianHHIncome_MOE") # Rename cols
# head(inc2)
# inc2 <- inc2[-1,] # Drop ACS names
# 
# pop4 <- pop3 %>% select(Id, StateName, TotalPop_Est, TotalPop_MOE)
# 
# head(pop4)
# sapply(pop4, class)
# 
# 
# pop5 <- pop4[,c(1:2)]
# head(pop5)
# names(pop5) <- c("state_geoid", "state_name")
# 
# pop5$st_var_id <- "S0101_C01_001"
# pop5$st_var_name <- "TotalPopulation"
# pop5$st_var_est <- pop4[,3]
# pop5$st_var_moe <- pop4[,4]
# 
# pop5$st_var_source <- "Census ACS"
# pop5$st_var_year <- 2020
# pop5$st_var_otherspecs <- "5yr estimates"
# 
# head(pop5)
# 




# -------------------------------------------------------------------------

# rowid
# state_geoid
# state_name
# st_var_id
# st_var_name
# st_var_est
# st_var_moe
# st_var_source
# st_var_year
# st_var_otherspecs

# -------------------------------------------------------------------------
# Internal function parameters
# dbConnection = con
# sqlTableName = "states"
# dataFrameToAdd = pop5
# -------------------------------------------------------------------------
# Example with income write -----------------------------------------------

# setwd("/Users/benclaassen/Documents/_Mines/Data_MAIN/_RawDownloads/Census/ACS 2020 5yr/States/Median Income")
# inc1 <- read.csv("ACSST5Y2020.S1903-Data.csv") # Read data
# 
# inc2 <- inc1 %>% select(GEO_ID, NAME, S1903_C03_001E, S1903_C03_001M) # Select cols
# 
# names(inc2) <- c("GEO_ID", "StateName", "MedianHHIncome_Est", "MedianHHIncome_MOE") # Rename cols
# head(inc2)
# inc2 <- inc2[-1,] # Drop ACS names
# head(inc2)
# 
# 
# inc2$Id <- gsub("0400000US", "", inc2$GEO_ID) # Create integer ID col
# 
# # Change class of est, moe, and id
# sapply(inc2[,3:5], class)
# inc2[,3:5] <- sapply(inc2[,3:5], as.numeric)
# sapply(inc2[,3:5], class)
# 
# # Check [inc2]
# summary(inc2)
# head(inc2)
# 
# # Assign all NA's in MOE cols to be equal to 0
# inc3 <- inc2 %>% mutate(MedianHHIncome_MOE = replace_na(MedianHHIncome_MOE, 0))
# summary(inc3)
# head(inc3)
# 
# 
# inc4 <- inc3 %>% select(Id, StateName, MedianHHIncome_Est, MedianHHIncome_MOE)
# head(inc4)
# sapply(inc4, class)
# 
# # Add vars for sql table col match
# inc5 <- inc4[,c(1:2)]
# head(inc5)
# names(inc5) <- c("state_geoid", "state_name")
# 
# inc5$st_var_id <- "S1903_C03_001"
# inc5$st_var_name <- "MedianHHIncome"
# inc5$st_var_est <- inc4[,3]
# inc5$st_var_moe <- inc4[,4]
# 
# inc5$st_var_source <- "Census ACS"
# inc5$st_var_year <- 2020
# inc5$st_var_otherspecs <- "5yr estimates"
# 
# head(inc5)
# sapply(inc5, class)


# Write data using function
# sql_addCensusDataToDatabase(dbConnection = con, sqlTableName = "states", dataFrameToAdd = inc5)
# 


sql_addCensusDataToDatabase <- function(dbConnection, sqlTableName, dataFrameToAdd) {
  

# Shorthand steps ---------------------------------------------------------
# ~DONE~ check for input errors
# ~DONE~ set connection
# ~DONE~ pull table names
# ~DONE~ confirm sql table names match input data.frame table names
# ~DONE~ check if data already exists
# ~DONE~ convert [dataFrameToAdd] to sql format
# ~DONE~ write [dataFrameToAdd] to table
# ~DONE~ confirm first row of [dataFrameToAdd] is in sql table
# ~DONE~ close db connection

  
  # -----------------------------------------------------------------------
  # Check for input errors ------------------------------------------------
  
  # Confirm [dataFrameToAdd] is a data.frame
  if(class(dataFrameToAdd) != "data.frame") {
    stop("ERROR: [dataFrameToAdd] is not a data.frame")
  }
  
  # Confirm connection is valid -> [dbConnection] must be a "PostgreSQLConnection", else throw error
  if(class(dbConnection) != 'PostgreSQLConnection') {
    stop("ERROR: [dbConnection] must be a useable database connection")
  }
  
  # Confirm [sqlTableName] is a valid table via [dbConnection]
  ifTableExists <- as.logical( # Pull table status
    dbGetQuery(dbConnection,
      paste0("SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = '", sqlTableName, "');" )      
    )
  )
  # If table doesn't exist, exit function
  if( !ifTableExists ) {
    tableExistenceErrorStatement <- paste0("ERROR: Table '", sqlTableName, "' does not exist in [dbConnection]") # Stop statement does not process 'paste0' command, therefore pre-paste to get statement
    stop( tableExistenceErrorStatement )
  }
  rm(ifTableExists) # Remove status if true, i.e. if statement above evaluates TRUE
  
  

  # ----------------------------------------------------------------------
  # Confirm that names of target table match input data.frame [dataFrameToAdd]
  # NOTE: If the first column in SQL table is "rowid" then it is the PROPER KEY. This is a SERIAL data type, and is handled automatically by PSQL
  
  sqlTableColumnNames <- names(
    dbGetQuery(dbConnection, paste0("SELECT * FROM ", sqlTableName," WHERE false;") )
  )
  
  if( sqlTableColumnNames[1] == "rowid") { # IF first sql table column name is the SERIAL var 'rowid'...
    if( !( identical( sqlTableColumnNames[-1], names(dataFrameToAdd) ) ) ) { # ...THEN all names except the first must match; ...
      print( paste0("Input table names are:  {", paste0( names(dataFrameToAdd), collapse = ", ") , "}") ) # Print what the input table names are
      print( paste0("Target table names are: {", paste0(sqlTableColumnNames[-1], collapse = ", ") , "} ('rowid' purposely ommited)") ) # Print what the target table names are
      stop("ERROR: Names of input table [dataFrameToAdd] do not match names of [sqlTableName] (Column 1: 'rowid' EXCLUDED)")
    }
  } else if( !( identical( sqlTableColumnNames, names(dataFrameToAdd) ) ) ) { # ...ELSE, first sql table column name is not the SERIAL var 'rowid', THEN all names must match
    print( paste0("Target table names are: {", paste0(sqlTableColumnNames, collapse = ", ") , "}") ) # Print what the target table names are
    stop("ERROR: Names of input table [dataFrameToAdd] do not match names of [sqlTableName] (Column 1: 'rowid' INCLUDED)")
  }
  
  

  # Once formatting is confirmed, check if data already exists ------------
  # E.g.: SELECT 1 FROM MyTable WHERE <condition>
  
  # Initialize sql query to look for first row of [dataFrameToAdd]
  sql_dataExistsCheckStatement <- paste0("SELECT 1 FROM ", sqlTableName, " WHERE ")
  
  # Add each of the columns to the query except the last column
  for(n in 1:( length(names(dataFrameToAdd)) - 1) ) {
    if( is.character(dataFrameToAdd[,n]) ) { # If variable is a character, put the value in single-quotes
      sql_dataExistsCheckStatement <- paste0(sql_dataExistsCheckStatement, 
        names(dataFrameToAdd)[n], " = '", dataFrameToAdd[1,n], "' AND "
      )
    } else {
      sql_dataExistsCheckStatement <- paste0(sql_dataExistsCheckStatement, 
        names(dataFrameToAdd)[n], " = ", dataFrameToAdd[1,n], " AND "
      )
    }
  }
  
  # Add the last column to the query
  if( is.character(dataFrameToAdd[,n+1]) ) {
      sql_dataExistsCheckStatement <- paste0(sql_dataExistsCheckStatement, 
        names(dataFrameToAdd)[n+1], " = '", dataFrameToAdd[1,n+1], "';"
      )
    } else {
      sql_dataExistsCheckStatement <- paste0(sql_dataExistsCheckStatement, 
        names(dataFrameToAdd)[n+1], " = ", dataFrameToAdd[1,n+1], ";"
      )
    }
  
  # Run query. If any of the returns are TRUE, exit function, else proceed
  if( any( dbGetQuery(dbConnection, sql_dataExistsCheckStatement) ) ) {
    stop("ERROR: Data already exists in table (based on check of first row in [dataFrameToAdd])")
  } else {
    print( paste0("NOTE: First row of [dataFrameToAdd] not found -> adding given data to [", sqlTableName, "]") )
  }
  
  
  # -----------------------------------------------------------------------
  # Transform data.frame into format for SQL input, e.g. ->
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
  
  
  # Create list of values to insert ---------------------------------------
  sql_dataToAdd_values <- "VALUES "
  
  for(i in 1:dim(dataFrameToAdd)[1]) {
    sql_dataToAdd_values <- paste0(sql_dataToAdd_values, "(", paste(dataFrameToAdd[i,], collapse= ", "), "), ") # Collapse rows to: "(, , , ),"
  }
  
  # Substitute last comma for a semicolon in [sql_dataToAdd_values]
  sql_dataToAdd_values <- sub("), $", ");", sql_dataToAdd_values)
  
  
  # Assemble final SQL command to insert data
  sql_dataToAdd_complete <- paste0(
    "INSERT INTO ", sqlTableName, " (", paste0(names(dataFrameToAdd), collapse = ", "), ") ",
    # "INSERT INTO ", sqlTableName, " (state_geoid, state_name, st_var_id, ) ",
    sql_dataToAdd_values
  )
  
  # Final Command
  # Insert data into [sqlTableName] using command in [sql_dataToAdd_complete]
  dbGetQuery(dbConnection, sql_dataToAdd_complete)
  

  # -----------------------------------------------------------------------
  # Query database to confirm the data was written by checking first line of [dataFrameToAdd]
  
  # Run query used to check if data existed in the first place [sql_dataExistsCheckStatement]
  if( any( dbGetQuery(dbConnection, sql_dataExistsCheckStatement) ) ) {
    print("Data write successful - FUNCTION ENDS")
  } else {
    stop("ERROR: Data WAS NOT WRITTEN (based on check of first row in [dataFrameToAdd])")
  }
  
  # Close [dbConnection] ----------------------------------------------------
  print("Database disconnected:")
  dbDisconnect(dbConnection)

}

