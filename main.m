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
[SM_Africa,lat,lon] = cutAndCombineDailySM(dir,startDate,endDate,geoAfrica);
save('output/SM_Africa_shapefile.mat', 'SM_Africa','lat','lon', '-v7.3')

%% Average Soil Moisture to 8-day Time Blocks
dt = 8;
[avgSM_Africa,endDates] = averageSoilMoisture(SM_Africa,startDate,endDate,dt);
save('output/avgSM_Africa_8day.mat', 'avgSM_Africa','endDates', '-v7.3')
%% Calculate drought thresholds
dt = 8;
load('output/avgSM_Africa_8day.mat', 'avgSM_Africa');
%%
% Cut down porosity data
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

[D_AfricaSurface,centerDatePeriod,a_param,b_param] = calculateDThresholds(avgSM_Africa,startDate,endDate,dt,porosityAfrica,pct);
save('output/DThresholdsAfrica_8daySurface.mat', 'D_AfricaSurface','centerDatePeriod','a_param','b_param','-v7.3')

%%
RZSM_Africa = filterSurfacetoRZSM();

save('/output/RZSM_Africa.mat','RZSM_Africa','-v7.3')

%%
D_Africa_RZSM = calculateDThresholds();
