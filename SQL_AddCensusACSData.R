

# -------------------------------------------------------------------------
# -------------------------------------------------------------------------
# Test variables


require("RPostgreSQL")
require("tidyverse")

# Setup connection with database
con <- dbConnect("PostgreSQL", dbname = "themines",
                 host = "127.0.0.1", port = 5432,
                 user = "benclaassen", password = "")
# Test connection
dbGetQuery(con, 'SELECT * FROM states_info')


# -------------------------------------------------------------------------

pop5 <- pop4[,c(1:2)]
head(pop5)
names(pop5) <- c("state_geoid", "state_name")

pop5$st_var_id <- "S0101_C01_001"
pop5$st_var_name <- "TotalPopulation"
pop5$st_var_est <- pop4[,3]
pop5$st_var_moe <- pop4[,4]

pop5$st_var_source <- "Census ACS"
pop5$st_var_year <- "2020"
pop5$st_var_otherspecs <- "5yr estimates"

head(pop5)





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
dbConnection = con
sqlTableName = "states"
dataFrameToAdd = pop5
# -------------------------------------------------------------------------



sql_addCensusDataToDatabase <- function(dbConnection, sqlTableName, dataFrameToAdd) {


# Shorthand steps ---------------------------------------------------------
# ~DONE~ check for input errors
# ~DONE~ set connection
# ~DONE~ pull table names
# ~DONE~ confirm sql table names match input data.frame table names
# convert [dataFrameToAdd] to sql format
# write [dataFrameToAdd] to table
# close db connection

  

# -------------------------------------------------------------------------
# START FCN UPDATE --------------------------------------------------------
# -------------------------------------------------------------------------


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
      stop("ERROR: Names of input table [dataFrameToAdd] do not match names of [sqlTableName] (Column 1: 'rowid' EXCLUDED)")
    }
  } else if( !( identical( sqlTableColumnNames, names(dataFrameToAdd) ) ) ) { # ...ELSE, first sql table column name is not the SERIAL var 'rowid', THEN all names must match
    stop("ERROR: Names of input table [dataFrameToAdd] do not match names of [sqlTableName] (Column 1: 'rowid' INCLUDED)")
  }
  
  
# -------------------------------------------------------------------------
# UPDATED TO HERE ---------------------------------------------------------
# -------------------------------------------------------------------------


  
  
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




# -------------------------------------------------------------------------
# -------------------------------------------------------------------------


  
}
## get sql col names ->
dbGetQuery(con, 'SELECT * FROM states WHERE false')

