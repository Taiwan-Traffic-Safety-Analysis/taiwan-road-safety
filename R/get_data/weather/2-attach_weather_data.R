pacman::p_load(tidyverse, #for stringr, dyplr & lubridate
               rvest, #for webscraping
               data.table, #for fast import and manupulation of .csv
               rdflib,
               openmeteo)



# left join weather with historical traffic -------------------------------

    
    # left join with weather
    taipei_accidents_eng_weather <- taipei_accidents_eng %>%  
      left_join(weather_history_taipei_daily, by=c("incident_date" = "date")) %>% 
      left_join(weather_history_taipei_hourly,
                by=c("incident_datetime" = "datetime")) %>% 
      arrange(incident_datetime)
    
    
    # export to csv
      fwrite(taipei_accidents_eng_weather, "data/taipei_accidents/tpe_hist_accident_weather.csv",
             sep = ",",
             quote = TRUE,
             na = "",
             bom = TRUE,
             row.names = FALSE,
             dateTimeAs = "ISO",
             logical01 = FALSE)


    
    
    
  