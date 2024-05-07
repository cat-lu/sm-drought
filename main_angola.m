%% Main code block for Angola case study
clear; clc
% load('output\SM_Africa_shapefile.mat','lat','lon')
% load('output\DThresholdsAfrica_8daySurface.mat','D_AfricaSurface','centerDatePeriod')
load('input\SMAP_Color_SoilMoisture.mat')
%% Load shapefile and cut Africa data into Angola (just surface)
load('output\SM_Africa_shapefile.mat','coordsAfrica')
load('output\avgSM_withDroughtLabels_Africa_8day.mat','SM_withDroughtLabels')
load('output\DThresholdsAfrica_8daySurface.mat','D_AfricaSurface')
% load('output\DThresholdsAfrica_8dayRoot.mat','D_AfricaRoot')

angolashp = shaperead('input\Angola_shp\AGO_adm0.shp','UseGeoCoords',true);

% Cut down avgSM Africa data 
avgSM_Angola = cutStruct3D(SM_withDroughtLabels,'SM',coordsAfrica.Lat,coordsAfrica.Lon,angolashp);
avgSM_Angola = cutStruct3D(avgSM_Angola,'droughtLabels',coordsAfrica.Lat,coordsAfrica.Lon,angolashp);
% Cut down D threshold data
D_AngolaSurface = D_AfricaSurface; % Initialize struct
allFields = fieldnames(D_AfricaSurface);
for ifield = 2:numel(fieldnames(D_AfricaSurface)) % Skips month field
    D_AngolaSurface = cutStruct3D(D_AngolaSurface,allFields{ifield},coordsAfrica.Lat,coordsAfrica.Lon,angolashp);
end %ifield

save('output\avgSM_withDroughtLabels_Angola_8day.mat','avgSM_Angola')
save('output\DThresholdsAngola_8daySurface.mat','D_AngolaSurface')

%% GeoTIFF
R = georasterref('RasterSize',size(avgSM_Angola(:,:,1)), ...
'LatitudeLimits',[min(latAngola,[],'all') max(latAngola,[],'all')],...
'LongitudeLimits',[min(lonAngola,[],'all') max(lonAngola,[],'all')]);

filename = 'output/SM_Angola_4.1.15.tif';
geotiffwrite(filename,flipud(avgSM_Angola(:,:,1)),R)
%% show geotiff
[grid,ref] = readgeoraster(filename); 
geoshow(grid,ref)
%%
%% Calculate time series (SM)
% load('output/avgSM_withDroughtLabels_Angola_8day.mat','avgSM_Angola')
% load('output/DThresholdsAngola_8daySurface.mat','D_AngolaSurface')

angolashp = shaperead('input\Angola_shp\AGO_adm0.shp','UseGeoCoords',true);
DNames = ["D0","D1","D2","D3","D4"];
DpercentAngola = avgSM_Angola; % Initialize
% Calculate percent area in D0-D4
for D = 1:length(DNames)
    DpercentAngola = calculateTimeSeries(DpercentAngola,D_AngolaSurface,DNames(D)); % Add new field
end%D

save('output\DpercentAngola.mat','DpercentAngola')
%% Plot regional time series (SM)
% load('output\DpercentAngola.mat','DpercentAngola')
load('output\avgSM_Africa_8day.mat', 'missingDatePeriods')
DNames = ["D0","D1","D2","D3","D4"];
DColors = ["#ffec52","#ffdb6b","#ff9f0f","#ef482a","#9d2001"];

yearOfCenter = ymd([DpercentAngola.centerDate]);

for y = 2015:2023 % Years of SMAP data
    datesInYear = [DpercentAngola(yearOfCenter==y).centerDate]';

    % Filter out missing date periods for year y
    centerInd = floor((size(missingDatePeriods,2)+1)/2);
    yearOfCenterMissing = ymd(missingDatePeriods(:,centerInd));
    missingDatesInYear = [missingDatePeriods(yearOfCenterMissing==y,:)];

    fig = figure('Position',[100 200 1800 500]);

    for D = 1:length(DNames)
        field = "percentIn"+DNames(D);
        percentD = [DpercentAngola.(field)]';
        percentDInYear = percentD(yearOfCenter==y);
        drawTimeSeriesPlot(fig,'Angola',datesInYear,missingDatesInYear,percentDInYear,DNames(D),DColors(D))
    end %D Thresholds
    hold off;
    saveas(gcf,['output/Figures/AngolaResults/TimeSeries/noTitle/TimeSeries_',num2str(y),'_Angola'],'jpeg')
    saveas(gcf,['output/Figures/AngolaResults/TimeSeries/noTitle/fig/TimeSeries_',num2str(y),'_Angola'],'fig')

end %year