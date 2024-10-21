library(here)

## Reading in helper functions
source(here("R/helper_functions.R"))

data_file <- "/input/projects/rds-starter/palmerpenguins_raw.csv"
# If not working on powerplant, can use the following path instead:
# data_file <- "https://storage.powerplant.pfr.co.nz/input/projects/rds-starter/palmerpenguins_raw.csv"

penguins_df <- read_data(data_file)

# Plotting bill and flipper length
p1 <- plot_bill_flipper(penguins_df)
p1

# Saving figure with high resolution for presentation
ggplot2::ggsave(
  here("output/plot_bill_vs_flipper_length.png"), 
  plot = p1,
  dpi = 300,
  bg = "white"
)

model_coeff <- fit_model(penguins_df) # fitting linear model for bill length

## Saving results to output folder (will only work if working on powerplant)
readr::write_csv(model_coeff, file = "/output/projects/rds-starter/fitted_model.csv")


## Visualise PCA with scatter3d
plot_PCA_3d(penguins_df)