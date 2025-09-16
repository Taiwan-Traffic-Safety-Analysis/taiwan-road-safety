# Load and update libraries
pacman::p_load(tidyverse,matchmaker, deeplr, polyglotr, data.table, update = F )

#' while the code works to create a dictionary, most of the values that are in chinese are
#' locations like "中山區市民大道2段與新生北路西側附近1段口新生北路西側迴轉道" >>>
#' "Xinsheng North Road west side turnaround at the intersection of Section 2 of Shimin 
#' Avenue and Section 1 of Xinsheng North Road, Zhongshan District" and those are super hard to
#' geocode. Therefore it might be quite useless to translate as is. Maybe we can use some LM model 
#' to obtain an approc location? than it might be usefull, but if we then obtain lon lats, translation is not needed

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
  
  # one by one translation with polyglotr (free google translate, but slow)
    # make a translation function that can handle large requests 1x1
      safe_translate <- function(txt) {
        Sys.sleep(.05)
        google_translate(txt,target_language = "en",source_language = "zh-TW")
        # toEnglish2(txt, source_lang = "ZH", auth_key = deepLapi) #alternatively use deepL's free api
      }
      
    # translate (takes hours, so split in batches not to loose progress)x
      
      # make dictionary 
     
      
      
  # export dictionary 
     
      

# translate complete translated dataset -----------------------------------
    taipei_historical_en <- taipei_historical_zh %>% 
      match_df(
        dictionary = dictionary_zh_en,
        from = "value_zhTW",
        to = "value_en",
        by = ""
      )
    
    
    
  
   