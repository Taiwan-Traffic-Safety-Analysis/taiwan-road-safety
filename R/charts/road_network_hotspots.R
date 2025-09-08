# Install and load necessary packages
# install.packages(c("osmdata", "sf", "sfnetworks", "dodgr", "dbscan", "tmap"))
library(osmdata)
library(sf)
library(ggplot2)
library(leaflet)
library(dplyr)
library(sfnetworks)
library(tidygraph)
library(spatstat.linnet)
library(spatstat.geom)

# 1. create an sf object for Taipei's road network
q <- opq("Taipei, Taiwan") %>%
  add_osm_feature(
    key = "highway",
    value = c("motorway",
              "trunk", 
              "primary", 
              "secondary",
              "tertiary",
              "residential", 
              "unclassified" , 
              "service" , 
              "track"
              ))  %>%
  osmdata_sf()


# 1. transform the crs of the road network to match li shapefile
taipei_roads_sf <- q$osm_lines %>% st_transform(st_crs(taipei_villages))


# crop the roads to only include Taipei city

# create a Taipei outline
taipei_outline <- taipei_villages |> st_union()

# crop
cropped_roads <- st_intersection(taipei_roads_sf, taipei_outline)

# filter for only streets with names
filtered_roads <- cropped_roads |>
  
               # remove footways
               filter(!(highway %in% c("footway",
                                       "cycleway",
                                       "platform",
                                       "steps",
                                       "ladder" #, 
                                   #    "path" #, 
                                      # "corridor"
                                      )),
                      !(service %in% c("parking_aisle",
                                       "driveway",
                                       "driving_learning")),
                      
                      !(highway == "path" & is.na(service))) 

# remove multistring lines
geometry_types <- st_geometry_type(filtered_roads)

filtered_roads <- filtered_roads[geometry_types != "MULTILINESTRING", ]

# check roads
filtered_roads |> 
  leaflet() |> 
  addTiles() |> 
  addPolygons(popup = ~ paste("<b>name:</b>", `name:zh`, "<br>",
                              "OSM ID:", osm_id, "<br>",
                              "Higway Type:", highway,"<br>",
                              "Service Type:", service,"<br>",
                              "Track Type:", tracktype
                              ))






# Convert to sfnetwork object
roads_net <- as_sfnetwork(filtered_roads, directed = FALSE)


road_intersections <- roads_net %>%
  activate("nodes") %>%
  st_as_sf()


road_edges <- roads_net %>%
  activate("edges") %>%
  st_as_sf()

#simplify out multi edges and loops
# see: https://luukvdmeer.github.io/sfnetworks/articles/sfn02_preprocess_clean.html#network-cleaning-functions
simple_road_edges <- roads_net %>%
  activate("edges") %>%
  filter(!edge_is_multiple()) %>%
  filter(!edge_is_loop()) %>%
  st_as_sf()

simple_road_edges |>
  leaflet() |>
  addTiles() |>
  addPolylines()|>
  addCircleMarkers( data= road_intersections,
                    radius = 4,
                    stroke = FALSE,
                    fillOpacity = 0.9,
                    
                    fillColor = "black",
                    group = "default_size")



road_intersections |>
  leaflet() |>
  addTiles() |>
  addCircleMarkers( radius = 4,
                    stroke = FALSE,
                    fillOpacity = 0.5,
                  
              
                    
                    fillColor = "blue",
                    group = "default_size")




# From here on be dragons ------------------------------------------------

# Ensure your roads are LINESTRINGs
simple_road_edges <- st_cast(simple_road_edges, "LINESTRING")

# Make sure CRS is projected in meters (important for distances!)
simple_road_edges <- st_transform(simple_road_edges, 3826)  # Taipei TM2

# make sure CRS is projected in meters
simple_road_edges <- st_transform(simple_road_edges, 3826)

# Extract only geometry (sfc)
roads_sfc <- st_geometry(simple_road_edges)

# Convert sfc -> psp
roads_psp <- as.psp(roads_sfc)

# 5. Convert psp -> linnet (this works directly!)
lnet <- as.linnet(roads_psp)

plot(lnet)







# Convert sfnetwork -> linnet (linear network object)
lnet <- as.linnet(simple_road_edges)

# Snap accident points to nearest edge on the network
accidents_snapped <- st_snap(accidents, st_as_sf(roads_net, "edges"), tolerance = 10)

# Convert accidents to spatstat ppp, then to lpp (linear point pattern)
acc_ppp <- as.ppp(accidents_snapped)
acc_lpp <- lpp(acc_ppp, lnet)

# Kernel density estimation along the network
dens <- density.lpp(acc_lpp, sigma = 200)  # sigma = bandwidth in meters

plot(dens)
plot(lnet, add = TRUE, col = "grey")


# 3. Match events to nearest network nodes
unique_accidents_sf$node_id <- st_nearest_feature(unique_accidents_sf, roads_net)

node_indices <- unique_accidents_sf$node_id


dists_matrix <- dodgr_dists(roads_net, from = node_indices, to = node_indices)




nodes <- st_as_sf(roads_net, "nodes")

event_nodes <- nodes[unique_accidents_sf$node_id, ]

# 4. Calculate network distance matrix
# Get node IDs for the events
node_ids <- event_nodes$name

# Use dodgr to get a network distance matrix
dists_matrix <- dodgr_dists(roads_net, 
                            from = node_ids, 
                            to = node_ids, 
                            shortest = TRUE)

# 5. Perform DBSCAN
# 'eps' is the max network distance (in meters)
# 'minPts' is the minimum number of points for a cluster
db <- dbscan::dbscan(dists_matrix, eps = 500, minPts = 5)

# Add cluster ID to event data
events$cluster <- as.factor(db$cluster)
event_nodes$cluster <- as.factor(db$cluster)

# 6. Visualize the clusters
# Create a basemap with the road network
tm_basemap("OpenStreetMap") +
  tm_shape(roads_sf) +
  tm_lines(col = "grey", lwd = 1) +
  # Plot event points, coloring by cluster ID
  tm_shape(events) +
  tm_dots(
    col = "cluster",
    palette = "Set1",
    size = 0.5,
    title = "Event Clusters",
    legend.show = TRUE
  ) +
  tm_layout(main.title = "Network-Constrained DBSCAN Clustering",
            legend.outside = TRUE)
