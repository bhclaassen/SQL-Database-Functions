


# -------------------------------------------------------------------------
# Function to take data from long-form SQL database and transform it to a
#    wide-format dataframe
# Ben Claassen
# Started: 2023-09-15
# Updated: 2023-09-16
# -------------------------------------------------------------------------

require("tidyverse")
require("RPostgreSQL")

# Setup connection with database
con <- dbConnect("PostgreSQL", dbname = "themines",
                 host = "127.0.0.1", port = 5432,
                 user = "benclaassen", password = "")

# Internal function values ------------------------------------------------

dbConnection <- con
keepGeographyName = FALSE
closeConnection = TRUE

sqlQuery <- "SELECT *    FROM states WHERE st_var_name = 'TotalPopulation'"
head(
  dbGetQuery(con, sqlQuery)
)
dim(
  dbGetQuery(con, sqlQuery)
)

# -------------------------------------------------------------------------

# pullSqlData <- function(dbConnection, sqlQuery, keepGeographyName = FALSE, closeConnection = TRUE) {
  
  # Steps -----------------------------------------------------------------
  
  # CHECKs
  ## ~DONE~ Confirm connection exists
  ## ~DONE~ Extract table name from query and confirm table exists
  
  # MAIN
  ## Pass the query to sql
  
  # PROCESSING
  ## Transform form long format to wide format
  
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
  colName_geoid <- grep("geoid", names(dat_internal1))
  colName_name <- grep("", names(dat_internal1))
  colName_varEst <- grep("", names(dat_internal1))
  colName_varMOE <- grep("", names(dat_internal1))
  
  # Collate columns to keep
  if(keepGeographyName) {
    varNamesToKeep <- c()
  } else {
    varNamesToKeep <- c()
  }
  
  # Select columns to keep
  dat_internal2 <- dat_internal1 %>% 
    
  # Rename columns
  
    

  # -----------------------------------------------------------------------
  # Transform data from long-format to wide-format
  
    
  
  
  
  
  
  # ~ RETURN AND EXIT ~ ---------------------------------------------------
  # Close [dbConnection] --------------------------------------------------
  if(closeConnection) {
    print("Database disconnected:")
    dbDisconnect(dbConnection)
  }
  
  return(...)
# }
