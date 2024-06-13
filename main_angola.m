%% Main code block for Angola case study
clear; clc
% load('output\SM_Africa_shapefile.mat','lat','lon')
% load('output\DThresholdsAfrica_8daySurface.mat','D_AfricaSurface','centerDatePeriod')
load('input\SMAP_Color_SoilMoisture.mat')
%% cut coordinates to Angola
% load('output\SM_Africa_shapefile.mat','coordsAfrica')
angolashp = shaperead('input\Angola_shp\AGO_adm0.shp','UseGeoCoords',true);

coordsAngola = struct('Lat',[],'Lon',[]);
coordsAngola.Lat = cut2D(coordsAfrica.Lat,coordsAfrica.Lat,coordsAfrica.Lon,angolashp);
coordsAngola.Lon = cut2D(coordsAfrica.Lon,coordsAfrica.Lat,coordsAfrica.Lon,angolashp);
save('output\coordsAngola.mat','coordsAngola')

%% Load shapefile and cut Africa data into Angola (surface)
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
%% Load shapefile and cut Africa data into Angola (filtered)
load('output\SM_Africa_shapefile.mat','coordsAfrica')
% load('output\RZSM_withDroughtLabels_Africa_8day.mat','RZSM_withDroughtLabels')
% load('output\DThresholdsAfrica_8dayRoot.mat','D_AfricaRoot')

angolashp = shaperead('input\Angola_shp\AGO_adm0.shp','UseGeoCoords',true);

% Cut down avgSM Africa data 
RZSM_Angola = cutStruct3D(RZSM_withDroughtLabels,'SM',coordsAfrica.Lat,coordsAfrica.Lon,angolashp);
RZSM_Angola = cutStruct3D(RZSM_Angola,'droughtLabels',coordsAfrica.Lat,coordsAfrica.Lon,angolashp);
% Cut down D threshold data
D_AngolaRoot = D_AfricaRoot; % Initialize struct
allFields = fieldnames(D_AfricaRoot);
for ifield = 2:numel(fieldnames(D_AfricaRoot)) % Skips month field
    D_AngolaRoot = cutStruct3D(D_AngolaRoot,allFields{ifield},coordsAfrica.Lat,coordsAfrica.Lon,angolashp);
end %ifield

save('output\RZSM_withDroughtLabels_Angola_8day.mat','RZSM_Angola')
save('output\DThresholdsAngola_8dayRoot.mat','D_AngolaRoot')
%% GeoTIFF (SM)
load('output/coordsAngola.mat')
load('output/avgSM_withDroughtLabels_Angola_8day.mat','avgSM_Angola')
for idate = 1:length(avgSM_Angola)
    R = georasterref('RasterSize',size(avgSM_Angola(idate).SM), ...
    'LatitudeLimits',[min(coordsAngola.Lat,[],'all') max(coordsAngola.Lat,[],'all')],...
    'LongitudeLimits',[min(coordsAngola.Lon,[],'all') max(coordsAngola.Lon,[],'all')]);
    % Filename is center date of 8-day date period
    [yr,mo,dy] = ymd(avgSM_Angola(idate).centerDate);
    yr = num2str(yr); 
    mo = num2str(mo,'%02d'); %Add zero if single digit
    dy = num2str(dy,'%02d'); 
    filename = ['output/Figures/AngolaDroughtLabels/SM/',yr,'_',mo,'_',dy,'.tif'];
    geotiffwrite(filename,flipud(avgSM_Angola(idate).SM),R)
end

%% GeoTIFF (RZSM)
load('output/coordsAngola.mat')
load('output/RZSM_withDroughtLabels_Angola_8day.mat','RZSM_Angola')
for idate = 1:length(RZSM_Angola)
    R = georasterref('RasterSize',size(RZSM_Angola(idate).SM), ...
    'LatitudeLimits',[min(coordsAngola.Lat,[],'all') max(coordsAngola.Lat,[],'all')],...
    'LongitudeLimits',[min(coordsAngola.Lon,[],'all') max(coordsAngola.Lon,[],'all')]);
    % Filename is center date of 8-day date period
    [yr,mo,dy] = ymd(RZSM_Angola(idate).centerDate);
    yr = num2str(yr); 
    mo = num2str(mo,'%02d'); %Add zero if single digit
    dy = num2str(dy,'%02d'); 
    filename = ['output/Figures/AngolaDroughtLabels/RZSM/',yr,'_',mo,'_',dy,'.tif'];
    geotiffwrite(filename,flipud(RZSM_Angola(idate).SM),R)
end

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
%% Plot Angola time series (SM)
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

