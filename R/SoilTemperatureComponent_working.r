#' Soil Temperature Model (Iterative Time Series Calculation)
#'
#' This function simulates soil temperature changes over time based on the initial values and iterates through 
#' each time step using the previous day's results as inputs for the next calculation.
#'
#' @param initial_conditions List, containing initial values for soil and snow properties.
#' @param weather Data frame, containing daily weather inputs such as max temperature, min temperature, radiation, etc.
#' @param parameters List, containing model parameters such as soil layer depth, average bulk density, etc.
#'
#' @return A list containing:
#' \item{SoilTempArray}{Matrix of soil temperatures for each layer over time.}
#' \item{SnowWaterContent}{Vector of snow water content over time.}
#' \item{SoilSurfaceTemperature}{Vector of soil surface temperature over time.}
#' \item{AgeOfSnow}{Vector of snow age over time.}
SoilSurfaceTemperature_old <-0

model_soiltemperature <- function(initial_conditions, weather, parameters) {
  
  # Initialize variables from initial conditions and model parameters
  cCarbonContent <- parameters$cCarbonContent
  cAlbedo <- parameters$cAlbedo
  cSoilLayerDepth <- parameters$cSoilLayerDepth
  cAverageGroundTemperature <- parameters$cAverageGroundTemperature
  cAverageBulkDensity <- parameters$cAverageBulkDensity
  cDampingDepth <- parameters$cDampingDepth
  
  pInternalAlbedo <- initial_conditions$pInternalAlbedo
  SnowWaterContent <- initial_conditions$SnowWaterContent
  SoilSurfaceTemperature <- initial_conditions$SoilSurfaceTemperature
  AgeOfSnow <- initial_conditions$AgeOfSnow
  SoilTempArray <- initial_conditions$SoilTempArray
  rSoilTempArrayRate <- initial_conditions$rSoilTempArrayRate
  
  # Create empty matrices/vectors to store results for each time step
  SoilTempArrayMatrix <- matrix(0, nrow = length(cSoilLayerDepth) + 6, ncol = nrow(weather))
  SnowWaterContentVector <- numeric(nrow(weather))
  SoilSurfaceTemperatureVector <- numeric(nrow(weather))
  AgeOfSnowVector <- numeric(nrow(weather))
  pSoilLayerDepth <- matrix(0, nrow = length(cSoilLayerDepth) + 6, ncol = nrow(weather))
  pInternalAlbedo <- numeric(nrow(weather))
  
  
  # Initial conditions for day 1
  SoilTempArrayMatrix[, 1] <- SoilTempArray
  SnowWaterContentVector[1] <- SnowWaterContent
  SoilSurfaceTemperatureVector[1] <- SoilSurfaceTemperature
  AgeOfSnowVector[1] <- AgeOfSnow
  pInternalAlbedo[1] <- initial_conditions$pInternalAlbedo
  pSoilLayerDepth[,1] <- initial_conditions$pSoilLayerDepth
  
  
  # Loop through each time step (e.g., each day) to calculate the next state based on the previous state
  for (day in 2:nrow(weather)) {
    # Extract weather data for the current day
    iTempMax <- weather$`maxt(oC)`[day]
    iTempMin <- weather$`mint(oC)`[day]
    iRadiation <- weather$`radn(MJ/m^2)`[day]
    iRAIN <- weather$`rain(mm)`[day]
    iCropResidues <- 0
    iPotentialSoilEvaporation <- 0.6
    iLeafAreaIndex <- 0
    
    # Step 2: Use previous day's results as input for the snow cover calculator
    list[SnowWaterContent,SoilSurfaceTemperature,AgeOfSnow, rSnowWaterContentRate, rSoilSurfaceTemperatureRate, rAgeOfSnowRate, SnowIsolationIndex]<-
      model_snowcovercalculator(
      iTempMax = iTempMax,
      iTempMin = iTempMin,
      iRadiation = iRadiation,
      iRAIN = iRAIN,
      iCropResidues = iCropResidues,
      iPotentialSoilEvaporation = iPotentialSoilEvaporation,
      iSoilTempArray = SoilTempArrayMatrix[, day - 1],
      SnowWaterContent = SnowWaterContentVector[day - 1],
      SoilSurfaceTemperature <- SoilSurfaceTemperatureVector[day - 1],# Use previous day's snow water content
      AgeOfSnow = AgeOfSnowVector[day - 1],
      pInternalAlbedo = pInternalAlbedo[day -1]) # Use previous day's soil temp array
    
    # Update soil surfacetemperature for the current day

    
    # Step 3: Use updated snow results to compute soil temperature for the current day
    list[SoilTempArray, rSoilTempArrayRate] <- model_stmpsimcalculator(
      cSoilLayerDepth = cSoilLayerDepth,
      cFirstDayMeanTemp = (iTempMax + iTempMin) / 2, # Use today's mean temp
      cAVT = cAverageGroundTemperature, # From parameters
      cABD = cAverageBulkDensity, # From parameters
      cDampingDepth = cDampingDepth, # From parameters
      iSoilWaterContent = SnowWaterContent,  # Placeholder, can be dynamic based on model requirements
      iSoilSurfaceTemperature = SoilSurfaceTemperature, # Use today's surface temp
      SoilTempArray = SoilTempArrayMatrix[, day - 1], # Use previous day's soil temp array
      rSoilTempArrayRate = rSoilTempArrayRate, # Use previous day's rate
      pSoilLayerDepth = pSoilLayerDepth[, day - 1]) # Use previous day's pSoilLayerDepth
    
    # Store the results for the current day
    SoilTempArrayMatrix[, day] <- SoilTempArray
    SnowWaterContentVector[day] <- SnowWaterContent
    SoilSurfaceTemperatureVector[day] <- SoilSurfaceTemperature
    AgeOfSnowVector[day] <- AgeOfSnow
  }
  
  # Return the results as a list
  return(list(
    "SoilTempArray" = SoilTempArrayMatrix,
    "SnowWaterContent" = SnowWaterContentVector,
    "SoilSurfaceTemperature" = SoilSurfaceTemperatureVector,
    "AgeOfSnow" = AgeOfSnowVector
  ))
}
