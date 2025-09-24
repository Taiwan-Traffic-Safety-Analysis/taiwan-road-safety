pacman::p_load(tidyverse, #for stringr, dyplr & lubridate
               rvest, #for webscraping
               data.table, #for fast import and manupulation of .csv
               rdflib,
               openmeteo)

# Download, save and import historical weather data Taipei (15 years) ----------------
    # !!! the open meteo package also has location based weather data 
    # see: https://open-meteo.com/en/docs/air-quality-api
    
  # Download daily data
    weather_history_taipei_daily <-  weather_history(location = "Taipei",
                                                      start = "2012-01-01",
                                                      end = "2024-12-31",
                                                      daily = list("weather_code",
                                                                   "temperature_2m_mean",
                                                                   "temperature_2m_max",
                                                                   "temperature_2m_min",
                                                                   "apparent_temperature_mean",
                                                                   "apparent_temperature_max",
                                                                   "apparent_temperature_min",
                                                                   "sunrise",
                                                                   "sunset",
                                                                   "daylight_duration",
                                                                   "sunshine_duration",
                                                                   "precipitation_sum",
                                                                   "precipitation_hours",
                                                                   "wind_speed_10m_max",
                                                                   "wind_gusts_10m_max",
                                                                   "wind_direction_10m_dominant")
                                                      )

  # Download hourly data
    weather_history_taipei_hourly <-  weather_history(location = "Taipei",
                                                      start = "2012-01-01",
                                                      end = "2024-12-31",
                                                      hourly = list("temperature_2m",
                                                                    "precipitation",
                                                                    "windspeed_10m",
                                                                    "cloudcover",
                                                                    "apparent_temperature",
                                                                    "weather_code",
                                                                    "wind_direction_10m",
                                                                    "wind_gusts_10m")
                                                      )
  # Save both datasets
    fwrite(weather_history_taipei_daily, "data/weather/weather_history_taipei_daily.csv",
           sep = ",",
           quote = TRUE,
           na = "",
           bom = TRUE,
           row.names = FALSE,
           dateTimeAs = "ISO",
           logical01 = FALSE)
    
    
    fwrite(weather_history_taipei_hourly, "data/weather/weather_history_taipei_hourly.csv",
           sep = ",",
           quote = TRUE,
           na = "",
           bom = TRUE,
           row.names = FALSE,
           dateTimeAs = "ISO",
           logical01 = FALSE)

