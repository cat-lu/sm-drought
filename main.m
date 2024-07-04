%% Main code block for Africa
clear; clc;

% Directory of daily SMAP files
dir = '/Users/cathe/Dropbox (MIT)/college/senior year/UROP/SMAP/L3_SM_P_E/Daily/';
% Manual input for start and end dates of SMAP data
startDate = [2015,04,01];
endDate = [2023,12,02];

%% Extract shapefile of Africa from shapefile of all continents
worldFile = 'input\World_Continents\World_Continents.shp';
world = shaperead(worldFile,'UseGeoCoords',true);
row = find(strcmp({world.CONTINENT},'Africa')==1); %Find row exclusive to Africa
shapeAfrica = world(row);
geoAfrica = checkCoordinateReferenceSystem(worldFile,shapeAfrica); %Return geocrs if not already

%% Cut and combine daily soil moisture files using Africa shapefile
[SM_Africa,coordsAfrica,missingDates] = cutAndCombineDailySM(dir,startDate,endDate,geoAfrica);
% Save Africa-specific daily soil moisture, SMAP coordinates, missing dates
save('output/SM_Africa_shapefile.mat','SM_Africa','coordsAfrica','missingDates', '-v7.3')

%% Average Soil Moisture to 8-day Time Blocks
dt = 8; minObservedDates = 2; % Requires at least 2 days of non-missing data for averaging
[avgSM_Africa,missingDatePeriods] = averageSoilMoisture(SM_Africa,dt,minObservedDates);
% Save average soil moisture variable in output folder
save('output/avgSM_Africa_8day.mat', 'avgSM_Africa','missingDatePeriods', '-v7.3')

%% Extract Africa-specific porosity data
load('input/porosity_9km.mat'); % Loads porosity array (given from SMAP)
% Loads SMAP coordinates (coordinates that satellite covers)
load('input/SMAPCenterCoordinates9KM.mat','SMAPCenterLatitudes','SMAPCenterLongitudes') 
porosityAfrica = cut2D(porosity,SMAPCenterLatitudes,SMAPCenterLongitudes,geoAfrica);
save('output/porosityAfrica.mat','porosityAfrica')

%% Calculate drought thresholds from surface soil moisture
% Determine wanted percentiles (50th and D0-D4 percentiles)
% D0 to D4 Percentile-Based Thresholds in Volumetric Units
        % D0 Abnormally dry     21% - 30%  
        % D1 Moderate drought   11% - 20%  
        % D2 Severe drought      6% - 10%  
        % D3 Extreme drought     3% -  5% 
        % D4 Exceptional drought 2%    
pct = [0.50, 0.30, 0.21, 0.11, 0.06, 0.03]; % Upper percentiles
pctLabels = ["Median","D0","D1","D2","D3","D4"];
load('output/porosityAfrica.mat','porosityAfrica')
load('output/avgSM_Africa_8day.mat','avgSM_Africa')

D_AfricaSurface = calculateDThresholds(avgSM_Africa,porosityAfrica,pct,pctLabels);
save('output/DThresholdsAfrica_8daySurface.mat', 'D_AfricaSurface','-v7.3')

%% Create filtered data (root-zone soil moisture, 8-day periods) from averaged data
load('output/avgSM_Africa_8day.mat','avgSM_Africa')
% Filter time length = 60 days, previous 60 days affects current RZSM
RZSM_Africa = filterSurfaceToRZSM(avgSM_Africa,60);
save('output/RZSM_Africa.mat','RZSM_Africa','-v7.3')

%% Create filtered drought thresholds from RZSM
load('output/RZSM_Africa.mat','RZSM_Africa')
load('output/porosityAfrica.mat','porosityAfrica')
pct = [0.50, 0.30, 0.21, 0.11, 0.06, 0.03];
pctLabels = ["Median","D0","D1","D2","D3","D4"];

