library(sf)
library(ggplot2)
library(leaflet)

taiwan_villages <- st_read("/home/russ/Downloads/OFiles_567e47a5-8819-4ece-8dbc-6d68492611f8/VILLAGE_NLSC_1140620.shp")



# convert unique accidents to sf object
unique_accidents_sf <- unique_accidents |>
                       filter(!is.na(座標_X)) |>
                       st_as_sf(coords = c(x = "座標_X", y = "座標_Y"),
                                crs = st_crs(taiwan_villages))


fatal_accidents <- unique_accidents |>
                   filter(死亡人數 > 0)


fatal_accidents_sf <- unique_accidents_sf |>
  filter(死亡人數 > 0)



taiwan_villages |>
  filter(COUNTYNAME == "臺北市") |>
  ggplot() +
  geom_sf() +
  geom_sf(data = fatal_accidents_sf)



fatal_accidents_sf |>
  leaflet() |>
  addProviderTiles(providers$CartoDB.Positron) |>
  addCircleMarkers(     radius = ~ (死亡人數 * 4),
                        stroke = FALSE,
                        fillOpacity = 0.5,
                        
                        # the label is the thing that appears on hover
                        label = ~死亡人數,
                       
                         # The popup is the thing that appears on click
                        popup = ~paste(
                          "<b>Date:</b>", 發生日期, "<br>",
                          "<b>Time:</b>", 發生時間, "<br>",
                          "<b>District:</b>",區序 , "<br>",
                          "<b>Location:</b>",肇事地點 , "<br>",
                          "<br>",
                          
                          
                          "<b>Deaths:</b>", 死亡人數, "<br>",
                          "<b>Injuries:</b>", 受傷人數, "<br>",
                          "<b>Accident ID:</b>", accident_id
                        ),
                       
                         fillColor = "blue",
                        group = "default_size")

