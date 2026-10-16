

if(!requireNamespace("here", quietly = TRUE)) {
  install.packages("here")
}
library(here)

source(here::here("utils", "functions.R"))

install_load_packages(c("sf",
                        "tigris",
                        "mapview",
                        "tidyverse",
                        "zip"))

dir_raw <- here::here("data", "raw")
dir_derived <- here::here("data", "derived")
dir_ensure(c(dir_raw,
             dir_derived))

epsg <- "EPSG:5070"

filenm <- "firedv2_west_2000_to_2025_events"

fired <- sf::st_read(here(dir_raw, "fired_conus_ak_2000_to_2025_events/fired_conus_ak_2000_to_2025_events.shp")) |>
  st_transform(epsg)

states <- tigris::states() |>
  st_transform(epsg)



#' Write Shapefile to a New Directory and Create a Zipped Version
#'
#' This function writes an `sf` object to a shapefile in a new, file-specific directory and optionally creates a zipped version of the shapefile.
#' It also allows for the removal of the original unzipped files and handles overwriting existing files.
#'
#' @param shp An `sf` object to write as a shapefile.
#' @param location A character string specifying the path of the directory to create the new file-specific subdirectory in.
#' @param filename A character string specifying the name of the file without the `.shp` extension.
#' @param zip_only A logical value indicating whether the original (unzipped) files should be removed after zipping. Defaults to `FALSE`.
#' @param overwrite A logical value indicating whether existing files should be overwritten. Defaults to `FALSE`.
#' @return No return value. The function writes a shapefile to a specified directory, optionally zips the files, and manages file cleanup based on user input.
#' @examples
#' \dontrun{
#' # Example usage
#' st_write_shp(shp = prepped_for_parks_etal,
#'              location = here::here("data/derived"),
#'              filename = "career_lba_for_parks_v1",
#'              zip_only = TRUE,
#'              overwrite = TRUE)
#' }
#' @importFrom sf st_write
#' @importFrom zip zip
#' @export
st_write_shp <- function(shp, location, filename, zip_only = FALSE, overwrite = FALSE) {
  
  # Define paths
  out_dir <- file.path(location, filename)
  zip_file <- file.path(out_dir, paste0(filename, ".zip"))
  zip_file_dest <- file.path(location, paste0(filename, ".zip"))
  
  # Manage overwriting and directory creation
  if (dir.exists(out_dir)) {
    if (overwrite) {
      unlink(out_dir, recursive = TRUE)
    } else {
      stop("Directory '", out_dir, "' already exists and overwrite is set to FALSE.")
    }
  }
  
  if (file.exists(zip_file_dest) && zip_only) {
    if (overwrite) {
      unlink(zip_file_dest)
    } else {
      stop("Zip file '", zip_file_dest, "' already exists and overwrite is set to FALSE.")
    }
  }
  
  # Create the directory if not there
  dir_ensure(out_dir)
  
  # Write the shapefile
  shapefile_path <- file.path(out_dir, paste0(filename, ".shp"))
  sf::st_write(shp, shapefile_path, append = FALSE)
  
  # Get all shapefile components
  all_shp_files <- list.files(out_dir, pattern = paste0(filename, ".*"), full.names = TRUE)
  
  # Create zip file
  zip::zip(zipfile = zip_file, files = all_shp_files, mode = "cherry-pick")
  
  # Remove raw files if zip_only is TRUE
  if (zip_only) {
    file.copy(zip_file, zip_file_dest)
    unlink(out_dir, recursive = TRUE)
  }
}


# Define the 10 western states (CONUS only)
western_states <- c(
  "Washington", "Oregon", "California", "Idaho", "Montana",
  "Nevada", "Utah", "Colorado", "Wyoming", "New Mexico", "Arizona"
)

# Filter TIGRIS states layer and transform to match EPA CRS
states_west <- states |>
  dplyr::filter(NAME %in% western_states)


# -------------------------------------------------------------------
# Filter Fired Polygons to Those Overlapping 
# -------------------------------------------------------------------

fired_west <- fired |>
  sf::st_filter(states_west, .predicate = sf::st_intersects)
mapview(fired_west)

# -------------------------------------------------------------------
# Export Filtered Fired Polygons as Zipped Shapefile
# -------------------------------------------------------------------

st_write_shp(
  shp = fired_west,
  location = dir_derived,
  filename = filenm,
  zip_only = TRUE,
  overwrite = TRUE
)

st_write(fired_west, here(dir_derived, paste0(filenm, ".gpkg")), append = FALSE)


