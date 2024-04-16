%% Main code block for Angola case study
clear; clc
load('output\avgSM_Angola_8day.mat','avgSM_Angola','latAngola','lonAngola','centerDatePeriod')
% load('output\SM_Africa_shapefile.mat','lat','lon')
% load('output\DThresholdsAfrica_8daySurface.mat','D_AfricaSurface','centerDatePeriod')
load('input\SMAP_Color_SoilMoisture.mat')
%% Load shapefile
angolashp = shaperead('input\Angola_shp\AGO_adm0.shp','UseGeoCoords',true);

[avgSM_Angola,latAngola,lonAngola] = cut3D(avgSM_Africa,lat,lon,angolashp);
D_AngolaSurface = cut4D(D_AfricaSurface,lat,lon,angolashp);

save('output\avgSM_Angola_8day.mat','avgSM_Angola','centerDatePeriod','latAngola','lonAngola')
save('output\DThresholdsAngola_8daySurface.mat','D_AngolaSurface','centerDatePeriod','latAngola','lonAngola')
%% Write variables as csv files
writematrix(latAngola,'csv\latAngola.csv');
writematrix(lonAngola,'csv\lonAngola.csv');
writematrix(centerDatePeriod,'csv\centerDatePeriod.csv')
writematrix(avgSM_Angola,'csv\avgSM_Angola.csv')
writematrix(D_AngolaSurface,'csv\D_AngolaSurface.csv')

%% GeoTIFF
R = georasterref('RasterSize',size(avgSM_Angola(:,:,1)), ...
'LatitudeLimits',[min(latAngola,[],'all') max(latAngola,[],'all')],...
'LongitudeLimits',[min(lonAngola,[],'all') max(lonAngola,[],'all')]);

filename = 'output/SM_Angola_4.1.15.tif';
geotiffwrite(filename,flipud(avgSM_Angola(:,:,1)),R)
%% show geotiff
[grid,ref] = readgeoraster(filename); 
geoshow(grid,ref)
