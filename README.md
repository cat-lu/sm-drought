# About
This repository contains MATLAB scripts for a drought monitoring methodology, producing drought maps and time series for Africa. Historical soil moisture data from remote sensing is used to calculate month- and location-specific drought thresholds based on the U.S. Drought Monitor (USDM) drought categories (D0-D4). These drought thresholds then determine drought intensity, or lack thereof, at a given area and time. 

# Dataset
The following scripts uses satellite surface soil moisture data (top 5 cm of soil column) from NASA's Soil Moisture Active Passive (SMAP) mission. The dataset used has temporal coverage from April 15th, 2015 to December 2nd, 2023 provided at an interpolated resolution of 9 km. The resulting figures are summarized in a thesis report, "Soil moisture-based drought monitoring using remote sensing over Africa". 

# Scripts
The provided code is split into four categories: main scripts (one for each shapefile: Africa, regions of Africa, and Angola), primary functions, figure-producing scripts and functions, and helper functions. The following image shows an overview of the drought estimation methodology. ![flowchart](https://github.com/cat-lu/sm-drought/blob/main/method_flowchart.png?raw=true)

### Main scripts:
`main.m`: Drought monitoring methodology for Africa, producing month- and location-specific drought thresholds and subsequent time series and drought maps.

`main_regional.m`: Drought monitoring methodology for six climate reference regions in Africa (Mediterranean, Sahara, Western Africa, Central Africa, Eastern Africa, and Southern Africa), producing month- and location-specific drought thresholds and subsequent time series and drought maps.

`main_angola.m`: Drought monitoring methodology for Angola, producing month- and location-specific drought thresholds and subsequent time series and drought maps.


### Primary functions:
`cutAndCombineDailySM.m`: Reduces SMAP file to a given area and combines daily individual SMAP files into single structure array of surface soil moisture values.

`averageSoilMoisture.m`: Averages soil moisture data over a given time period.

`filterSurfacetoRZSM.m`: Converts raw surface soil moisture data into root-zone soil moisture data using an exponential time filter. This function also takes the number of days for water to travel from the surface (top ~5cm of soil) to the root-zone level(~200 cm) as an input. 

`calculateDThresholds.m`: Calculates drought thresholds based on soil moisture data and inputted drought percentiles. Drought threshold values are specific to a month and coordinate and are calculated by fitting a beta distribution to historical soil moisture data. The USDM percentiles (table shown below) provide example upper drought percentiles to be used in this case.

| Category     | Description           | Percentile Range |
|--------------|-----------------------|------------------|
| No Drought   | Normal/wet conditions | Greater than 30  |
| D0           | Abnormally dry        | 21 to 30         |
| D1           | Moderate drought      | 11 to 20         |
| D2           | Severe drought        | 6 to 10          |
| D3           | Extreme drought       | 3 to 5           |
| D4           | Exceptional drought   | 0 to 2           |

`classifyWithDroughtCategories.m`: Labels soil moisture data for each coordinate and each date period as No Drought, D0, D1, D2, D3, or D4 drought based on previously calculated drought thresholds. 

`aggregateSMPercentilesToMonth.m`: Averages soil moisture percentiles on a monthly basis and calculates subsequent drought labels. 

`calculateTimeSeries.m`: Calculates the percent area that a region is under D0-D4 drought conditions at each time step.

### Figure-producing scripts and functions:
`betaParameterizationPlot.m`: Visualizes the methodology of beta distribution fitting for historical soil moisture values at a reference location. 

`mapSoilMoisture.m`: Produces map of volumetric soil moisture values for a given area and time period. 

`mapDThresholdDifference.m`: Visualizes and maps the differences between drought threshold values (e.g. D1-D2) in terms of volumetric soil moisture.

`mapDroughtLabels.m`: Produces map of drought labels (i.e. D0-D4, no drought) for a given area and time period. 

`drawTimeSeriesPlot.m`: Visualizes time series of percent area that a region is in D0-D4 drought. 

### Helper functions:
`cut2D.m`: Reduces a 2D array (i.e. Nlat x Nlon) to coordinates that fall within a given shapefile or bounding box. 

`cut3D.m`: Reduces a 3D array (i.e. Nlat x Nlon x Ndates) on the third dimension to coordinates that fall within a given shapefile or bounding box. 

`cutStruct3D.m`: Reduces each value in a structure array, which is a 2D array, to coordinates that fall within a given shapefile or bounding box. 

`transformMatrix3DToStruct.m`: Converts a 3D array (i.e. Nlat x Nlon x Ndates) into a specified field in a structure array. Each index in the structure array is a 2D array (i.e. Nlat x Nlon). 

`transformStructTo3DMatrix.m`: Combines values from a specified field in a structure array and converts them to a 3D array (i.e. Nlat x Nlon x Ndates). 

`checkCoordinateReferenceSystem.m`: Changes projection of input shapefile to match another existing shapefile. 

`classifyDroughtFromPercentiles.m`: Helper function to `aggregateSMPercentilesToMonth.m`. Labels soil moisture percentiles for each coordinate and each month with a drought category. 

# References
The shapefiles for Africa, climate regions of Africa, and Angola are taken from the following sources:
- Africa: [Esri World Continents layer](http://www.arcgis.com/home/item.html?id=57c1ade4fa7c4e2384e6a23f2b3bd254)
- Regions of Africa: Combination of regions from [Iturbide et al., 2020](https://essd.copernicus.org/articles/12/2959/2020/) and [IPCC AR5-WGI](https://www.ipcc-data.org/guidelines/pages/ar5_regions.html)
- Angola & Angola Provinces: [UNDP - CNIDAH](https://geodata.libraries.mit.edu/record/gismit:AO_F7PROVINCES_2005)
