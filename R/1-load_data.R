# This script calls other scripts that fetches and cleans
# the data

# load packages
source("R/config/packages.R")

# by default it tries to used cached data
# to change this to FALSE
USE_CACHED_DATA <- TRUE


load_data <- function(data_folder,
                      scripts_folder,
                      use_cached_data){

# Load Taipei Data
if(use_cached_data){
  
  
  # create a folder if it doesn't exist
  if(!dir.exists(data_folder)){
    dir.create(data_folder, recursive = TRUE)
  }
  
  
  # check to see if files are already in folder
  if(length(list.files(data_folder)) > 0){
    
    print("Using Cached data!")
    
    for(f in list.files(data_folder,
                        full.names = TRUE)){
      
      # define a regex expresion
      # to get the file name 
      # without folders or extensions
      regex_exp <- paste0("(?<=",
                          data_folder,
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
    for(f in list.files(scripts_folder,
                        full.names = TRUE)){
      
      source(f)
    }
 
  }

  
} else{
  
  # Here we overwrite even if the data already exists
  # lol
  
  # call all the scripts to load data
  for(f in list.files(scripts_folder,
                      full.names = TRUE)){
    
    source(f)
    
  }
  
}

}



# Load accidents data
load_data(data_folder = "data/taipei_accidents",
          scripts_folder = "R/get_data/taipei_A2_accidents",
          use_cached_data = USE_CACHED_DATA)

# Load weather data
load_data(data_folder = "data/weather",
          scripts_folder = "R/get_data/weather",
          use_cached_data = USE_CACHED_DATA)

# Load population data
load_data(data_folder = "data/population",
          scripts_folder = "R/get_data/population",
          use_cached_data = USE_CACHED_DATA)

rm(list = c("USE_CACHED_DATA",

            "load_data", 
            "load_shapefiles",
            "read_Big5_csv"))
  