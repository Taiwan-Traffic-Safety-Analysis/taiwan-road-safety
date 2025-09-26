library(stringr)
library(data.table)
library(httr)
library(jsonlite)
library(dplyr)
library(rdflib)

read_dcat <- function(url){
  
  
  # extract just the dataset id from the entire url
  dataset_id <- str_extract(url, "(?<=dataset/).*")
  
  # import .ttl (rdf DCAT lib) file
  download_url <- paste0("https://data.gov.tw/api/front/dataset/dcat.download?nid=", dataset_id)
  rdf <- rdf_parse(download_url, format = "turtle")
  
  query <- "
    PREFIX dcat: <http://www.w3.org/ns/dcat#>
    PREFIX schema: <http://schema.org/>

    SELECT ?s ?downloadURL ?encodingFormat WHERE {
      ?s dcat:downloadURL ?downloadURL .
      OPTIONAL { ?s schema:encodingFormat ?encodingFormat }
    }"
  
  
  query_results <- rdf %>% 
    rdf_query(query) 
  
  #%>% 
   # select(downloadURL) %>%
    #pull() #select urls add to string
  
  
# Create a list to store all the datasets
data_list <- list()
 
 for(i in 1:nrow(query_results)){
   
   
   url <- query_results[i,] |> 
     pull(downloadURL)
   
   encoding <- query_results[i,] |> 
     pull(encodingFormat)
   
   # send an httr request to the download URL
   res <- httr::GET(url)
   
   # detect the file type
  mime <- httr::http_type(res)
  
  # Save the content to temporary file
  tmp <- tempfile()
  writeBin(httr::content(res, "raw"), tmp)
   
   if(encoding == "UTF-8" & (mime == "text/csv" | mime == "application/vnd.ms-excel" )){
     
     data_list[[i]] <- lapply(fread(tmp), as.character)
     
   } else if(encoding == "BIG5" & (mime == "text/csv" | mime == "application/vnd.ms-excel" )){

     data_list[[i]] <- lapply(read.csv(tmp, fileEncoding = "BIG5", stringsAsFactors = FALSE), as.character)

   } else if(mime == "application/json"){
     
     data_list[[i]] <- lapply(jsonlite::fromJSON(tmp), as.character)
     
   } else if(mime == "application/zip"){
     
     zipped_data_list <- list()
     
     unzip_dir <- tempdir()
     unzipped_files <- unzip(tmp, exdir = unzip_dir)
     
     # Try to find first CSV file in zip
     csv_files <- unzipped_files[str_detect( unzipped_files, "\\.csv$")]
     
     if(length(csv_files) < 1) { 
       print(unzipped_files)
       stop("No csv files detected! fix the function")
       }
     
     for(file in csv_files){
       
       zipped_data_list[[file]] <- lapply(read.csv(file), as.character)
       
       
     }
     
     data_list[[i]] <- bind_rows(zipped_data_list)

   } else {
     
     print(mime)
     stop("Add code to deal with this new mime type")
   }
   
 }


# Coerce everything to a character (which will be annoying later...)


df  <- data_list |> bind_rows()
 
 

}


#taipei_data <- read_dcat("https://data.gov.tw/dataset/130110") 
  