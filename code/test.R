library(terra)
library(here)

# full raster *metadata only* (no heavy read yet)
r <- rast(here("data/derived/WUMI2024a/WUMI2024a_1992.tif"))

# Colorado extent (must be in same CRS as raster)
co <- states(cb = TRUE, year = 2020) |>
  subset(STUSPS == "CO") |>
  vect() |>
  project(crs(r))

# get bounding box
co_ext <- ext(co)

# read ONLY that window + only the band
t_co <- rast(
  here("data/derived/WUMI2024a/WUMI2024a_1992.tif"),
  lyrs = "CBI_bc",
  ext = co_ext
) |>
  mask(co)