library(archive)
library(dplyr)
library(sf)





# Check to see if the shapefiles already exist
# download them if they don't

load_shapefiles <- function(){

if(!dir.exists("data/shapefiles/villages")){
  
  # create a folder for caching the shape files
  dir.create("data/shapefiles/villages", recursive = TRUE)
  
  # Define URL of the ZIP file containing shapefiles
  zip_url <- "https://data.moi.gov.tw/MoiOD/System/DownloadFile.aspx?DATA=B8AF344F-B5C6-4642-AF46-1832054399CE"
  
  # Define local paths
  zip_file <- tempfile(fileext = ".zip")
  
  # Download the ZIP file
  download.file(zip_url, destfile = zip_file, mode = "wb")
  
  # Unzip the contents
  archive::archive_extract(zip_file, dir = "data/shapefiles/villages")
  
  
}


# List all the  files in the villages folder
files <- list.files("data/shapefiles/villages", full.names = TRUE)

# Find the .shp file in the extracted files
shp_file <- files[grepl("NLSC_.*\\.shp$", files)][1]

# Read the shapefile into an sf object
taiwan_villages <- st_read(shp_file)

taiwan_villages

}

taiwan_villages <- load_shapefiles()

#taiwan_villages <- st_read("/home/russ/Downloads/OFiles_567e47a5-8819-4ece-8dbc-6d68492611f8/VILLAGE_NLSC_1140620.shp")

taipei_villages <- taiwan_villages |>
  filter(COUNTYNAME == "臺北市")





# convert unique accidents to sf object
unique_accidents_sf <- unique_accidents |>
  filter(!is.na(座標_X)) |>
  st_as_sf(coords = c(x = "座標_X", y = "座標_Y"),
           crs = st_crs(taiwan_villages))


fatal_accidents <- unique_accidents |>
  filter(死亡人數 > 0)


fatal_accidents_sf <- unique_accidents_sf |>
  filter(死亡人數 > 0)


# assign a polygon (li) to each point
points_in_villages <- st_join(unique_accidents_sf,
                              taipei_villages, 
                              join = st_intersects)

# summarize deaths and accidents
accidents_by_village <- points_in_villages %>%
  group_by(VILLCODE) %>%
  summarize(deaths = sum(死亡人數),
            accidents = sum(受傷人數)) |> 
  mutate(deaths_and_accidents = deaths + accidents) |>
  st_drop_geometry()


# reattach summaries to taipei villages
taipei_villages <- taipei_villages |>
  left_join(accidents_by_village)


