library(readODS)
library(dplyr)
library(janitor)
library(tidyr)
library(stringr)


# we'll start with 2024

# The data for all years for Taipei is here on this site: https://ca.gov.taipei/News_Content.aspx?n=8693DC9620A1AABF&sms=D19E9582624D83CB&s=E70E0ADF8510073C
# The entire population of Taiwan can be found here: https://pop-proj.ndc.gov.tw/api/v3/page#/


taipei_pop_2024_url <- "https://www-ws.gov.taipei/Download.ashx?u=LzAwMS9VcGxvYWQvMzM0L3JlbGZpbGUvMTYxMjEvMjU1MDgzOC83MzVkN2JiMC03YjMwLTQzZmQtODVkYi1iNTAyY2FmZWNmNmMub2Rz&n=MTEz5bm0MS0xMuaciOWQhOWNgOaMieW5tOm9oeS6uuWPo%2baVuC5vZHM%3d&icon=..ods"



load_population <- function(data_url){
  
  data_location <- "data/population_data"
  
  if(!dir.exists(data_location)){
    
    # create a folder for caching the shape files
    dir.create(data_location, recursive = TRUE)
    
  }

    # Define local paths
    ods_file <- tempfile(fileext = ".ods")
    
    # Download the ZIP file
    download.file(data_url, destfile = ods_file, mode = "wb")
    
    df <- read_ods(ods_file) |>
      row_to_names(row_number = 1)
    
    # Unzip the contents
    #archive::archive_extract(zip_file, dir = "data/shapefiles/villages")
    
    df_long <- df |>
      pivot_longer(
        cols = starts_with("合計_") | matches("^\\d+歲") | matches("總計"),
        names_to = "age_category",
        values_to = "population"
      ) |>
      
      # convert population to a number (uhh duhh)
      mutate(population = as.numeric(population)) |> 
      
      # remove the word sui from ages
      mutate(age_category = str_squish(str_remove_all(age_category,"歲|合計_|以上" ))) |>
      rename(district = `區 域 別`,
             sex = 性別)
      
    
    df_long
  
}

# load the data
taipei_pop_2024_zh <- load_population(taipei_pop_2024_url)

# write to file
write.csv(taipei_pop_2024_zh, 
          "data/population_data/taipei_pop_2024_zh.csv",
          row.names = FALSE )


# translate to english
#taipei_pop_2024_eng <- taipei_pop_2024_zh |>
 #                      mutate(district = case_match(`區 域 別`, 
  #                                                  "總  計" ~ "Total",
   #                                                 ))




