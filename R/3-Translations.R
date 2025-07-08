# Load and update libraries
pacman::p_load(tidyverse,matchmaker, data.table,update = F)

remotes::install_github("Tomeriko96/polyglotr", force=T) # need to use development version for now because of bug in iso lang code in CRAN version
library(polyglotr)

# create dictionary from historical Taipei data frame -----------------------
  # Unicode traditional mandarin range
    chinese_regex <- "[\\u4e00-\\u9fff]+" #should cover most according to Gemini
  
  # obtain unique Traditional Chinese values from complete dataframe
    unique_zh_values <- taipei_historical_zh %>%
      select(where(is.character)) %>% 
      map(~ str_extract_all(.x, chinese_regex) %>% unlist()) %>%
      unlist() %>% # Flatten the list of vectors into a single vector
      na.omit() %>% # Remove any NA values (from strings without Chinese text)
      unique() # Get only the distinct entries
    
  # check if randomly selected values are in Mandarin
    unique_zh_values %>% sample(10) %>% detect2(deepLapi) %>% str_equal("ZH")
    
  # translate with gpolyglotr
    dictionary_zh_en <- unique_zh_values %>% 
      as.data.frame() %>% 
      rename(value_zhTW = 1) %>% 
      mutate(value_en = google_translate(value_zhTW, 
                                         target_language = "en", 
                                         source_language = "zh-TW")
             )
     
  # export dictionary 
    fwrite(dictionary_zh_en, "data/Taipei_Accidents (2012-2024)_Dictionary zhTW - en.csv")
    
  
   