D_AfricaRoot = calculateDThresholds(RZSM_Africa,porosityAfrica,pct,pctLabels);
save('output/DThresholdsAfrica_8dayRoot.mat', 'D_AfricaRoot','-v7.3')

%% FIGURE: Plot SM/RZSM map using SMAP colorbar
load('output/avgSM_Africa_8day.mat','avgSM_Africa')
load('output/SM_Africa_shapefile.mat','coordsAfrica')
load coastlines

% Example soil moisture/RZSM map for period including July 1st, 2015
fig = figure;
mapSoilMoisture(fig,avgSM_Africa,datetime(2015,7,1),coordsAfrica.Lat,coordsAfrica.Lon,coastlat,coastlon)
title('Surface soil moisture')

load('output/RZSM_Africa.mat','RZSM_Africa')
fig2 = figure;
mapSoilMoisture(fig2,RZSM_Africa,datetime(2015,7,1),coordsAfrica.Lat,coordsAfrica.Lon)
title('Root-zone soil moisture')

%% FIGURE: Drought threshold difference maps (SM)
% Replace SM variables for RZSM variables to obtain filtered results
% (DAfrica_Surface -> DAfrica_Root)

DNames = ["D0","D1","D2","D3","D4"];
load('output/SM_Africa_shapefile.mat','coordsAfrica')
% load('output/DThresholdsAfrica_8daySurface.mat','D_AfricaSurface')
load('output/DThresholdsAfrica_8dayRoot.mat','D_AfricaRoot')
load coastlines

for imonth = 1:12
    for D = 1:length(DNames)-1
        fig = figure('Position',[500 200 600 500]);
        % mapDThresholdDifference(fig,D_AfricaSurface,imonth,coordsAfrica.Lat,coordsAfrica.Lon,coastlat,coastlon,DNames(D),DNames(D+1))
        mapDThresholdDifference(fig,D_AfricaRoot,imonth,coordsAfrica.Lat,coordsAfrica.Lon,coastlat,coastlon,DNames(D),DNames(D+1))
        titleString = [strcat(DNames(D),"-",DNames(D+1)," threshold: ",month(datetime(1,imonth,1),'name'))];
        title(titleString)
        saveas(gcf,strcat('output/Figures/AfricaResults/DroughtThresholdDifferences_filteredwTitle/',DNames(D),'-',DNames(D+1),'_Month',num2str(imonth)),'jpeg')
        saveas(gcf,strcat('output/Figures/AfricaResults/DroughtThresholdDifferences_filteredwTitle/fig/',DNames(D),'-',DNames(D+1),'_Month',num2str(imonth)),'fig')
    end % D
end % imonth

%% Find drought classifications (SM)
% Classify soil moisture under D0-D4 drought (surface)
load('output/avgSM_Africa_8day.mat','avgSM_Africa')
load('output/DThresholdsAfrica_8daySurface.mat','D_AfricaSurface')
SM_withDroughtLabels = classifyWithDroughtCategories(avgSM_Africa,D_AfricaSurface);
save('output/avgSM_withDroughtLabels_Africa_8day.mat','SM_withDroughtLabels','-v7.3')

%% FIGURE: Map drought classifications (SM)
load('output/avgSM_withDroughtLabels_Africa_8day.mat','SM_withDroughtLabels')
load('output/SM_Africa_shapefile.mat','coordsAfrica')
load coastlines
fig = figure;
% Plot drought labels map for example date period (e.g. index=200) 
mapDroughtLabels(fig,SM_withDroughtLabels(200).droughtLabels,coordsAfrica.Lat,coordsAfrica.Lon,coastlat,coastlon)

%% Find drought classifications (RZSM) for filtered data
% Classify soil moisture under D0-D4 drought (RZSM)
load('output/RZSM_Africa.mat','RZSM_Africa')
load('output/DThresholdsAfrica_8dayRoot.mat','D_AfricaRoot')
RZSM_withDroughtLabels = classifyWithDroughtCategories(RZSM_Africa,D_AfricaRoot);
save('output/RZSM_withDroughtLabels_Africa_8day.mat','RZSM_withDroughtLabels','-v7.3')

