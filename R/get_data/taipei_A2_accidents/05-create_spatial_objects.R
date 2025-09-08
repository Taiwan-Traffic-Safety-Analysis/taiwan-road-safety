library(sf)
library(ggplot2)
library(leaflet)
library(dplyr)



taiwan_villages <- st_read("/home/russ/Downloads/OFiles_567e47a5-8819-4ece-8dbc-6d68492611f8/VILLAGE_NLSC_1140620.shp")

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


