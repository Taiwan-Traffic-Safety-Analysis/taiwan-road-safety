# Load the data
library(dplyr,data.table)


# create a blank list for the data
data_list <- list()
i <- 1

# Read the data into the list
for(file in list.files("data", full.names = TRUE)){
  
  
  if(file %in% c("data/file.csv", "data/manifest.csv", "data/schema-file.csv")){
    
    print(paste("skipping", file))
    
  } else {
    
    data_list[[i]] <- read.csv(file)
    # increase iterator
    i <- i + 1
    
  }
  

}

# combine the list into a dataframe
data_set <- data_list |> dplyr::bind_rows()


# Load Historical Taipei Traffic Data From Data Folder --------------------
taipei_historical_zh <- fread("data/Taipei accidents (2012-2024).csv")

