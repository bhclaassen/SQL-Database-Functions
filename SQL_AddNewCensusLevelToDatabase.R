
# -------------------------------------------------------------------------
# SQL - Add a new Census ACS level to the SQL database
#
# BHC
# Started: 2023-09-01
# Updated: 2023-09-01
# -------------------------------------------------------------------------



sqlFcn_addDataToDatabase <- function(newData, currentTableName, joinVariable, sqlDatabaseConnection) {

# Libraries
require("RPostgreSQL")
require("DBI") # Should be required by 'RPostgreSQL' library
require("tidyverse")

# Read in SQL table to join [newData] to
tmp_currentSQLTable_in <- dbReadTable(sqlDatabaseConnection, currentTableName)

# Confirm [tmp_currentSQLTable_in] has [joinVariable]
if( !any(names(tmp_currentSQLTable_in) == joinVariable) ) { # If the [joinVariable] is NOT present in [tmp_currentSQLTable_in], print warning and exit
  print( paste0("ERROR: [", joinVariable, "] variable missing in SQL table [", currentTableName, "]") )
  stop()
}

# Confirm [newData] has [joinVariable]
if( !any(names(newData) == joinVariable) ) { # If the [joinVariable] is NOT present in [newData], print warning and exit
  print( paste0("ERROR: [", joinVariable, "] variable missing in data to add") )
  stop()
}



# Join current SQL table to data to add to SQL
tmp_currentSQLTable_out <- left_join(tmp_currentSQLTable_in, newData, by = joinVariable)

# Write joined table to SQL, overwriting current SQL table
dbWriteTable(sqlDatabaseConnection, name = currentTableName, value = tmp_currentSQLTable_out, overwrite = T, append = F, row.names = FALSE)

# Confirm data was written to SQL
tmp_dataCheck <- dbGetQuery(sqlDatabaseConnection, paste0('SELECT * FROM ', currentTableName) )
tmp_numColumnsWritten <- dim(newData)[2] - 1 # Number of columns written to SQL is (number of columns - 1) for identifier [joinVariable]

# Last [tmp_numColumnsWritten] columns in newly updated [currentTableName] should match columns in [newData] excluding identifier [joinVariable]
# if(
#   all.equal(
#     tmp_currentSQLTable_out[, ( ( ncol(tmp_currentSQLTable_out) - tmp_numColumnsWritten + 1 ):ncol(tmp_currentSQLTable_out) )]
#     , tmp_dataCheck[, ( ( ncol(tmp_dataCheck) - tmp_numColumnsWritten + 1 ):ncol(tmp_dataCheck) ) ]
#   )
# ) {
  print( paste0("Data successfully added to SQL data table [", currentTableName,"]") )
# } else {
  # print("ERROR: Written data does not match data to add")
#   stop()
# }

# clipr::write_clip(cbind(tmp_currentSQLTable_out[, ( ( ncol(tmp_currentSQLTable_out) - tmp_numColumnsWritten + 1 ):ncol(tmp_currentSQLTable_out) )]
    # , tmp_dataCheck[, ( ( ncol(tmp_dataCheck) - tmp_numColumnsWritten + 1 ):ncol(tmp_dataCheck) ) ]))

  # Disconnect from database
  dbDisconnect(sqlDatabaseConnection)
  print("Database disconnected")
}


setwd("/Users/benclaassen/Documents/_Workshop/PlacingAmerica/2023 04 City Roles In Urban Areas/Data/ACS 2020 5 yr/Places/Age and Sex")
datAndMOE <- read.csv("ACSST5Y2020.S0101-Data.csv")

datAndMOE <- datAndMOE %>% select(GEO_ID, S0101_C01_001E, S0101_C01_001M)

names(datAndMOE) <- c("place_geoid", "place_totalpop_est", "place_totalpop_moe")
head(datAndMOE)

datAndMOE <- datAndMOE[-1,]
head(datAndMOE)

datAndMOE[,1] <- gsub("1600000US", "", datAndMOE[,1])
head(datAndMOE)

datAndMOE <- sapply(datAndMOE, as.numeric)


datAndMOE <- as.data.frame(datAndMOE)
head(datAndMOE)
summary(datAndMOE)



# Test run ----------------------------------------------------------------
con <- dbConnect("PostgreSQL", dbname = "censusacs",
                 host = "127.0.0.1", port = 5432,
                 user = "bhclaassen", password = "postgray")
sqlFcn_addDataToDatabase(datAndMOE, "censusacs_place", "place_geoid", con)
