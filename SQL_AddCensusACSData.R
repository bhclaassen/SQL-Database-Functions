

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



sql_addCensusDataToDatabase <- function(dbConnection, sqlTableName, dataFrameToAdd) {#, variableID, variableName = "", dataSource, dataYear, dataOtherSpecs) {

  dbGetQuery(con, 'SELECT * FROM INFORMATION_SCHEMA.COLUMNS')
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
  

# -------------------------------------------------------------------------

  
  # If [dataFrameToAdd] does not have 3 column, throw error
  if(dim(dataFrameToAdd)[2] != 3) {
    stop("ERROR: Dataset must have 3 columns: {ID, Estimate, MOE}")
  }

# -------------------------------------------------------------------------

  
  
  
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