%% Calculate time series (RZSM)
% load('output/RZSM_withDroughtLabels_Angola_8day.mat','RZSM_Angola')
% load('output/DThresholdsAngola_8dayRoot.mat','D_AngolaRoot')

angolashp = shaperead('input\Angola_shp\AGO_adm0.shp','UseGeoCoords',true);
DNames = ["D0","D1","D2","D3","D4"];
filteredDpercentAngola = RZSM_Angola; % Initialize
% Calculate percent area in D0-D4
for D = 1:length(DNames)
    filteredDpercentAngola = calculateTimeSeries(filteredDpercentAngola,D_AngolaRoot,DNames(D)); % Add new field
end%D

save('output\filteredDpercentAngola.mat','filteredDpercentAngola')
%% Plot Angola time series (RZSM)
% load('output\filteredDpercentAngola.mat','filteredDpercentAngola')
load('output\avgSM_Africa_8day.mat', 'missingDatePeriods')
DNames = ["D0","D1","D2","D3","D4"];
DColors = ["#ffec52","#ffdb6b","#ff9f0f","#ef482a","#9d2001"];

yearOfCenter = ymd([filteredDpercentAngola.centerDate]);

for y = 2015:2023 % Years of SMAP data
    datesInYear = [filteredDpercentAngola(yearOfCenter==y).centerDate]';

    % Filter out missing date periods for year y
    centerInd = floor((size(missingDatePeriods,2)+1)/2);
    yearOfCenterMissing = ymd(missingDatePeriods(:,centerInd));
    missingDatesInYear = [missingDatePeriods(yearOfCenterMissing==y,:)];

    fig = figure('Position',[100 200 1800 500]);

    for D = 1:length(DNames)
        field = "percentIn"+DNames(D);
        percentD = [filteredDpercentAngola.(field)]';
        percentDInYear = percentD(yearOfCenter==y);
        drawTimeSeriesPlot(fig,'Angola',datesInYear,missingDatesInYear,percentDInYear,DNames(D),DColors(D))
    end %D Thresholds
    hold off;
    saveas(gcf,['output/Figures/AngolaResults/TimeSeriesFiltered/noTitle/TimeSeries_',num2str(y),'_Angola'],'jpeg')
    saveas(gcf,['output/Figures/AngolaResults/TimeSeriesFiltered/noTitle/fig/TimeSeries_',num2str(y),'_Angola'],'fig')

end %year
%% Period drought maps
% load('output/avgSM_withDroughtLabels_Angola_8day.mat','avgSM_Angola')
% load('output/coordsAngola.mat','coordsAngola')
angolashp = shaperead('input\Angola_shp\AGO_adm0.shp','UseGeoCoords',true);

for iperiod = 1:length(avgSM_Angola)
    fig = figure('Position',[500 200 500 500]);
    mapDroughtLabels(fig,avgSM_Angola(iperiod).droughtLabels,coordsAngola.Lat,coordsAngola.Lon,angolashp.Lat,angolashp.Lon)
    
    % Title of plot
    startStr = string(avgSM_Angola(iperiod).startDate,'MMM dd, yyyy');
    endStr = string(avgSM_Angola(iperiod).endDate,'MMM dd, yyyy');
    titleString = strcat(startStr," - ",endStr);
    title(titleString)
    axis off
    saveStr = string(avgSM_Angola(iperiod).centerDate,'yyyy_MM_dd');
    saveas(gcf,strcat('output/Figures/AngolaResults/IndividualMapsD0-D4/',saveStr),'jpeg')
    saveas(gcf,strcat('output/Figures/AngolaResults/IndividualMapsD0-D4/fig/',saveStr),'fig')

end % imonth   

% load('output/RZSM_withDroughtLabels_Angola_8day.mat','RZSM_Angola')

for iperiod = 1:length(RZSM_Angola)
    fig = figure('Position',[500 200 500 500]);
    mapDroughtLabels(fig,RZSM_Angola(iperiod).droughtLabels,coordsAngola.Lat,coordsAngola.Lon,angolashp.Lat,angolashp.Lon)
    
    % Title of plot
    startStr = string(RZSM_Angola(iperiod).startDate,'MMM dd, yyyy');
    endStr = string(RZSM_Angola(iperiod).endDate,'MMM dd, yyyy');
    titleString = strcat(startStr," - ",endStr);
    title(titleString)
    axis off
    saveStr = string(RZSM_Angola(iperiod).centerDate,'yyyy_MM_dd');
    saveas(gcf,strcat('output/Figures/AngolaResults/IndividualMapsD0-D4Filtered/',saveStr),'jpeg')
    saveas(gcf,strcat('output/Figures/AngolaResults/IndividualMapsD0-D4Filtered/fig/',saveStr),'fig')

end % imonth   