%% Aggregate periods using percentiles to categorize drought
% Average the percentiles that soil moisture from the 8-day periods are in
% for each month, then categorize using D0-D4 percentiles
load('output/DThresholdsAfrica_8daySurface.mat','D_AfricaSurface')
load('output/avgSM_Africa_8day.mat','avgSM_Africa')
load('output/porosityAfrica.mat','porosityAfrica')

pct = [0.30, 0.21, 0.11, 0.06, 0.03]; % Percentiles of D0-D4 drought
pctValues = [0 1 2 3 4]; % Values correspond to D0-D4 drought
% Dates of available SMAP data
startDate = datetime(2015,04,01);
endDate = datetime(2023,12,02);

aggPct_Africa = aggregateSMPercentilesToMonth(startDate,endDate,...
                D_AfricaSurface,avgSM_Africa,pct,pctValues,porosityAfrica);
save('output/aggregatedPercentiles_withDroughtLabels_Africa.mat','aggPct_Africa')

%% FIGURE: Aggregated monthly drought maps
% Plot drought labeled maps to emphasize most significant clusters of
% drought (i.e. clusters that are prevalent throughout a given month)

load('output/aggregatedPercentiles_withDroughtLabels_Africa.mat','aggPct_Africa')
load('output/SM_Africa_shapefile.mat','coordsAfrica')
load coastlines

for imonth = 1:length(aggPct_Africa)
    fig = figure('Position',[500 200 600 500]);
    mapDroughtLabels(fig,aggPct_Africa(imonth).droughtLabels,coordsAfrica.Lat,coordsAfrica.Lon,coastlat,coastlon)
    monthName = month(datetime(1,aggPct_Africa(imonth).Month,1),'name');
    titleString = strcat(monthName," ",num2str(aggPct_Africa(imonth).Year));
    title(titleString)
    saveas(gcf,strcat('output/Figures/AfricaResults/AggregatedMapsD0-D4/Year',...
        num2str(aggPct_Africa(imonth).Year),'_Month',num2str(aggPct_Africa(imonth).Month)),'jpeg')
    saveas(gcf,strcat('output/Figures/AfricaResults/AggregatedMapsD0-D4/fig/Year',...
        num2str(aggPct_Africa(imonth).Year),'_Month',num2str(aggPct_Africa(imonth).Month)),'fig')
end % imonth    

%% FIGURE: Individual period drought maps
% Plot individual drought labeled maps for each 8-day period prior to aggregation 
load('output/avgSM_withDroughtLabels_Africa_8day.mat','SM_withDroughtLabels')
load('output/SM_Africa_shapefile.mat','coordsAfrica')
load coastlines

for iperiod = 1:length(SM_withDroughtLabels)
    fig = figure('Position',[500 200 600 500]);
    mapDroughtLabels(fig,SM_withDroughtLabels(iperiod).droughtLabels,coordsAfrica.Lat,coordsAfrica.Lon,coastlat,coastlon)
    
    % Title of plot
    startStr = string(SM_withDroughtLabels(iperiod).startDate,'MMM dd, yyyy');
    endStr = string(SM_withDroughtLabels(iperiod).endDate,'MMM dd, yyyy');
    titleString = strcat(startStr," - ",endStr);
    title(titleString)

    % Save figure with center date as filename
    saveStr = string(SM_withDroughtLabels(iperiod).centerDate,'yyyy_MM_dd');
    saveas(gcf,strcat('output/Figures/AfricaResults/IndividualMapsD0-D4/',saveStr),'jpeg')
    saveas(gcf,strcat('output/Figures/AfricaResults/IndividualMapsD0-D4/fig/',saveStr),'fig')

end % imonth   