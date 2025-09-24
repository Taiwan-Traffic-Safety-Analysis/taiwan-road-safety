# This script calls other scripts that fetches and cleans
# the data

# load packages
source("R/config/packages.R")

# by default it tries to used cached data
# to change this to FALSE
USE_CACHED_DATA <- TRUE

# Only change this if you want to save the data somewhere else
# (not recommended)
ACCIDENT_DATA_FOLDER <- "data/taipei_accidents"
WEATHER_DATA_FOLDER <- "data/weather"

ACCIDENT_SCRIPTS_FOLDER <- "R/get_data/taipei_A2_accidents"
WEATHER_SCRIPTS_FOLDER <- "R/get_data/weather"

load_data <- function(DATA_FOLDER,
                      SCRIPTS_FOLDER,
                      USE_CACHED_DATA){

# Load Taipei Data
if(USE_CACHED_DATA){
  
  
  # create a folder if it doesn't exist
  if(!dir.exists(DATA_FOLDER)){
    dir.create(DATA_FOLDER, recursive = TRUE)
  }
  
  
  # check to see if files are already in folder
  if(length(list.files(DATA_FOLDER)) > 0){
    
    print("Using Cached data!")
    
    for(f in list.files(DATA_FOLDER,
                        full.names = TRUE)){
      
      # define a regex expresion
      # to get the file name 
      # without folders or extensions
      regex_exp <- paste0("(?<=",
                          DATA_FOLDER,
                          "/).*?(?=\\.)")
      
      # extract the file name 
      # for later use renaming the file
      obj_name  <- f |> str_extract(regex_exp)
      
      
      file_ext <- f |> str_extract("(?<=\\.).*")
      
      if(file_ext == "csv"){
        
        obj <- fread(f)
        
      } else if(file_ext == "geojson"){
        
        obj <- st_read(f)
      }
      
      # dynamically assign a new name based on
      # the original file name
      assign(obj_name, obj, envir = .GlobalEnv)
      
    }
  } else {
    
    # call all the scripts to load data
    for(f in list.files(SCRIPTS_FOLDER,
                        full.names = TRUE)){
      
      source(f)
    }
 
  }

  
} else{
  
  # Here we overwrite even if the data already exists
  # lol
  
  # call all the scripts to load data
  for(f in list.files(SCRIPTS_FOLDER,
                      full.names = TRUE)){
    
    source(f)
    
  }
  
}

}

# Load accidents data
load_data(DATA_FOLDER = ACCIDENT_DATA_FOLDER,
          SCRIPTS_FOLDER = ACCIDENT_SCRIPTS_FOLDER,
          USE_CACHED_DATA = USE_CACHED_DATA)

# Load weather data
load_data(DATA_FOLDER = WEATHER_DATA_FOLDER,
          SCRIPTS_FOLDER = WEATHER_SCRIPTS_FOLDER,
          USE_CACHED_DATA = USE_CACHED_DATA)

rm(list = c("ACCIDENT_DATA_FOLDER",
            "ACCIDENT_SCRIPTS_FOLDER",
            "USE_CACHED_DATA",
            "WEATHER_DATA_FOLDER",
            "WEATHER_SCRIPTS_FOLDER",
            "load_data", 
            "load_shapefiles",
            "read_Big5_csv"))
  