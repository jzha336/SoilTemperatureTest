#' Initialize Snow Cover Calculator
#'
#' This function initializes the snow cover properties such as snow water content, soil surface temperature,
#' and the age of snow based on carbon content, albedo, temperature, and other input factors.
#'
#' @param cCarbonContent Numeric, carbon content of the soil.
#' @param cInitialAgeOfSnow Numeric, initial age of the snow cover.
#' @param cInitialSnowWaterContent Numeric, initial snow water content.
#' @param Albedo Numeric, albedo parameter.
#' @param iTempMax Numeric, maximum daily temperature.
#' @param iTempMin Numeric, minimum daily temperature.
#' @param iRadiation Numeric, radiation levels.
#' @param iRAIN Numeric, rainfall values.
#' @param iCropResidues Numeric, crop residue levels.
#' @param iPotentialSoilEvaporation Numeric, potential soil evaporation rate.
#' @param iLeafAreaIndex Numeric, leaf area index.
#' @param iSoilTempArray Numeric vector, initial soil temperature array.
#' @return A list containing:
#' \item{pInternalAlbedo}{Numeric, internal albedo value.}
#' \item{SnowWaterContent}{Numeric, initialized snow water content.}
#' \item{SoilSurfaceTemperature}{Numeric, initialized soil surface temperature.}
#' \item{AgeOfSnow}{Numeric, initialized age of the snow.}
init_snowcovercalculator <- function(cCarbonContent,
                                     cInitialAgeOfSnow,
                                     cInitialSnowWaterContent,
                                     Albedo,
                                     iTempMax,
                                     iTempMin,
                                     iRadiation,
                                     iRAIN,
                                     iCropResidues,
                                     iPotentialSoilEvaporation,
                                     iLeafAreaIndex,
                                     iSoilTempArray) {
  
  # Initialize values
  SnowWaterContent <- 0.0
  SoilSurfaceTemperature <- 0.0
  AgeOfSnow <- 0
  pInternalAlbedo <- 0.0
  
  # Calculate internal albedo if not provided
  if (Albedo == as.double(0)) {
    pInternalAlbedo <- 0.0226 * log(cCarbonContent, 10) + 0.1502
  } else {
    pInternalAlbedo <- Albedo
  }
  
  # Calculate mean temperature and amplitude
  TMEAN <- 0.5 * (iTempMax + iTempMin)
  TAMPL <- 0.5 * (iTempMax - iTempMin)
  
  # Calculate daily soil surface temperature
  DST <- TMEAN + (TAMPL * (iRadiation * (1 - pInternalAlbedo) - 14) / 20)
  SoilSurfaceTemperature <- DST
  
  # Set initial snow properties
  AgeOfSnow <- cInitialAgeOfSnow
  SnowWaterContent <- cInitialSnowWaterContent
  
  return(list(
    "pInternalAlbedo" = pInternalAlbedo,
    "SnowWaterContent" = SnowWaterContent,
    "SoilSurfaceTemperature" = SoilSurfaceTemperature,
    "AgeOfSnow" = AgeOfSnow
  ))
}


#' Snow Cover Calculator Model
#'
#' This function simulates the snow cover changes over time based on factors such as temperature, radiation, rainfall,
#' crop residues, and potential soil evaporation.
#'
#' @param cCarbonContent Numeric, carbon content of the soil.
#' @param cInitialAgeOfSnow Numeric, initial age of the snow cover.
#' @param cInitialSnowWaterContent Numeric, initial snow water content.
#' @param Albedo Numeric, albedo parameter.
#' @param pInternalAlbedo Numeric, internal albedo value.
#' @param cSnowIsolationFactorA Numeric, static part of the snow isolation index calculation. Currently using 1.
#' @param cSnowIsolationFactorB Numeric, dynamic part of the snow isolation index calculation.Currently using 1.
#' @param iTempMax Numeric, maximum daily temperature.
#' @param iTempMin Numeric, minimum daily temperature.
#' @param iRadiation Numeric, daily radiation levels.
#' @param iRAIN Numeric, daily rainfall values.
#' @param iCropResidues Numeric, crop residue levels.
#' @param iPotentialSoilEvaporation Numeric, potential soil evaporation rate.
#' @param iLeafAreaIndex Numeric, leaf area index.
#' @param iSoilTempArray Numeric vector, soil temperature array for the day.
#' @param SnowWaterContent Numeric, current snow water content.
#' @param SoilSurfaceTemperature Numeric, current soil surface temperature.
#' @param AgeOfSnow Numeric, current age of snow.
#' @return A list containing:
#' \item{SnowWaterContent}{Numeric, updated snow water content.}
#' \item{SoilSurfaceTemperature}{Numeric, updated soil surface temperature.}
#' \item{AgeOfSnow}{Numeric, updated age of the snow.}
#' \item{rSnowWaterContentRate}{Numeric, rate of snow water content change.}
#' \item{rSoilSurfaceTemperatureRate}{Numeric, rate of soil surface temperature change.}
#' \item{rAgeOfSnowRate}{Numeric, rate of snow age change.}
#' \item{SnowIsolationIndex}{Numeric, snow isolation index.}

