library(dplyr)
library(rvest)
library(stringr)


# URL
dataset_url <- "https://data.gov.tw/dataset/13139"


# Load the data directly for Taiwan's data portal
# Using A2 level data (I'm still not sure what the different levels are)
# We're going to load whatever data is on the page dynamically
# So as the months progress, we'll always add new data to the database
dataset_html <- rvest::read_html(dataset_url)

#This is the html for the download links on the page
# We'll loop through it later to download the datasets
data_links <- dataset_html |> 
  html_nodes("div.table") |> 
  html_nodes(".table-row:nth-child(2)") |> 
  html_nodes(".table-cell") |>
  html_nodes("ul") |>
  html_nodes("a") |>
  html_attr("href")


# This will overwrite
# We are assuming that there will be a unique name for each csv file
# This is an assumption that will likely break in december....

if(Sys.Date() > "2025-12-01"){
  
  stop("Please figure out a better system for overwriting and storing data. If you don't, you'll likely overwrite Jan 2025 data with jan 2026 data!")
}
for(link in data_links){
  
  
  # extract the file name from the link
  file_name <- link |> str_extract("(?<=\\?DATA=).*")
  
  # paste on the folder and extension
  zip_file <- paste0( "data/", file_name, ".zip")
  
  # download the file as a zip file
  download.file(link, zip_file)
  
  # extract the zip file
  unzip(zipfile = zip_file, exdir = "data")
  
  # remove the old zip file
  file.remove(zip_file)
  
}



