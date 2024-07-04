%% Main code block for climate reference regions in Africa
clear; clc

%% Load shapefiles of climate reference regions in Africa
WGIregionshp =  '\Users\cathe\Repos\sm-drought\input\IPCC-WGI-reference-regions-v4_shapefile\IPCC-WGI-reference-regions-v4.shp';
IPCCregionshp = '\Users\cathe\Repos\sm-drought\input\referenceRegions\referenceRegions.shp';
WGIregions = shaperead(WGIregionshp,'UseGeoCoords',true);
IPCCregions = shaperead(IPCCregionshp,'UseGeoCoords',true);

regionSHP = shaperead('output\AfricaRegions\regionSHP.shp','UseGeoCoords',true);

%% Create updated hybrid climate reference regions (MED, SAH, WAF, CAF, SAF, EAF)
AfricaRegionNames = ["MED","SAH","WAF","CAF","EAF","SAF"];
regionalTimeSeries = struct('Acronym',[],'Name',[],'Lat',[],'Lon',[],'Dpercent',[],'SM',[]);

for i = 1:length(AfricaRegionNames)
    if sum(strcmp(AfricaRegionNames(i),"SAF"))==1
        % Merge WGI regions (Iturbide et al., 2020)
        SAF = ["WSAF","ESAF","MDG"];
        SAFLats = []; SAFLons = [];
        % Combine latitude and longitudes for SAF regions
        for j = 1:length(SAF)
            index = find(strcmp({WGIregions.Acronym}, SAF(j))==1);
            currentRegion = WGIregions(index);
            SAFLats = [SAFLats; currentRegion.Lat'];
            SAFLons = [SAFLons; currentRegion.Lon'];
        end
        % Remove null values
        isNull = isnan(SAFLats);
        SAFLats = SAFLats(~isNull); SAFLons = SAFLons(~isNull);
        % Only include outer boundary of SAF region
        idx = boundary(SAFLats,SAFLons);
        SAFLats = SAFLats(idx); SAFLons = SAFLons(idx);
        regionSHP(i).Geometry = 'Polygon';
        regionSHP(i).Lon = SAFLons;
        regionSHP(i).Lat = SAFLats;
        regionSHP(i).Name = 'Southern-Africa';
        regionSHP(i).Acronym = 'SAF';
    elseif sum(strcmp(AfricaRegionNames(i),"EAF"))==1
        EAF = ["NEAF","SEAF"];
        EAFLats = []; EAFLons = [];
        % Combine latitude and longitudes for EAF regions
        for j = 1:length(EAF)
            index = find(strcmp({WGIregions.Acronym}, EAF(j))==1);
            currentRegion = WGIregions(index);
            EAFLats = [EAFLats; currentRegion.Lat'];
            EAFLons = [EAFLons; currentRegion.Lon'];
        end
        % Remove null values
        isNull = isnan(EAFLats);
        EAFLats = EAFLats(~isNull); EAFLons = EAFLons(~isNull);
        % Only include outer boundary of EAF region
        idx = boundary(EAFLats,EAFLons);
        EAFLats = EAFLats(idx); EAFLons = EAFLons(idx);
        regionSHP(i).Geometry = 'Polygon';
        regionSHP(i).Lon = EAFLons;
        regionSHP(i).Lat = EAFLats;
        regionSHP(i).Name = 'Eastern-Africa';
        regionSHP(i).Acronym = 'EAF';
    else % Keep lat/lon coords of other WGI regions (Iturbide et al., 2020)
        index = find(strcmp({WGIregions.Acronym}, AfricaRegionNames(i))==1);
        currentRegion = WGIregions(index);
        regionSHP(i).Geometry = currentRegion.Geometry;
        regionSHP(i).Lon = currentRegion.Lon;
        regionSHP(i).Lat = currentRegion.Lat;
        regionSHP(i).Name = currentRegion.Name;
        regionSHP(i).Acronym = currentRegion.Acronym;
    end
end
% Create new shapefile for hybrid regions in output folder
shapewrite(regionSHP,'output\AfricaRegions\regionSHP.shp')

%% Calculate surface SM time series (percent area in D0-D4 drought)
load('output/avgSM_Africa_8day.mat','avgSM_Africa')
load('output/DThresholdsAfrica_8daySurface.mat','D_AfricaSurface')
load('output/SM_Africa_shapefile.mat','coordsAfrica')

% Open created shapefile and initialize regions struct array
regionSHP = shaperead('output\AfricaRegions\regionSHP.shp','UseGeoCoords',true);
AfricaRegionNames = ["MED","SAH","WAF","CAF","EAF","SAF"];
AfricaRegions = struct('Acronym',[],'Name',[],'Lat',[],'Lon',[],'Data',[]);

% Transform SM structure array to 3D Matrix (easier to cut data to region's
% boundaries)
SM_matrix = transformStructTo3DMatrix(avgSM_Africa,'SM'); 
DNames = ["D0","D1","D2","D3","D4"];

for i = 1:length(AfricaRegionNames)
    currentRegion = regionSHP(i);
    % Cut data to a region based on coordinates compared to SMAP data
    [regionSM,regionlat,regionlon] = cut3D(SM_matrix,coordsAfrica.Lat,coordsAfrica.Lon,currentRegion);  

    % Initialize time series variable to store percent in drought
    regionDpercent = transformMatrix3DToStruct(regionSM,avgSM_Africa,'SM');
    D_RegionalSurface = rmfield(D_AfricaSurface,{'Median','a','b'}); % Remove extraneous fields

    % Calculate percent area in D0-D4
    for D = 1:length(DNames)
        % Find D Threshold array (Nlat x Nlon x 12) for region
        D_matrix = transformStructTo3DMatrix(D_AfricaSurface,DNames(D));
        regionD = cut3D(D_matrix,coordsAfrica.Lat,coordsAfrica.Lon,currentRegion);
        % Add regional D Threshold to struct array
        D_RegionalSurface = transformMatrix3DToStruct(regionD,D_RegionalSurface,DNames(D));
        % Compare SM with D Threshold to calculate percentage in drought
        regionDpercent = calculateTimeSeries(regionDpercent,D_RegionalSurface,DNames(D)); % Add new field
    end %D

    % Add data into structure array
    AfricaRegions(i).Acronym = currentRegion.Acronym;
    AfricaRegions(i).Name = currentRegion.Name;
    AfricaRegions(i).Lat = regionlat;
    AfricaRegions(i).Lon = regionlon;
    AfricaRegions(i).Data = regionDpercent; % Add D percentages struct array into Data field

end
save('output\AfricaRegions.mat','AfricaRegions','-v7.3')

%% FIGURE: Plot regional time series (surface SM)
load('output\AfricaRegions.mat','AfricaRegions')
load('output\avgSM_Africa_8day.mat', 'missingDatePeriods')
% Labels and hexcodes for D0-D4 drought categories
DNames = ["D0","D1","D2","D3","D4"];
DColors = ["#ffec52","#ffdb6b","#ff9f0f","#ef482a","#9d2001"];

for iregion = 1:length(AfricaRegions)
    currentRegionData = AfricaRegions(iregion).Data;
    yearOfCenter = ymd([currentRegionData.centerDate]);

    for y = 2015:2023 % Years of SMAP data
        % Filter for only data in year y
        datesInYear = [currentRegionData(yearOfCenter==y).centerDate]';

        % Filter out missing date periods for year y
        centerInd = floor((size(missingDatePeriods,2)+1)/2);
        yearOfCenterMissing = ymd(missingDatePeriods(:,centerInd));
        missingDatesInYear = [missingDatePeriods(yearOfCenterMissing==y,:)];

        fig = figure('Position',[100 200 1800 500]);

        for D = 1:length(DNames)
            % Find relevant percentInD field in structure array
            field = "percentIn"+DNames(D);
            percentD = [currentRegionData.(field)]';
            percentDInYear = percentD(yearOfCenter==y);
            % Plot drought time series by year 
            drawTimeSeriesPlot(fig,AfricaRegions(iregion).Acronym,datesInYear,missingDatesInYear,percentDInYear,DNames(D),DColors(D))
        end %D Thresholds
        hold off;
        saveas(gcf,['output/Figures/RegionalResults/TimeSeries/noTitle/TimeSeries_',num2str(y),'_',AfricaRegions(iregion).Acronym],'jpeg')
        saveas(gcf,['output/Figures/RegionalResults/TimeSeries/noTitle/fig/TimeSeries_',num2str(y),'_',AfricaRegions(iregion).Acronym],'fig')

    end %year
end %iregion
%% Calculate filtered RZSM time series (percent area in D0-D4 drought)
load('output/RZSM_Africa.mat','RZSM_Africa')
load('output/DThresholdsAfrica_8dayRoot.mat','D_AfricaRoot')
load('output/SM_Africa_shapefile.mat','coordsAfrica')

% Open created shapefile and initialize regions struct array
regionSHP = shaperead('output\AfricaRegions\regionSHP.shp','UseGeoCoords',true);
AfricaRegionNames = ["MED","SAH","WAF","CAF","EAF","SAF"];
filteredAfricaRegions = struct('Acronym',[],'Name',[],'Lat',[],'Lon',[],'Data',[]);

RZSM_matrix = transformStructTo3DMatrix(RZSM_Africa,'SM'); 
DNames = ["D0","D1","D2","D3","D4"];

for i = 1:length(AfricaRegionNames)
    currentRegion = regionSHP(i);
    % Cut data based on coordinates compared to SMAP data
    [regionSM,regionlat,regionlon] = cut3D(RZSM_matrix,coordsAfrica.Lat,coordsAfrica.Lon,currentRegion);    
    
    % Initialize time series variable to store percent in drought
    regionDpercent = transformMatrix3DToStruct(regionSM,RZSM_Africa,'SM');
    D_RegionalRoot = rmfield(D_AfricaRoot,{'Median','a','b'}); % create regional D struct

    % Calculate percent area in D0-D4
    for D = 1:length(DNames)
        % Find D Threshold array (Nlat x Nlon x 12) for region
        D_matrix = transformStructTo3DMatrix(D_AfricaRoot,DNames(D));
        regionD = cut3D(D_matrix,coordsAfrica.Lat,coordsAfrica.Lon,currentRegion);
        % Add regional D Threshold to struct array
        D_RegionalRoot = transformMatrix3DToStruct(regionD,D_RegionalRoot,DNames(D));
        % Compare SM with D Threshold to calculate percentage in drought
        regionDpercent = calculateTimeSeries(regionDpercent,D_RegionalRoot,DNames(D)); % Add new field
    end

    % Add data into structure array
    filteredAfricaRegions(i).Acronym = currentRegion.Acronym;
    filteredAfricaRegions(i).Name = currentRegion.Name;
    filteredAfricaRegions(i).Lat = regionlat;
    filteredAfricaRegions(i).Lon = regionlon;
    filteredAfricaRegions(i).Data = regionDpercent;

end
save('output\filteredAfricaRegions.mat','filteredAfricaRegions','-v7.3')

%% FIGURE: Plot regional time series (filtered RZSM) 
load('output\filteredAfricaRegions.mat','filteredAfricaRegions')
load('output\avgSM_Africa_8day.mat', 'missingDatePeriods')
% Labels and hexcodes for D0-D4 drought categories
DNames = ["D0","D1","D2","D3","D4"];
DColors = ["#ffec52","#ffdb6b","#ff9f0f","#ef482a","#9d2001"];

for iregion = 1:length(filteredAfricaRegions)
    currentRegionData = filteredAfricaRegions(iregion).Data;
    yearOfCenter = ymd([currentRegionData.centerDate]);
    
    for y = 2015:2023 % Years of SMAP data
        % Filter for only data in year y
        datesInYear = [currentRegionData(yearOfCenter==y).centerDate]';

        % Filter out missing date periods for year y
        centerInd = floor((size(missingDatePeriods,2)+1)/2);
        yearOfCenterMissing = ymd(missingDatePeriods(:,centerInd));
        missingDatesInYear = [missingDatePeriods(yearOfCenterMissing==y,:)];
        
        fig = figure('Position',[100 200 1800 500]);

        for D = 1:length(DNames)
            % Find relevant percentInD field in structure array
            field = "percentIn"+DNames(D);
            percentD = [currentRegionData.(field)]';
            percentDInYear = percentD(yearOfCenter==y);
            % Plot drought time series by year 
            drawTimeSeriesPlot(fig,filteredAfricaRegions(iregion).Acronym,datesInYear,missingDatesInYear,percentDInYear,DNames(D),DColors(D))
        end %D Thresholds
        hold off;
        saveas(gcf,['output/Figures/RegionalResults/TimeSeriesFiltered/noTitle/TimeSeries_',num2str(y),'_',filteredAfricaRegions(iregion).Acronym],'jpeg')
        saveas(gcf,['output/Figures/RegionalResults/TimeSeriesFiltered/noTitle/fig/TimeSeries_',num2str(y),'_',filteredAfricaRegions(iregion).Acronym],'fig')

    end %year
end %iregion

%% FIGURE: 2017-2018 Regional Time Series figure creation (SM)
% Plot regional time series for combined 2017-2018 (anomaly year)
load('output\AfricaRegions.mat','AfricaRegions')
% Labels and hexcodes for D0-D4 drought categories
DNames = ["D0","D1","D2","D3","D4"];
DColors = ["#ffec52","#ffdb6b","#ff9f0f","#ef482a","#9d2001"];

for iregion = 1:length(AfricaRegions)
    currentRegionData = AfricaRegions(iregion).Data; %Load regional data
    yearOfCenter = ymd([currentRegionData.centerDate]);
    yearInd = yearOfCenter==2017|yearOfCenter==2018; % Filter for only 2017-2018
    datesInYear=[currentRegionData(yearInd).centerDate]';
    fig = figure('Position',[100 200 1800 500]);
    for D = 1:length(DNames)
        % Find relevant percentInD field in structure array
        field = "percentIn"+DNames(D);
        percentD = [currentRegionData.(field)]';
        percentDInYear = percentD(yearInd);
        % Plot drought time series by region
        drawTimeSeriesPlot(fig,AfricaRegions(iregion).Acronym,datesInYear,[],percentDInYear,DNames(D),DColors(D))
    end %D Thresholds
    hold off;
    saveas(gcf,['output/Figures/RegionalResults/2017-18TimeSeries/TimeSeries_',AfricaRegions(iregion).Acronym],'jpeg')
    saveas(gcf,['output/Figures/RegionalResults/2017-18TimeSeries/fig/TimeSeries_',AfricaRegions(iregion).Acronym],'fig')
end %iregion

%% FIGURE: 2017-2018 Regional Time Series figure creation (RZSM)
% Plot filtered regional time series for combined 2017-2018 (anomaly year)
load('output\filteredAfricaRegions.mat','filteredAfricaRegions')
% Labels and hexcodes for D0-D4 drought categories
DNames = ["D0","D1","D2","D3","D4"];
DColors = ["#ffec52","#ffdb6b","#ff9f0f","#ef482a","#9d2001"];

for iregion = 1:length(filteredAfricaRegions)
    currentRegionData = filteredAfricaRegions(iregion).Data; %Load regional data
    yearOfCenter = ymd([currentRegionData.centerDate]);
    yearInd = yearOfCenter==2017|yearOfCenter==2018; % Filter for only 2017-2018
    datesInYear = [currentRegionData(yearInd).centerDate]';
    fig = figure('Position',[100 200 1800 500]);
    for D = 1:length(DNames)
        % Find relevant percentInD field in structure array
        field = "percentIn"+DNames(D);
        percentD = [currentRegionData.(field)]';
        percentDInYear = percentD(yearInd);
        % Plot drought time series by region
        drawTimeSeriesPlot(fig,filteredAfricaRegions(iregion).Acronym,datesInYear,[],percentDInYear,DNames(D),DColors(D))
    end %D Thresholds
    hold off;
    saveas(gcf,['output/Figures/RegionalResults/2017-18TimeSeriesFiltered/TimeSeries_',filteredAfricaRegions(iregion).Acronym],'jpeg')
    saveas(gcf,['output/Figures/RegionalResults/2017-18TimeSeriesFiltered/fig/TimeSeries_',filteredAfricaRegions(iregion).Acronym],'fig')
end %iregion

%% FIGURE: Map of created regions in Africa
load('output\regionalTimeSeries.mat')
regionSHP = shaperead('output\AfricaRegions\regionSHP.shp','UseGeoCoords',true);

% Load shapefile of Africa border
worldFile = 'input\World_Continents\World_Continents.shp';
world = shaperead(worldFile,'UseGeoCoords',true);
row = find(strcmp({world.CONTINENT},'Africa')==1); %Find row exclusive to Africa
shapeAfrica = world(row);
geoAfrica = checkCoordinateReferenceSystem(worldFile,shapeAfrica); %Return geocrs if not already
figure % Plot Africa border (black outline)
geoshow(geoAfrica,'FaceColor',[0.4902 0.4902 0.4902],'EdgeColor','none','FaceAlpha',0.3); hold on
grid minor
set(gca,'XColor','none','YColor','none');

% Set position for region label
posLabelX = {7,5,-7,13,31,21}; posLabelY = {37,22,10,1,5,-22};
[regionSHP.posLabelX] = posLabelX{:}; [regionSHP.posLabelY] = posLabelY{:};

% Show shapefile of each region
for i = 1:length(regionSHP)
    geoshow(regionSHP(i).Lat,regionSHP(i).Lon,'Color','k','LineWidth',1.5)
    text(regionSHP(i).posLabelX,regionSHP(i).posLabelY,regionSHP(i).Acronym,'FontSize',14,'FontName','TimesNewRoman')
    hold on;
end