# This version of the code only uses the Welty & Jeffries polygons
# Tyler L. McIntosh 2025

rm(list = ls())

if(!requireNamespace("here", quietly = TRUE)) {
  install.packages("here")
}
library(here)

source(here::here("utils", "functions.R"))

install_load_packages(c("tigris",
                            "tictoc",
                            "httr",
                            "jsonlite",
                            "sf",
                            "zip",
                            "tidyverse"))

dir_derived <- here::here('data', 'derived')
dir_ensure(dir_derived)

flnm <- "welty_wildfire_west_1984_2020"

# Operate ----


epsg <- "EPSG:5070"

westernStates <- c("WA", "OR", "CA", "ID", "NV", "MT", "WY", "UT", "CO", "AZ", "NM")

west <- tigris::states() |>
  dplyr::filter(STUSPS %in% westernStates) |>
  sf::st_transform(epsg)

# The welty & jeffries combined fire polygon dataset can be acquired here: https://www.sciencebase.gov/catalog/item/61aa537dd34eb622f699df81
welty <- sf::st_read(here::here('data', 'raw', 'welty_combined_wildland_fire_dataset', 'welty_combined_wildland_fire_perimeters.shp')) |>
  sf::st_transform(epsg)

welty_wf <- welty |>
  dplyr::filter(Assigned_F == "Wildfire" | Assigned_F == "Likely Wildfire" | Assigned_F == "Unknown - Likely Wildfire")

  
welty_wildfire_1984_2020 <- welty_wf |> 
  dplyr::filter(Fire_Year >= 1984 & Fire_Year <= 2020) |>
  sf::st_filter(west)

# Write files

gpkg_flnm <- here::here(dir_derived, paste0(flnm, ".gpkg"))
st_write(welty_wildfire_1984_2020, gpkg_flnm)
st_write_shp(shp = welty_wildfire_1984_2020,
             location = dir_derived,
             filename = flnm,
             zip_only = TRUE,
             overwrite = TRUE)





