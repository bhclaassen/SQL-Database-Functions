


# -------------------------------------------------------------------------
# Function to take data from long-form SQL database and transform it to a
#    wide-format dataframe
# Ben Claassen
# Started: 2023-09-15
# Updated: 2023-09-15
# -------------------------------------------------------------------------

require("tidyverse")
require("RPostgreSQL")

# Setup connection with database
con <- dbConnect("PostgreSQL", dbname = "themines",
                 host = "127.0.0.1", port = 5432,
                 user = "benclaassen", password = "")

# Internal function values ------------------------------------------------

dbConnection <- con
sql_givenQuery <- "SELECT *    FROM states WHERE state_geoid < 100"
head(
  dbGetQuery(con, sql_givenQuery)
)

# -------------------------------------------------------------------------

pullSqlData <- function(dbConnection, sql_givenQuery) {
  
  # Steps:
  # ~DONE~ Confirm connection exists
  # ~DONE~ Confirm table exists
  # Pass the query to sql
  # Transform form long format to wide format
  

  # Libraries -------------------------------------------------------------
  require("tidyverse")
  require("RPostgreSQL")
  
  # Confirm connection is valid -> [dbConnection] must be a "PostgreSQLConnection", else throw error
  if(class(dbConnection) != 'PostgreSQLConnection') {
    stop("ERROR: [dbConnection] must be a useable database connection")
  }
  
  
  # Extract sql table name from query
  sqlTableName_interim <- gsub("\\s+", " ", sql_givenQuery) # Replace any multiple-spaces with a single space
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
    
    

  
  
  
  
  
  return()
}