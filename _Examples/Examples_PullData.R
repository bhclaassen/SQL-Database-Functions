
require("tidyverse")
require("RPostgreSQL")

# Setup connection with database
con <- dbConnect("PostgreSQL", dbname = "themines",
                 host = "127.0.0.1", port = 5432,
                 user = "benclaassen", password = "")

# Internal function values ------------------------------------------------

dbConnection <- con
keepGeographyName = TRUE
closeConnection = FALSE

# sqlQuery <- "SELECT *    FROM states WHERE st_var_name = 'TotalPopulation'"
sqlQuery <- "SELECT *    FROM states WHERE state_geoid < 100 "

head(
  dbGetQuery(con, sqlQuery)
)
dim(
  dbGetQuery(con, sqlQuery)
)


# sqlQuery <- "SELECT *    FROM states WHERE st_var_name = 'TotalPopulation'"
sqlQuery <- "SELECT *    FROM states WHERE state_geoid < 100 "
head(pullSqlData(con, sqlQuery, TRUE, FALSE))
