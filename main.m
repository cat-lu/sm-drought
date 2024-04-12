%% Main code block for Africa
clear; clc;

% Directory of daily SMAP files
dir = '/Users/cathe/Dropbox (MIT)/college/senior year/UROP/SMAP/L3_SM_P_E/Daily/';
startDate = [2015,04,01];
endDate = [2023,12,02];
bbox = [-38,38; -21,53];
%% Use Africa bounding box
% [SM_Africa,lat,lon,dates] = cutAndCombineDailySM(dir,startDate,endDate,bbox);
% save('output/SM_Africa_bbox.mat', 'SM_Africa', '-v7.3')
%% Cut and combine daily soil moisture files using Africa shapefile
worldFile = 'input\World_Continents\World_Continents.shp';
world = shaperead(worldFile,'UseGeoCoords',true);
row = find(strcmp({world.CONTINENT},'Africa')==1); %Find row exclusive to Africa
shapeAfrica = world(row);
geoAfrica = checkCoordinateReferenceSystem(worldFile,shapeAfrica); %Return geocrs if not already
%%
[SM_Africa,coordsAfrica,missingDates] = cutAndCombineDailySM(dir,startDate,endDate,geoAfrica);
save('output/SM_Africa_shapefile.mat','SM_Africa','coordsAfrica','missingDates', '-v7.3')

%% Average Soil Moisture to 8-day Time Blocks
dt = 8; minObservedDates = 2;
[avgSM_Africa,missingDatePeriods] = averageSoilMoisture(SM_Africa,dt,minObservedDates);
save('output/avgSM_Africa_8day.mat', 'avgSM_Africa','missingDatePeriods', '-v7.3')

%% Cut down porosity data
load('input/porosity_9km.mat'); % Loads porosity array
load('input/SMAPCenterCoordinates9KM.mat','SMAPCenterLatitudes','SMAPCenterLongitudes') % Loads SMAP coordinates
porosityAfrica = cut2D(porosity,SMAPCenterLatitudes,SMAPCenterLongitudes,geoAfrica);
save('output/porosityAfrica.mat','porosityAfrica')
%%
% Determine wanted percentiles (50th and D0-D4 percentiles)
% D0 to D4 Percentile-Based Thresholds in Volumetric Units
        % D0 Abnormally dry     21% - 30%  
        % D1 Moderate drought   11% - 20%  
        % D2 Severe drought      6% - 10%  
        % D3 Extreme drought     3% -  5% 
        % D4 Exceptional drought 2%    
pct = [0.50, 0.30, 0.21, 0.11, 0.06, 0.03];
pctLabels = ["Median","D0","D1","D2","D3","D4"];

load('output/porosityAfrica.mat','porosityAfrica')
load('output/avgSM_Africa_8day.mat','avgSM_Africa')
D_AfricaSurface = calculateDThresholds(avgSM_Africa,porosityAfrica,pct,pctLabels);
save('output/DThresholdsAfrica_8daySurface.mat', 'D_AfricaSurface','-v7.3')

%% RZSM test case
SM_test = zeros(1,1,100);
SM_test(1,1,50) = .6;
timelength = 10;
dt = 2; 
datePeriod = datetime(2015,3,2):2:datetime(2015,9,17);
rzsm = filterSurfaceToRZSM(SM_test,timelength,dt,datePeriod);
y = squeeze(rzsm(1,1,:));
figure
bar(y); hold on
% bar(SM_test)
title('RZSM: (e^{-x})')


%% Create filtered data from averaged data
% load('output/DThresholdsAfrica_8daySurface.mat','centerDatePeriod')
load('output/avgSM_Africa_8day.mat','avgSM_Africa')
RZSM_Africa = filterSurfaceToRZSM(avgSM_Africa,60 );
save('output/RZSM_Africa.mat','RZSM_Africa','-v7.3')

%% Create filtered drought thresholds
%load('output/RZSM_Africa.mat','RZSM_Africa')
load('output/porosityAfrica.mat','porosityAfrica')
pct = [0.50, 0.30, 0.21, 0.11, 0.06, 0.03];
pctLabels = ["Median","D0","D1","D2","D3","D4"];

D_AfricaRoot = calculateDThresholds(avgSM_Africa,porosityAfrica,pct,pctLabels);
save('output/DThresholdsAfrica_8dayRoot.mat', 'D_AfricaRoot','-v7.3')

%% Time Series for Africa
Nperiod = length(RZSM_Africa);
[Nlat,Nlon] = size(RZSM_Africa(1).SM);
RZSM_matrix = NaN(Nlat,Nlon,Nperiod);
datesArray = NaT(Nperiod,1);
DArray = NaN(Nlat,Nlon,)
for iperiod = 1:Nperiod
    RZSM_matrix(:,:,iperiod) = RZSM(iperiod).SM;
    datesArray(iperiod) = RZSM(iperiod).centerDate;
end
drawTimeSeriesPlot('Africa',datesArray,)