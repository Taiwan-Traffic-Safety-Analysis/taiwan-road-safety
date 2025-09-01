#load packages
pacman::p_load(dplyr,
               rvest,
               data.table,
               rdflib,
               openmeteo) 


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

# Taipei City Traffic Data - Open Data Portal - 2012-2024 ------------------
# import .ttl (rdf DCAT lib) file
url <- "https://data.gov.tw/api/front/dataset/dcat.download?nid=130110"
rdf <- rdf_parse(url, format = "turtle")

# obtain the yearly .csv file links form the rdf file
query <- "PREFIX dcat: <http://www.w3.org/ns/dcat#>
                SELECT ?s ?downloadURL WHERE {
                ?s dcat:downloadURL ?downloadURL .
                }" #using SPARQL to read triples (data structure of RDF) containing Subjects, Predicates and Objects for each triple

urls <- rdf %>% 
  rdf_query(query) %>% 
  select(downloadURL) %>%
  pull() #select urls add to string

# download all csv data at ones and deal with strange "Big5" encoding (not natively supported in fread)

# create function to properly import Big5 encoded csv 
read_Big5_csv <- function(url) {
  raw_lines <- readLines(url, encoding = "bytes", warn = FALSE)
  utf8_lines <- iconv(raw_lines, from = "Big5", to = "UTF-8")
  df <- fread(text = utf8_lines)
  df
}

#load all csvs and combine into list
taipei_accidents_list <- lapply(urls, read_Big5_csv)

# Combine all years into one data.table, filling missing columns if needed
taipei_accidents_df <- rbindlist(taipei_accidents_list, fill = TRUE)
  