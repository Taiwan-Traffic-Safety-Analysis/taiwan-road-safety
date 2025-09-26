#load packages
pacman::p_load(dplyr,
               rvest,
               stringr,
               data.table,
               rdflib,
               openmeteo) 


# URL
urls <- c("2025_A2" = "https://data.gov.tw/dataset/13139",
          "2025_A1" = "https://data.gov.tw/dataset/12818" )



taiwan_2025 <- lapply(urls, read_dcat) |> bind_rows()

