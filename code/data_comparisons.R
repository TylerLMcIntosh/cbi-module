

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
                        "tidyverse",
                        "arrow",
                        "trend"))

dir_derived <- here::here('data', 'derived')

# perimeter comparisons

fired <- sf::st_read(here(dir_derived, "firedv2_west.gpkg"))
welty <- sf::st_read(here(dir_derived, "welty_wildfire_west_1984_2020.gpkg"))
wumi_c <- sf::st_read(here(dir_derived, "WUMI2024a_main_fires_unified_with_circles.gpkg"))
wumi_nc <- sf::st_read(here(dir_derived, "WUMI2024a_main_fires_unified_no_circles.gpkg"))

# assess circle impact on WUMI
n_circ <- nrow(wumi_c) - nrow(wumi_nc)
perc_area <- (sum(wumi_c |> filter(perimeter_type == "CIRCLE") |> pull(poly_area_ha)) / sum(wumi_c$poly_area_ha)) * 100
perc_n <- nrow(wumi_c |> filter(perimeter_type == "CIRCLE")) / nrow(wumi_c) * 100

wumi_c_sum <- wumi_c |>
  st_drop_geometry() |>
  group_by(fire_year) |>
  summarize(n = n(), ha = sum(poly_area_ha)) |>
  mutate(dataset = "wumi_c")

wumi_nc_sum <- wumi_nc |>
  st_drop_geometry() |>
  group_by(fire_year) |>
  summarize(n = n(), ha = sum(poly_area_ha)) |>
  mutate(dataset = "wumi_nc")

fired_sum <- fired |>
  st_drop_geometry() |>
  group_by(ig_year) |>
  summarize(n = n(), ha = sum(tot_ar_ac) * 0.404686) |>
  mutate(dataset = "fired") |>
  rename(fire_year = ig_year)

welty_sum <- welty |>
  st_drop_geometry() |>
  group_by(Fire_Year) |>
  summarize(n = n(), ha = sum(GIS_Hectar)) |>
  mutate(dataset = "welty") |>
  rename(fire_year = Fire_Year)

comparison <-
  rbind(wumi_c_sum, wumi_nc_sum, fired_sum, welty_sum)

ggplot(comparison) +
  geom_col(aes(x = fire_year, y = n, fill = dataset), position = "dodge")


ggplot(comparison) +
  geom_col(aes(x = fire_year, y = ha, fill = dataset), position = "dodge")


# bccbi comparison figure & change over time
# tic()
# r <- terra::rast(here(dir_derived, 
#                       "bccbi_firedv2_west_2002.tif"))
# 
# 
# out_dir <- here(dir_derived, "test_vals_parquet")
# dir.create(out_dir, showWarnings = FALSE)
# 
# bs <- terra::blocks(r)
# 
# for (i in seq_len(bs$n)) {
#   v <- terra::values(r, row = bs$row[i], nrows = bs$nrows[i], mat = FALSE)
#   v <- v[!is.na(v)]
#   if (!length(v)) next
#   
#   tab <- arrow_table(value = v)
#   write_parquet(tab, file.path(out_dir, sprintf("part-%05d.parquet", i)))
# }
# 
# # Later: treat as one big "table" without loading it all
# ds <- open_dataset(out_dir, format = "parquet")
# ds
# toc() #221.78 sec elapsed
# 
# tic()
# f <- terra::freq(r)
# toc()


hist_compare <- read_csv(here(dir_derived, "CBI_bc_histograms_2001_2020.csv"))


hist_prop <- hist_compare |>
  mutate(is_high = bin_start >= 2.25) |>
  group_by(dataset, year) |>
  summarize(
    n_high = sum(n[is_high], na.rm = TRUE),
    n_total = sum(n, na.rm = TRUE),
    prop_high = n_high / n_total,
    .groups = "drop"
  )

range(hist_prop$prop_high)


sen_fits <- hist_prop |>
  group_by(dataset) |>
  summarize(
    sen = list(sens.slope(prop_high, year)),
    slope = sen[[1]]$estimates,
    p_value = sen[[1]]$p.value,
    .groups = "drop"
  )

trend_lines <- hist_prop |>
  inner_join(sen_fits, by = "dataset") |>
  group_by(dataset) |>
  mutate(
    fitted = slope * year +
      (mean(prop_high) - slope * mean(year))
  ) |>
  ungroup()

label_df <- sen_fits |>
  mutate(
    label = sprintf("slope = %.3g\np = %.3g", slope, p_value)
  )


ggplot(hist_prop, aes(x = year, y = prop_high, fill = dataset)) +
  geom_col(position = "dodge", width = 0.8, alpha = 0.8) +
  geom_line(
    data = trend_lines,
    aes(y = fitted, color = dataset, group = dataset),
    linewidth = 1.2
  ) +
  geom_text(
    data = label_df,
    aes(
      x = min(hist_prop$year) + 1,
      y = max(hist_prop$prop_high),
      label = label,
      color = dataset
    ),
    hjust = 0,
    vjust = 1,
    show.legend = FALSE
  ) +
  scale_y_continuous(
    labels = scales::percent_format(accuracy = 1)
  ) +
  labs(
    x = "Fire year",
    y = "Proportion of pixels with CBI ≥ 2.25",
    fill = "Dataset",
    color = "Dataset",
    title = "High-severity proportion (CBI ≥ 2.25) by year",
    subtitle = "Bars = yearly proportions; lines = Theil–Sen trends"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    panel.grid.minor = element_blank()
  )



# density_curves

sum_by_dataset <- hist_compare |>
  group_by(dataset, bin_start) |>
  summarize(
    n = sum(n, na.rm = TRUE),
    .groups = "drop"
  )

sum_by_dataset





# bccbi vs others for a single dataset (W&J? WUMI?)



