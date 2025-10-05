library(rdflib)


# get historical data (only need once)

# load needed functions
source("R/functions/read_dcat_taiwan_opendata.R")

# These are links to all the traffic data for Taiwan
# from the open data portal

urls <- c("2024" = "https://data.gov.tw/dataset/172969",
          "2023" = "https://data.gov.tw/dataset/167905",
          "2022" = "https://data.gov.tw/dataset/161199",
          "2021" = "https://data.gov.tw/dataset/158865",
          "2020" = "https://data.gov.tw/dataset/158864",
          "2019" = "https://data.gov.tw/dataset/158863",
          "2018" = "https://data.gov.tw/dataset/158862",
          "historical" = "https://data.gov.tw/dataset/12197")



taiwan_accidents_historical <- lapply(urls, read_dcat) |> bind_rows()




