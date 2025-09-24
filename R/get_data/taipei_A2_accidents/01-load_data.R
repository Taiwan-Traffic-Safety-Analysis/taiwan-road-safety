#load packages
library(dplyr)
library(rvest)
library(stringr)
library(data.table)
library(rdflib) 




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
  
  # Fix the column names for the random dataset where they added numbers 
  # at the start of the column names
  colnames(df) <- df |> 
                  colnames() |> 
                  str_remove("^\\d+(?=[\\p{Han}])")
  
  df
}

#load all csvs and combine into list
taipei_accidents_list <- lapply(urls, read_Big5_csv)



# Combine all years into one data.table, filling missing columns if needed
taipei_accidents_df <- rbindlist(taipei_accidents_list, fill = TRUE)


# remove intermediate files
rm(list = c("rdf", "taipei_accidents_list", "urls", "query", "url"))
  