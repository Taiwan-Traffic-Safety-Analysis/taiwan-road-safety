library(sf)
library(data.table)

# save the data we want to keep to the cached data folder
DATA_FOLDER <- "data/taipei_accidents"

# csv
fwrite(taipei_accidents_eng, paste0(DATA_FOLDER, "/taipei_accidents_eng.csv"))
fwrite(taipei_accidents_zh, paste0(DATA_FOLDER, "/taipei_accidents_zh.csv"))
fwrite(unique_accidents, paste0(DATA_FOLDER, "/unique_accidents.csv"))
fwrite(fatal_accidents, paste0(DATA_FOLDER, "/fatal_accidents.csv"))

#geojson
st_write(fatal_accidents_sf, 
        paste0(DATA_FOLDER, "/fatal_accidents_sf.geojson"),
        delete_dsn = TRUE)

st_write(unique_accidents_sf, 
         paste0(DATA_FOLDER, "/unique_accidents_sf.geojson"),
         delete_dsn = TRUE)

st_write(points_in_villages,
         paste0(DATA_FOLDER, "/points_in_villages.geojson"),
         delete_dsn = TRUE)

st_write(taipei_villages,
         paste0(DATA_FOLDER, "/taipei_villages.geojson"),
         delete_dsn = TRUE)

st_write(taiwan_villages,
         paste0(DATA_FOLDER, "/taiwan_villages.geojson"),
         delete_dsn = TRUE)
