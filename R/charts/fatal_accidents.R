library(sf)
library(ggplot2)
library(leaflet)
library(dplyr)



# deaths per li
  ggplot(data = taipei_villages) +
  geom_sf(aes(fill= deaths_and_accidents))+
    # Use a perceptually uniform color scale (e.g., viridis)
    scale_fill_viridis_c() +
    labs(
      title = "Deaths and Accidents per village In Taipei 2016-2025",
      fill = "Total Deaths and Accidents"
    ) +
    theme_minimal() + 
    geom_sf(data = fatal_accidents_sf)

  # deaths as points overlapped over lis
  taipei_villages  |>
    ggplot() +
    geom_sf() +
    geom_sf(data = fatal_accidents_sf)
  


# zoomable map of fatal accidents as points
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



# zoomable overlay of accidents per polygon over map of Taipei

# Example for a continuous numeric variable (e.g., 'value')
pal_numeric <- leaflet::colorNumeric(palette = "viridis", domain = taipei_villages$deaths)


taipei_villages |>
  leaflet() |>
  addProviderTiles(providers$CartoDB.Positron) |>
  addPolygons(fillColor = ~pal_numeric(deaths), 
              fillOpacity = 0.5,
              stroke = FALSE,
              popup = ~paste("<b>District:</b>", TOWNNAME, "<br>",
                            "<b>Li:</b>", VILLNAME, "<br>",
                            "<b>Deaths:</b>",deaths , "<br>",
                            "<b>Accidents:</b>",accidents , "<br>",
                            "<b>Deaths and Accidents:</b>", deaths_and_accidents
                            
              ))



