# Load the data
library(dplyr)
library(data.table)

# Load Historical Taipei Traffic Data From Data Folder --------------------
taipei_historical_zh <- fread("../data/Taipei Accidents (2012-2024).csv")


# load historical weather in environment ----------------------------------
weather_history_taipei_daily <- fread("data/weather_history_taipei_daily.csv")
weather_history_taipei_hourly <- fread("data/weather_history_taipei_hourly.csv")


# load historical weather and traffic dataset in environment --------------
tpe_hist_accident_weather <- fread("data/tpe_hist_accident_weather.csv")