model_snowcovercalculator <- function(
                                      iTempMax,
                                      iTempMin,
                                      iRadiation,
                                      iRAIN,
                                      iCropResidues,
                                      iPotentialSoilEvaporation,
                                      iSoilTempArray,
                                      SnowWaterContent,
                                      SoilSurfaceTemperature,
                                      AgeOfSnow,
                                      pInternalAlbedo) {
  
  # Mean temperature and temperature amplitude
  TMEAN <- 0.5 * (iTempMax + iTempMin)
  TAMPL <- 0.5 * (iTempMax - iTempMin)
  DST <- TMEAN + (TAMPL * (iRadiation * (1 - pInternalAlbedo) - 14) / 20)
  
  # Check for rain and snow-related conditions
  if (is.na(iSoilTempArray[1])) {
    SnowWaterContent <- SnowWaterContent + iRAIN
  } else {
    if (any(iRAIN > 0 & (iSoilTempArray[1] < 1 | SnowWaterContent > 3 | SoilSurfaceTemperature < 0))) {
      SnowWaterContent <- SnowWaterContent + iRAIN
    }
  }
  

  
  
  # Snow isolation index calculation
  SnowIsolationIndex <- if (iCropResidues * 10.0 < 10) {
    iCropResidues * 10.0 / (iCropResidues * 10.0 + exp(5.34 - 2.4 * iCropResidues * 10.0))
  } else {
    1.0
  }
  
  # Calculate updated soil surface temperature
  if (SnowWaterContent < 1E-10) {
    SnowIsolationIndex <- SnowIsolationIndex * 0.85
    SoilSurfaceTemperature_old <- SoilSurfaceTemperature
    SoilSurfaceTemperature <- 0.5 * (DST + ((1 - SnowIsolationIndex) * DST) + (SnowIsolationIndex * iSoilTempArray[1]))
  } else {
    #SnowIsolationIndex <- max(SnowWaterContent / (SnowWaterContent + exp(cSnowIsolationFactorA - cSnowIsolationFactorB * SnowWaterContent)), SnowIsolationIndex)
    SnowIsolationIndex <- max(SnowWaterContent / (SnowWaterContent + exp(1 - 1 * SnowWaterContent)), SnowIsolationIndex)
    SoilSurfaceTemperature <- (1 - SnowIsolationIndex) * DST + (SnowIsolationIndex * iSoilTempArray[1])
  }
  
  # Update snow water content and age of snow
  SnowWaterContent_old<-SnowWaterContent
  SnowWaterContent <- SnowWaterContent_old - (iPotentialSoilEvaporation + 0)
  AgeOfSnow_old <-  AgeOfSnow
  AgeOfSnow <- if (SnowWaterContent < 5) 0 else AgeOfSnow_old + 1
  
  # Calculate rate changes
  rSnowWaterContentRate <- SnowWaterContent - SnowWaterContent_old
  rSoilSurfaceTemperatureRate <- SoilSurfaceTemperature - SoilSurfaceTemperature_old
  rAgeOfSnowRate <- AgeOfSnow - AgeOfSnow_old
  
  return(list(
    "SnowWaterContent" = SnowWaterContent,
    "SoilSurfaceTemperature" = SoilSurfaceTemperature,
    "AgeOfSnow" = AgeOfSnow,
    "rSnowWaterContentRate" = rSnowWaterContentRate,
    "rSoilSurfaceTemperatureRate" = rSoilSurfaceTemperatureRate,
    "rAgeOfSnowRate" = rAgeOfSnowRate,
    "SnowIsolationIndex" = SnowIsolationIndex
  ))
}


# Alternative function
snowcovercalculator2 <- function (cCarbonContent, cInitialAgeOfSnow, cInitialSnowWaterContent, Albedo, iTempMax, iTempMin) {
  SnowCoverArray <- numeric(length(iTempMax))
  
  # Compute snow cover based on temperature difference
  for (day in 1:length(iTempMax)) {
    temp_diff <- iTempMax[day] - iTempMin[day]    # Simulate snow cover based on temperature and albedo
    snow_melt_factor <- temp_diff * Albedo
    
    # Handle each day's snow water content separately
    if (!is.na(cInitialSnowWaterContent[day])) {
      SnowCoverArray[day] <- max(cInitialSnowWaterContent[day] - snow_melt_factor, 0) # Ensure no negative snow cover
    } else {
      SnowCoverArray[day] <- 0
    }
    
    # Update age of snow (for future improvements)
    cInitialAgeOfSnow <- cInitialAgeOfSnow + 1
  }
  
  return(SnowCoverArray)
}

