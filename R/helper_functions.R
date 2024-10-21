#' Read and clean data
#' 
#' Reads in the penguins data, renames and selects relevant columns. The
#' following transformations are applied to the data: 
#' * only keep species common name
#' * extract observation year
#' * remove rows with missing values
#' 
#' @param file Character, path to the penguins data .csv file.
#' @returns A tibble.
read_data <- function(file) {
  readr::read_csv(file, show_col_types = FALSE) |> 
    # for Excel files use: readxl::read_excel(file, sheet = "SheetName")
    janitor::clean_names() |> 
    # Checks on columns name and type
    assertr::verify(
      assertr::has_all_names(
        "species", "island", "date_egg", "sex", "body_mass_g", 
        "culmen_length_mm", "culmen_depth_mm", "flipper_length_mm"
      )
    ) |> 
    assertr::assert(rlang::is_integerish, body_mass_g) |> 
    # Tidying columns content
    dplyr::mutate(
      species = stringr::word(species, 1),
      year = lubridate::year(date_egg),
      sex = stringr::str_to_lower(sex),
      year = as.integer(year),
      body_mass_g = as.integer(body_mass_g),
      dplyr::across(dplyr::where(is.character), as.factor)
    ) |> 
    # Selecting relevant columns
    dplyr::select(
      species,
      island,
      year,
      sex,
      body_mass_g,
      bill_length_mm = culmen_length_mm,
      bill_depth_mm = culmen_depth_mm,
      flipper_length_mm
    ) |> 
    # Removing rows with NA in any column
    tidyr::drop_na() |> 
    # More checks on columns content
    assertr::verify(flipper_length_mm > 0)
}

#' Bill vs flipper length scatterplot
#' 
#' Plots the flipper length (x-axis) against the bill length (y-axis) for 
#' each penguin species (colour).
#' 
#' @param df Tibble, penguins data.
#' @returns A ggplot.
plot_bill_flipper <- function(df) {
  df |> 
    ggplot2::ggplot(
      ggplot2::aes(x = flipper_length_mm, y = bill_length_mm, colour = species)
    ) +
    ggplot2::geom_point() +
    ggplot2::scale_colour_brewer(palette = "Set1") +
    ggplot2::labs(
      title = "Relationship betwen penguins' flipper and bill length",
      x = "Flipper length (mm)",
      y = "Bill length (mm)",
      colour = "Penguin species"
    ) +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      plot.title = ggplot2::element_text(hjust = 0.5),
      legend.position = "bottom"
    )
}

#' Fit bill length model
#'
#' Fits a linear model for bill length from species and flipper length, with an
#' interaction term. Flipper length is centred to zero before fitting the model.
#'
#' @param df Tibble, penguins data.
#' @returns A tibble of coefficients from the fitted model.
fit_model <- function(df) {
  df$flipper_length_mm <- scale(
    df$flipper_length_mm, 
    center = TRUE, 
    scale = FALSE
  )
  
  lm_fit <- lm(bill_length_mm ~ species*flipper_length_mm, data = df)
  
  # Return coefficients as a tibble
  broom::tidy(lm_fit)
}


#' Visualise PCA with a 3D Scatter Plot
#' 
#' Performs Principal Component Analysis (PCA) on selected numeric variables from a given dataset
#' of penguins and visualises the results in a 3D scatter plot. The points are colored based on the species.
#' 
#' @param df Tibble, penguins data.
#' @returns A plot_ly.
plot_PCA_3d <- function(df) {
  X <- df |>
    dplyr::select(flipper_length_mm, body_mass_g, bill_length_mm, bill_depth_mm)
  
  # Perform PCA
  prin_comp <- prcomp(X, rank. = 3, center = TRUE, scale. = TRUE)
  
  components <- data.frame(prin_comp$x) # Extract principal components

  components$species <- df$species # Add species back into the components dataframe
  
  # Calculate total explained variance
  tot_explained_variance_ratio <- summary(prin_comp)[["importance"]]['Proportion of Variance',]
  tot_explained_variance_ratio <- 100 * sum(tot_explained_variance_ratio)
  tit <- paste('Total Explained Variance =', round(tot_explained_variance_ratio, 2), '%')
  
  fig <- plotly::plot_ly(components, 
                 x = ~PC1, y = ~PC2, z = ~PC3, 
                 color = ~species, 
                 colors = c('#ebb233','#78c3ed','#33b18f')) |>
    plotly::add_markers(size = 12)
  
  fig <- fig |>
    plotly::layout(
      title = tit,
      scene = list(bgcolor = "#e5ecf6")
    )
  fig
}
