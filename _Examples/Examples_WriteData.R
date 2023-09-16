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

require("RPostgreSQL")
require("tidyverse")

# Setup connection with database
con <- dbConnect("PostgreSQL", dbname = "themines",
                 host = "127.0.0.1", port = 5432,
                 user = "benclaassen", password = "")
# Test connection
head(
  dbGetQuery(con, 'SELECT * FROM states_info')
)


# -------------------------------------------------------------------------
# Example with population write -------------------------------------------

setwd("/Users/benclaassen/Documents/_Mines/Data_MAIN/_RawDownloads/Census/ACS 2020 5yr/States/Age and Sex")# setwd("/Users/benclaassen/Documents/_Mines/Data_MAIN/_Ra# # setwd("/Users/benclaassen/Documents/_Mines/Data_MAIN/_RawDownloads/Census/ACS 2020 5yr/States/Age and Sex
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


pop4 <- pop3 %>% select(Id, StateName, TotalPop_Est, TotalPop_MOE)

head(pop4)
sapply(pop4, class)


pop5 <- pop4[,c(1:2)]
head(pop5)
names(pop5) <- c("state_geoid", "state_name")

pop5$st_var_id <- "S0101_C01_001"
pop5$st_var_name <- "TotalPopulation"
pop5$st_var_est <- pop4[,3]
pop5$st_var_moe <- pop4[,4]

pop5$st_var_source <- "Census ACS"
pop5$st_var_year <- 2020
pop5$st_var_otherspecs <- "5yr estimates"

head(pop5)

# Example with income write -----------------------------------------------

setwd("/Users/benclaassen/Documents/_Mines/Data_MAIN/_RawDownloads/Census/ACS 2020 5yr/States/Median Income")
inc1 <- read.csv("ACSST5Y2020.S1903-Data.csv") # Read data

inc2 <- inc1 %>% select(GEO_ID, NAME, S1903_C03_001E, S1903_C03_001M) # Select cols

names(inc2) <- c("GEO_ID", "StateName", "MedianHHIncome_Est", "MedianHHIncome_MOE") # Rename cols
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
inc3 <- inc2 %>% mutate(MedianHHIncome_MOE = replace_na(MedianHHIncome_MOE, 0))
summary(inc3)
head(inc3)


inc4 <- inc3 %>% select(Id, StateName, MedianHHIncome_Est, MedianHHIncome_MOE)
head(inc4)
sapply(inc4, class)

# Add vars for sql table col match
inc5 <- inc4[,c(1:2)]
head(inc5)
names(inc5) <- c("state_geoid", "state_name")

inc5$st_var_id <- "S1903_C03_001"
inc5$st_var_name <- "MedianHHIncome"
inc5$st_var_est <- inc4[,3]
inc5$st_var_moe <- inc4[,4]

inc5$st_var_source <- "Census ACS"
inc5$st_var_year <- 2020
inc5$st_var_otherspecs <- "5yr estimates"

head(inc5)
sapply(inc5, class)


# -------------------------------------------------------------------------
# Internal function parameters
# dbConnection = con
# sqlTableName = "states"
# dataFrameToAdd = pop5
# -------------------------------------------------------------------------


# Write data using function
sql_addCensusDataToDatabase(dbConnection = con, sqlTableName = "states", dataFrameToAdd = pop5, ifCloseConnection = FALSE)
sql_addCensusDataToDatabase(dbConnection = con, sqlTableName = "states", dataFrameToAdd = inc5, ifCloseConnection = FALSE)
#

