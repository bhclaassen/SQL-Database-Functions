
# -------------------------------------------------------------------------
# Function to take data from long-form SQL database and transform it to a
#    wide-format dataframe
# Ben Claassen
# Started: 2023-09-15
# Updated: 2023-09-16
# -------------------------------------------------------------------------

pullSqlData <- function(dbConnection, sqlQuery, keepGeographyName = FALSE, closeConnection = TRUE) {
  
  # Steps -----------------------------------------------------------------
  
  # CHECKs
  ## ~DONE~ Confirm connection exists
  ## ~DONE~ Extract table name from query and confirm table exists
  
  # MAIN
  ## Pass the query to sql
  
  # PROCESSING
  ## Transform form long format to wide format
  ## Rename Est and MOE cols
  ## Gather Est and MOE columns together by variable
  
  # RETURN AND EXIT
  ## Close connection
  ## Return queried data
  

  # Libraries -------------------------------------------------------------
  require("tidyverse")
  require("RPostgreSQL")
  

  # ~ CHECKS ~  -----------------------------------------------------------
  # Confirm connection is valid -> [dbConnection] must be a "PostgreSQLConnection", else throw error
  if(class(dbConnection) != 'PostgreSQLConnection') {
    stop("ERROR: [dbConnection] must be a useable database connection")
  }
  

  # -----------------------------------------------------------------------
  # Extract sql table name from query
  sqlTableName_interim <- gsub("\\s+", " ", sqlQuery) # Replace any multiple-spaces with a single space
  sqlTableName_interim <- strsplit(sqlTableName_interim, " ") # Split query by space
  tmp_sqlQueryTableNameSegmentID <- which(sqlTableName_interim[[1]] == "FROM") # Find which single word in query is 'FROM' [table]
  sqlTableName <- sqlTableName_interim[[1]][tmp_sqlQueryTableNameSegmentID + 1] # Pull the [table] specified 1 word after 'FROM'
  
  
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


  # ~ MAIN ~  -------------------------------------------------------------
  # Pass query to SQL database
  dat_internal1 <- dbGetQuery(dbConnection, sqlQuery)


  # ~ PROCESSING ~  -------------------------------------------------------
  # Transform form long format to wide format
  # Col Names ->
  ##  - [geoid]
  ##  - [name] (if requested)
  ##  - [var est]
  ##  - [var moe]
  

  # Find columns to keep
  colName_geoid <- names(dat_internal1)[ grep("geoid", names(dat_internal1), ignore.case = TRUE) ]
  colName_varName <- names(dat_internal1)[ grep("var_name", names(dat_internal1), ignore.case = TRUE) ]
  colName_varEst <- names(dat_internal1)[ grep("var_est", names(dat_internal1), ignore.case = TRUE) ]
  colName_varMOE <- names(dat_internal1)[ grep("var_moe", names(dat_internal1), ignore.case = TRUE) ]
  
  
  tmp_colNum_name <- grep("name", names(dat_internal1), ignore.case = TRUE)
  colName_name <- names(dat_internal1)[ tmp_colNum_name[ -grep("var_name", names(dat_internal1)[tmp_colNum_name]) ] ]# Drop column number for 'x_var_name'
  
  
  # Collate columns to keep
  if(keepGeographyName) {
    colsToKeep <- c(colName_geoid, colName_name, colName_varName, colName_varEst, colName_varMOE)
  } else {
    colsToKeep <- c(colName_geoid, colName_varName, colName_varEst, colName_varMOE)
  }
  
  # Select columns to keep
  dat_internal2 <- dat_internal1 %>% select( all_of(colsToKeep) )
    

  # -----------------------------------------------------------------------
  # Transform data from long-format to wide-format
  dat_internal3 <- dat_internal2 %>% pivot_wider(names_from = colName_varName, values_from = all_of(c(colName_varEst, colName_varMOE)) )
  dat_internal3 <- as.data.frame(dat_internal3)
  
  # Rename Est and MOE cols -----------------------------------------------
  # Construct est var names
  varEsts_ColNums <- grep(".+_var_est_", names(dat_internal3))
  varEsts_newNames <- gsub(".+_var_est_", "", names(dat_internal3)[varEsts_ColNums])
  varEsts_newNames <- paste0(varEsts_newNames, "_est")
  
  # Construct MOE var names
  varMOEs_ColNums <- grep(".+_var_moe_", names(dat_internal3))
  varMOEs_newNames <- gsub(".+_var_moe_", "", names(dat_internal3)[varMOEs_ColNums])
  varMOEs_newNames <- paste0(varMOEs_newNames, "_moe")
  
  # Assign new names
  names(dat_internal3)[varEsts_ColNums] <- varEsts_newNames
  names(dat_internal3)[varMOEs_ColNums] <- varMOEs_newNames
  
  
  # Gather Est and MOE cols by variable -----------------------------------
  if(keepGeographyName) {
    dat_internal4 <- dat_internal3 %>% select( all_of( c(colName_geoid, colName_name, sort(names(dat_internal3)[-c(1:2)]) ) ) ) # Sort all but the first two names [id] [geographic name]
  } else {
    dat_internal4 <- dat_internal3 %>% select( all_of( c(colName_geoid, sort(names(dat_internal3)[-1]) ) ) ) # Sort all but the first name [id]
  }
  
  
  # ~ RETURN AND EXIT ~ ---------------------------------------------------
  # Close [dbConnection] --------------------------------------------------
  if(closeConnection) {
    print("Database disconnected:")
    dbDisconnect(dbConnection)
  }
  
  return(dat_internal4)
}
