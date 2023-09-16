
# -------------------------------------------------------------------------
# Function to add Census data to SQL database
# Ben Claassen
# Started: 2023-08-04
# Updated: 2023-09-16
# -------------------------------------------------------------------------

sql_addCensusDataToDatabase <- function(dbConnection, sqlTableName, dataFrameToAdd, closeConnection = TRUE) {
  
  # Libraries -------------------------------------------------------------
  require("tidyverse")
  require("RPostgreSQL")
  

# Steps -------------------------------------------------------------------
# CHECKS
## ~DONE~ check for input errors
## ~DONE~ confirm connection
## ~DONE~ confirm sql table names match input data.frame table names
## ~DONE~ check if data already exists

# PROCESSING
## ~DONE~ convert [dataFrameToAdd] to sql format

# MAIN 
## ~DONE~ write [dataFrameToAdd] to table

# CHECK
## ~DONE~ confirm first row of [dataFrameToAdd] is in sql table

# EXIT  
## ~DONE~ close db connection
# -------------------------------------------------------------------------


  
  # ~ Checks ~ ------------------------------------------------------------
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
  
  

  # -----------------------------------------------------------------------
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
  
  
  # ~ PROCESSING ~ --------------------------------------------------------
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
  
  

  # ~ MAIN ~  ------------------------------------------------------------
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
  

  # ~ CHECK ~ -------------------------------------------------------------
  # Query database to confirm the data was written by checking first line of [dataFrameToAdd]
  
  # Run query used to check if data existed in the first place [sql_dataExistsCheckStatement]
  if( any( dbGetQuery(dbConnection, sql_dataExistsCheckStatement) ) ) {
    print("Data write successful - FUNCTION ENDS")
  } else {
    stop("ERROR: Data WAS NOT WRITTEN (based on check of first row in [dataFrameToAdd])")
  }
  

  # ~ EXIT ~ --------------------------------------------------------------
  # Close [dbConnection] --------------------------------------------------
  if(closeConnection) {
    print("Database disconnected:")
    dbDisconnect(dbConnection)
  }

}
