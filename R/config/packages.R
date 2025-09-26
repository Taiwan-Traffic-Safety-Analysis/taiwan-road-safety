# Use packman to install packages
# This is temporary until we move processes to renv or a cloud environment
if(!require("pacman")){
  install.packages("pacman")
}


pacman::p_load(archive,
               data.table,
               dplyr,
               httr,
               lubridate,
               janitor,
               jsonlite,
               rdflib,
               readODS,
               rvest,
               sf,
               stringr)