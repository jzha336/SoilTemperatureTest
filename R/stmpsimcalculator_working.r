#' Initialize Soil Temperature Simulation
#'
#' This function initializes the soil temperature for multiple layers based on the depth of the layers,
#' mean temperature, bulk density, and damping depth. It calculates the temperature profile for each soil layer.
#'
#' @param cSoilLayerDepth Numeric vector, depths of soil layers.
#' @param cFirstDayMeanTemp Numeric, mean temperature of the first day, calculated as the average between max and min temperatures.
#' @param cAVT Numeric, average ground temperature at deeper layers.
#' @param cABD Numeric, bulk density of the soil.
#' @param cDampingDepth Numeric, damping depth of the soil.
#' @param iSoilWaterContent Numeric, soil water content, typically derived from weather data or soil profile.
#' @param iSoilSurfaceTemperature Numeric vector, initial soil surface temperature for each layer.
#' @return A list containing:
#' \item{SoilTempArray}{Numeric vector, initial temperature profile for each soil layer.}
#' \item{rSoilTempArrayRate}{Numeric vector, rate of temperature change for each layer.}
#' \item{pSoilLayerDepth}{Numeric vector, depth profile for each soil layer.}
init_stmpsimcalculator <- function(cSoilLayerDepth, cFirstDayMeanTemp, cAVT, cABD, cDampingDepth, iSoilWaterContent, iSoilSurfaceTemperature) {
  SoilTempArray <- vector()
  rSoilTempArrayRate <- vector()
  pSoilLayerDepth <- vector()
  tStmp <- vector()
  tStmpRate <- vector()
  tz <- vector()
  
  # Profile depth and additional layer depth
  tProfileDepth <- cSoilLayerDepth[length(cSoilLayerDepth)]
  additionalDepth <- cDampingDepth - tProfileDepth
  firstAdditionalLayerHeight <- additionalDepth - as.double(floor(additionalDepth))
  layers <- as.integer(ceiling(additionalDepth)) + length(cSoilLayerDepth)
  
  tStmp <- vector(, layers)
  tStmpRate <- vector(, layers)
  tz <- vector(, layers)
  
  # Calculate soil temperatures for each layer
  for (i in seq(0, length(tStmp) - 1, 1)) {
    if (i < length(cSoilLayerDepth)) {
      depth <- cSoilLayerDepth[i + 1]
    } else {
      depth <- tProfileDepth + firstAdditionalLayerHeight + i - length(cSoilLayerDepth)
    }
    tz[i + 1] <- depth
    tStmp[i + 1] <- (cFirstDayMeanTemp * (cDampingDepth - depth) + (cAVT * depth)) / cDampingDepth
  }
  
  rSoilTempArrayRate <- tStmpRate
  SoilTempArray <- tStmp
  pSoilLayerDepth <- tz
  
  return(list("SoilTempArray" = SoilTempArray, "rSoilTempArrayRate" = rSoilTempArrayRate, "pSoilLayerDepth" = pSoilLayerDepth))
}




#' Simulate Soil Temperature Changes
#'
#' This function simulates soil temperature changes over time for each soil layer using the damping depth,
#' bulk density, and soil water content.
#'
#' @param cSoilLayerDepth Numeric vector, depths of soil layers.
#' @param cFirstDayMeanTemp Numeric, mean temperature of the first day.
#' @param cAVT Numeric, average temperature of the deepest soil layer.
#' @param cABD Numeric, bulk density of the soil.
#' @param cDampingDepth Numeric, damping depth of the soil.
#' @param iSoilWaterContent Numeric, water content in the soil profile.
#' @param iSoilSurfaceTemperature Numeric vector, temperature at the soil surface for each layer.
#' @param SoilTempArray Numeric vector, initial temperatures for each soil layer.
#' @param rSoilTempArrayRate Numeric vector, rate of temperature change for each layer.
#' @param pSoilLayerDepth Numeric vector, depth profile for each soil layer.
#' @return A list containing:
#' \item{SoilTempArray}{Updated temperatures for each soil layer.}
#' \item{rSoilTempArrayRate}{Updated rate of temperature change for each layer.}

model_stmpsimcalculator <- function(
    cSoilLayerDepth, 
    cFirstDayMeanTemp, 
    cAVT, 
    cABD, 
    cDampingDepth, 
    iSoilWaterContent, 
    iSoilSurfaceTemperature, 
    SoilTempArray, 
    rSoilTempArrayRate, 
    pSoilLayerDepth) {
  XLAG <- 0.8
  XLG1 <- 1 - XLAG
  DP <- 1 + (2.5 * cABD / (cABD + exp(6.53 - (5.63 * cABD))))
  WC <- 0.001 * iSoilWaterContent / ((0.356 - (0.144 * cABD)) * cSoilLayerDepth[length(cSoilLayerDepth)])
  DD <- exp(log(0.5 / DP) * ((1 - WC) / (1 + WC)) * 2) * DP
  Z1 <- as.double(0)
  
  # Calculate temperature changes for each layer
  for (i in seq(0, length(SoilTempArray) - 1, 1)) {
    ZD <- 0.5 * (Z1 + pSoilLayerDepth[i + 1]) / DD
    RATE <- ZD / (ZD + exp(-0.8669 - (2.0775 * ZD))) * (cAVT - iSoilSurfaceTemperature)
    RATE <- XLG1 * (RATE + iSoilSurfaceTemperature - SoilTempArray[i + 1])
    Z1 <- pSoilLayerDepth[i + 1]
    rSoilTempArrayRate[i + 1] <- RATE
    SoilTempArray[i + 1] <- SoilTempArray[i + 1] + rSoilTempArrayRate[i + 1]
  }
  
  return(list("SoilTempArray" = SoilTempArray, "rSoilTempArrayRate" = rSoilTempArrayRate))
}


