# ***some debug notes:
# depends on the Crop2ML model and user needs, specific R libraries might required, if error or warning appears, the user will need to use 
# "install.packages("the package name") to install required packages to R first.



# 1. Set up folders

# set up working folder as three folders
# /Crop2ML - all the function files generated from Crop2ML - units and composites
# /notebooks - store the wrappers or notebooks which runs the simulation by calling the composite by modelling steps
# /data - to store the weather and soil property files, if users store input weather data and soil property at other directories, they need to specify them in the 'load the data' chunk. 

################################################################################
# 2. Source functions
# set up the working directory by choosing the main script or the wrapper notebook, this is the directory one level up from the selected file, then locate the R folder which contains all the functions (units and compartment)
setwd(paste(dirname(dirname(file.choose())), ("/Crop2ML"), sep = ""))

# then load all the functions
lapply(list.files(getwd(), pattern = "\\.r$"), source)

# Currently they are three functions in the Crop2ML folder for Simplace Soil Temperature model, it is possible to just call the composite, which will then source the units by itself.
# However, considering there might be multiple model composites in the Crop2ML folder, the above command will load everything in the Crop2ML folder

################################################################################
# 3. Load weather input and soil property values
# move the working directory 
setwd(dirname(getwd()))

# for example
# weather
# weather <- read.table("/data/weather.txt", skip = 8, header = FALSE)

# soil properties 
# soilproperty <- read.table("/data/soil_property.txt", skip = 8, header = FALSE)


################################################################################
# 4. set the first values of exogenous of soilTemperature components

# The initial values, from the values of the first day in the weather data
iTempMax = weather$ # fill in the first value of the correct column from weather data
  iTempMin = weather$
  iRadiation = weather$
  iRAIN = weather$
  cFirstDayMeanTemp = mean(iTempMax,iTempMin)

# From soil property (in this example it is called soilproperty from the data/soil_property.txt):
cAverageGroundTemperature = soilproperty$ # fill in the correct values from soil property file
  cAverageBulkDensity = soilproperty$
  cCarbonContent = soilproperty$
  Albedo = soilproperty$
  cDampingDepth = soilproperty$
  cSoilLayerDepth = soilproperty$
  
# Other constents that is not in the input files
  iCropResidues = # fill in the values 
  iPotentialSoilEvaporation =  
  iLeafAreaIndex = 
  iSoilTempArray =
  cInitialAgeOfSnow = 
  cInitialSnowWaterContent =
  cSnowIsolationFactorA = 
  cSnowIsolationFactorB = 
  cAVT = 
  cABD = 
  iSoilWaterContent = 


################################################################################
# 5. generate init values using functions}
# call all initialization functions

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
for (id in 1:nrow(weather)) # or change the 'nrow(weather)' to the number of time step perfered
  # set exogenous
{
  # These come from weather data as vectors in the main compartment
  iAirTemperatureMax = weather$# the correct column with current row e.g. Tmax[id]
    iAirTemperatureMin = weather$
    iGlobalSolarRadiation = weather$
    iRAIN = weather$
    
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

