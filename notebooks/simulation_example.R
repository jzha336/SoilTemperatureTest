# ***some debug notes:
# depends on the Crop2ML model and user needs, specific R libraries might required, if error or warning appears, the user will need to use 
# "install.packages("the package name") to install required packages to R first.



# 1. Set up folders

# set up working folder as three folders
# /Crop2ML - all the function files generated from Crop2ML - units and composites
# /notebooks - store the wrappers or notebooks which runs the simulation by calling the composite by modelling steps
# /data - to store the weather and parameter files, if users store input weather data and parameters at other directories, they need to specify them in the 'load the data' chunk. 

################################################################################
# 2. Source functions
# set up the working directory by choosing the main script or the wrapper notebook, this is the directory one level up from the selected file, then locate the R folder which contains all the functions (units and compartment)
setwd(paste(dirname(dirname(file.choose())), ("/Crop2ML"), sep = ""))

# then load all the functions
lapply(list.files(getwd(), pattern = "\\.r$"), source)

# Currently they are three functions in the Crop2ML folder for Simplace Soil Temperature model, it is possible to just call the composite, which will then source the units by itself.
# However, considering there might be multiple model composites in the Crop2ML folder, the above command will load everything in the Crop2ML folder

# or alternatively, user can load the selected files 
# source("SoilTemperatureComponent.r")
# source("snowcovercalculator.r")
# source("stmpsimcalculator.r")

################################################################################
# 3. Load weather input and soil property values
# weather data
# move the working directory
setwd(dirname(getwd())) 

# weather
library(dplyr)
weather <- read.table("data/queenstown.txt", skip = 8, header = FALSE)
file_lines<- readLines("data/queenstown.txt")
column_names <- read.table(text = file_lines[7:8], header = FALSE, stringsAsFactors = FALSE) %>%
  { paste(.[1, ], .[2, ], sep = "") }
colnames(weather) <- column_names
weather <- weather[which(weather$`year()` == c(2000, 2001)),]

# soil property
parameter <- readLines("data/ParamTest.txt")[-1] 
parameters <- list()
for (line in parameter) {
  parts <- strsplit(line, ",\\s*", fixed = FALSE)[[1]]
  param_name <- parts[1]
  if (length(parts) > 2) {
    param_value <- as.numeric(parts[-1])  
  } else {
    param_value <- as.numeric(parts[2]) 
  }
  parameters[[param_name]] <- param_value
}


################################################################################
# 4. set parameters and first values of exogenous of soilTemperature components

# The initial values, from the values of the first day in the weather data
iTempMax = weather$`maxt(oC)`[1]
iTempMin = weather$`mint(oC)`[1]
iRadiation = weather$`radn(MJ/m^2)`[1]
iRAIN = weather$`rain(mm)`[1]   # first value
cFirstDayMeanTemp = mean(iTempMax,iTempMin)

# From parameter:
cAverageGroundTemperature = parameters$cAverageGroundTemperature
cAverageBulkDensity = parameters$cAverageBulkDensity
cCarbonContent = parameters$cCarbonContent
Albedo = parameters$cAlbedo
cDampingDepth = parameters$cDampingDepth
cSoilLayerDepth = parameters$cSoilLayerDepth

#Other constents that is not in the input files
iCropResidues = 30.0
iPotentialSoilEvaporation =  0.6
iLeafAreaIndex = 0.1
iSoilTempArray = c(2.6,5.4,8.6,12.2,11.4,10.6,9.8,9.0)
cInitialAgeOfSnow = 0
cInitialSnowWaterContent = 0.0
cSnowIsolationFactorA = 2.3
cSnowIsolationFactorB = 0.22
cAVT = 9.0
cABD = 1.4
iSoilWaterContent = 0.3

################################################################################
# 5. call all initialization functions

snow_init = init_snowcovercalculator(cCarbonContent,cInitialAgeOfSnow,cInitialSnowWaterContent,Albedo,cSnowIsolationFactorA,cSnowIsolationFactorB,iTempMax,iTempMin,iRadiation,iRAIN,iCropResidues,iPotentialSoilEvaporation,iLeafAreaIndex,iSoilTempArray)
stmp_init = init_stmpsimcalculator(cSoilLayerDepth,cFirstDayMeanTemp,cAVT,cABD,cDampingDepth,iSoilWaterContent,iSoilSurfaceTemperature)


################################################################################
# 6. perform sequential analysis}
# For loop
# link composite inputs with some model unit inputs
# set initialized variables
pInternalAlbedo = snow_init$pInternalAlbedo
SnowWaterContent = snow_init$SnowWaterContent
SoilSurfaceTemperature = snow_init$SoilSurfaceTemperature
AgeOfSnow = snow_init$AgeOfSnow

SoilTempArray = stmp_init$SoilTempArray
rSoilTempArrayRate = stmp_init$rSoilTempArrayRate
pSoilLayerDepth = stmp_init$pSoilLayerDepth
cAlbedo = Albedo

# call composite
for (id in 1:nrow(weather))
  # set exogenous
{
  # These come from weather data as vectors in the main compartment
  iAirTemperatureMax = weather$`maxt(oC)`[id]
  iAirTemperatureMin = weather$`mint(oC)`[id]
  iGlobalSolarRadiation = weather$`radn(MJ/m^2)`[id]
  iRAIN = weather$`rain(mm)`[id]
  
  simulation <- model_soiltemperature (cCarbonContent,
                                       cAlbedo,
                                       iAirTemperatureMax,
                                       iAirTemperatureMin,
                                       iGlobalSolarRadiation,
                                       iRAIN,
                                       iCropResidues,
                                       iPotentialSoilEvaporation,
                                       iLeafAreaIndex,
                                       SoilTempArray,
                                       cSoilLayerDepth,
                                       cFirstDayMeanTemp,
                                       cAverageGroundTemperature,
                                       cAverageBulkDensity,
                                       cDampingDepth,
                                       iSoilWaterContent,
                                       pInternalAlbedo,
                                       SnowWaterContent,
                                       SoilSurfaceTemperature,
                                       AgeOfSnow,
                                       rSoilTempArrayRate,
                                       pSoilLayerDepth)
  
  # set outputs
  AgeOfSnow=simulation$AgeOfSnow # do for all state variables
}


