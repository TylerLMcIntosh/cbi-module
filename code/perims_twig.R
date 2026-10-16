


if(!requireNamespace("here", quietly = TRUE)) {
  install.packages("here")
}
library(here)

source(here::here("utils", "functions.R"))

install_load_packages(c("sf",
                            "here",
                            "httr",
                            "glue",
                            "tidyverse"))

dir_raw <- here::here("data", "raw")
dir_derived <- here::here("data", "derived")
dir_ensure(c(dir_raw,
             dir_derived))

epsg <- "EPSG:5070"
planned_flnm <- "twig_planned_ignitions_completed_04012026"
unplanned_flnm <- "twig_unplanned_ignitions_04012026"



#Download datasets
twig_treatment_archive <- safe_download("https://sweri-treament-index.s3.us-west-2.amazonaws.com/treatment_index.zip",
                                        dest_dir = dir_raw,
                                        mode = "wb",
                                        timeout = 1000)

twig_schema_archive <- safe_download("https://sweri-treament-index.s3.us-west-2.amazonaws.com/database_scaffolding.zip",
                                     dest_dir = dir_raw,
                                     mode = "wb",
                                     timeout = 1000)

#Extract data archives
extracted_twig_treatment_path <- safe_extract(
  archive_path = twig_treatment_archive,
  extract_to = dir_raw,
  return_all_paths = FALSE)

extracted_twig_schema_path <- safe_extract(
  archive_path = twig_schema_archive,
  extract_to = dir_raw,
  return_all_paths = FALSE)

#Examine GDB contents
treatment_layers <- sf::st_layers(extracted_twig_treatment_path)
schema_layers <- sf::st_layers(extracted_twig_schema_path)
treatment_layers
schema_layers

twig_common_attributes <- sf::st_read(extracted_twig_schema_path,
                                      layer = "common_attributes_lookup")
twig_twig_categories <- sf::st_read(extracted_twig_schema_path,
                                    layer = "twig_category_lookup")
twig <- sf::st_read(extracted_twig_treatment_path,
                    layer = "treatment_index")




# States of interest
state_list <- c("WA", "OR", "CA", "ID", "MT", "WY", "NV", "AZ", "CO", "NM", "UT")

# ignitions that:
# - don't have duplicate error flags
# - are in the western US
# - have a date associated
# - and that date is prior to script runtime
# - and status is Completed rather than planned
twig_planned_ignitions_filtered <- twig |>
  dplyr::filter((is.na(error) | 
                    !grepl("DUPLICATE-DROP", error)) &
                    state %in% state_list &
                    (twig_category == "Planned Ignition") &
                    !is.na(treatment_date) &
                    status == "Completed") |>
  dplyr::mutate(burn_yr = lubridate::year(treatment_date)) |>
  dplyr::filter(treatment_date < as.Date(today())) |>
  sf::st_make_valid() |>
  sf::st_transform(epsg)


twig_unplanned_ignitions_filtered <- twig |>
  dplyr::filter(state %in% state_list &
                  twig_category == "Unplanned Ignition" & (is.na(error) | 
                                                             !grepl("DUPLICATE-DROP", error))) |>
  dplyr::mutate(burn_yr = lubridate::year(treatment_date)) |>
  dplyr::filter(treatment_date < as.Date(today())) |>
  sf::st_make_valid() |>
  sf::st_transform(epsg)


# Write out

planned_gpkg_flnm <- here::here(dir_derived, paste0(planned_flnm , ".gpkg"))
st_write(twig_planned_ignitions_filtered, planned_gpkg_flnm, append = FALSE)
st_write_shp(shp = twig_planned_ignitions_filtered,
             location = dir_derived,
             filename = planned_flnm,
             zip_only = TRUE,
             overwrite = TRUE)


unplanned_gpkg_flnm <- here::here(dir_derived, paste0(unplanned_flnm, ".gpkg"))
st_write(twig_unplanned_ignitions_filtered, unplanned_gpkg_flnm, append = FALSE)
st_write_shp(shp = twig_unplanned_ignitions_filtered,
             location = dir_derived,
             filename = unplanned_flnm,
             zip_only = TRUE,
             overwrite = TRUE)



