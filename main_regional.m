%% Main code block for regions in Africa
clear; clc
load('\Users\cathe\Repos\sm-drought\output\avgSM_Africa_8day.mat')
load('\Users\cathe\Repos\sm-drought\output\SM_Africa_shapefile.mat','lat','lon')
load('\Users\cathe\Repos\sm-drought\output\DThresholdsAfrica_8daySurface.mat')
%% Load shapefiles and initialize
WGIregionshp =  '\Users\cathe\Repos\sm-drought\input\IPCC-WGI-reference-regions-v4_shapefile\IPCC-WGI-reference-regions-v4.shp';
IPCCregionshp = '\Users\cathe\Repos\sm-drought\input\referenceRegions\referenceRegions.shp';
WGIregions = shaperead(WGIregionshp,'UseGeoCoords',true);
IPCCregions = shaperead(IPCCregionshp,'UseGeoCoords',true);
%% run this for shape
% load('output\SM_Africa_shapefile.mat','lat','lon')
regionSHP = shaperead('output\AfricaRegions\regionSHP.shp','UseGeoCoords',true);
AfricaRegionNames = ["MED","SAH","WAF","CAF","EAF","SAF"];

regionalTimeSeries = struct('Acronym',[],'Name',[],'Lat',[],'Lon',[],'Dpercent',[],'SM',[]);
%% Create hybrid regions; Merge SAF and EAF
for i = 1:length(AfricaRegionNames)
    if sum(strcmp(AfricaRegionNames(i),"SAF"))==1
        % Merge WGI regions
        SAF = ["WSAF","ESAF","MDG"];
        SAFLats = []; SAFLons = [];
        for j = 1:length(SAF)
            index = find(strcmp({WGIregions.Acronym}, SAF(j))==1);
            currentRegion = WGIregions(index);
            % tempLat = SAFLats; tempLon = SAFLons;
            SAFLats = [SAFLats; currentRegion.Lat'];
            SAFLons = [SAFLons; currentRegion.Lon'];
        end
        isNull = isnan(SAFLats);
        SAFLats = SAFLats(~isNull); SAFLons = SAFLons(~isNull);
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
        for j = 1:length(EAF)
            index = find(strcmp({WGIregions.Acronym}, EAF(j))==1);
            currentRegion = WGIregions(index);
            % tempLat = SAFLats; tempLon = SAFLons;
            EAFLats = [EAFLats; currentRegion.Lat'];
            EAFLons = [EAFLons; currentRegion.Lon'];
        end
        isNull = isnan(EAFLats);
        EAFLats = EAFLats(~isNull); EAFLons = EAFLons(~isNull);
        idx = boundary(EAFLats,EAFLons);
        EAFLats = EAFLats(idx); EAFLons = EAFLons(idx);
        regionSHP(i).Geometry = 'Polygon';
        regionSHP(i).Lon = EAFLons;
        regionSHP(i).Lat = EAFLats;
        regionSHP(i).Name = 'Eastern-Africa';
        regionSHP(i).Acronym = 'EAF';
    else
        index = find(strcmp({WGIregions.Acronym}, AfricaRegionNames(i))==1);
        currentRegion = WGIregions(index);
        regionSHP(i).Geometry = currentRegion.Geometry;
        regionSHP(i).Lon = currentRegion.Lon;
        regionSHP(i).Lat = currentRegion.Lat;
        regionSHP(i).Name = currentRegion.Name;
        regionSHP(i).Acronym = currentRegion.Acronym;
    end
end
shapewrite(regionSHP,'output\AfricaRegions\regionSHP.shp')
%% Calculate time series (SM)
load('output/avgSM_Africa_8day.mat','avgSM_Africa')
load('output/DThresholdsAfrica_8daySurface.mat','D_AfricaSurface')
load('output/SM_Africa_shapefile.mat','coordsAfrica')

regionSHP = shaperead('output\AfricaRegions\regionSHP.shp','UseGeoCoords',true);
AfricaRegionNames = ["MED","SAH","WAF","CAF","EAF","SAF"];
AfricaRegions = struct('Acronym',[],'Name',[],'Lat',[],'Lon',[],'Data',[]);

SM_matrix = transformStructTo3DMatrix(avgSM_Africa,'SM'); 
DNames = ["D0","D1","D2","D3","D4"];

for i = 1:length(AfricaRegionNames)
    currentRegion = regionSHP(i);
    % Cut data based on coordinates compared to SMAP data
    [regionSM,regionlat,regionlon] = cut3D(SM_matrix,coordsAfrica.Lat,coordsAfrica.Lon,currentRegion);  

    % regionDpercent = avgSM_Africa; %add D percent info to current structure array
    regionDpercent = transformMatrix3DToStruct(regionSM,avgSM_Africa,'SM');

    D_RegionalSurface = rmfield(D_AfricaSurface,{'Median','a','b'}); % create regional D struct

    % Calculate percent area in D0-D4
    for D = 1:length(DNames)
        D_matrix = transformStructTo3DMatrix(D_AfricaSurface,DNames(D));
        regionD = cut3D(D_matrix,coordsAfrica.Lat,coordsAfrica.Lon,currentRegion);
        D_RegionalSurface = transformMatrix3DToStruct(regionD,D_RegionalSurface,DNames(D));
        regionDpercent = calculateTimeSeries(regionDpercent,D_RegionalSurface,DNames(D)); % Add new field
    end%D

    % Add data into structure array
    AfricaRegions(i).Acronym = currentRegion.Acronym;
    AfricaRegions(i).Name = currentRegion.Name;
    AfricaRegions(i).Lat = regionlat;
    AfricaRegions(i).Lon = regionlon;
    AfricaRegions(i).Data = regionDpercent;

end
save('output\AfricaRegions.mat','AfricaRegions','-v7.3')
%% Plot regional time series (SM)
% load('output\AfricaRegions.mat','AfricaRegions')
% load('output\avgSM_Africa_8day.mat', 'missingDatePeriods')
DNames = ["D0","D1","D2","D3","D4"];
DColors = ["#ffec52","#ffdb6b","#ff9f0f","#ef482a","#9d2001"];

for iregion = 1:length(AfricaRegions)
    currentRegionData = AfricaRegions(iregion).Data;
    yearOfCenter = ymd([currentRegionData.centerDate]);

    for y = 2015:2023 % Years of SMAP data
        datesInYear = [currentRegionData(yearOfCenter==y).centerDate]';

        % Filter out missing date periods for year y
        centerInd = floor((size(missingDatePeriods,2)+1)/2);
        yearOfCenterMissing = ymd(missingDatePeriods(:,centerInd));
        missingDatesInYear = [missingDatePeriods(yearOfCenterMissing==y,:)];

        fig = figure('Position',[100 200 1800 500]);

        for D = 1:length(DNames)
            field = "percentIn"+DNames(D);
            percentD = [currentRegionData.(field)]';
            percentDInYear = percentD(yearOfCenter==y);
            drawTimeSeriesPlot(fig,AfricaRegions(iregion).Acronym,datesInYear,missingDatesInYear,percentDInYear,DNames(D),DColors(D))
        end %D Thresholds
        hold off;
        saveas(gcf,['output/Figures/RegionalResults/TimeSeries/noTitle/TimeSeries_',num2str(y),'_',AfricaRegions(iregion).Acronym],'jpeg')
        saveas(gcf,['output/Figures/RegionalResults/TimeSeries/noTitle/fig/TimeSeries_',num2str(y),'_',AfricaRegions(iregion).Acronym],'fig')

    end %year
end %iregion
%% Calculate time series (filtered)
load('output/RZSM_Africa.mat','RZSM_Africa')
load('output/DThresholdsAfrica_8dayRoot.mat','D_AfricaRoot')
load('output/SM_Africa_shapefile.mat','coordsAfrica')

regionSHP = shaperead('output\AfricaRegions\regionSHP.shp','UseGeoCoords',true);
AfricaRegionNames = ["MED","SAH","WAF","CAF","EAF","SAF"];
filteredAfricaRegions = struct('Acronym',[],'Name',[],'Lat',[],'Lon',[],'Data',[]);

RZSM_matrix = transformStructTo3DMatrix(RZSM_Africa,'SM'); 
DNames = ["D0","D1","D2","D3","D4"];

for i = 1:length(AfricaRegionNames)
    currentRegion = regionSHP(i);
    % Cut data based on coordinates compared to SMAP data
    [regionSM,regionlat,regionlon] = cut3D(RZSM_matrix,coordsAfrica.Lat,coordsAfrica.Lon,currentRegion);    
    % [regionD] = cut4D(D_AfricaRoot,lat,lon,currentRegion);
    
    regionDpercent = transformMatrix3DToStruct(regionSM,RZSM_Africa,'SM');
    % for iperiod = 1:length(regionDpercent)
    %     regionDpercent(iperiod).SM = regionSM(:,:,iperiod); % Change SM field to region-specific SM
    % end%iperiod
    D_RegionalRoot = rmfield(D_AfricaRoot,{'Median','a','b'}); % create regional D struct

    % Calculate percent area in D0-D4
    for D = 1:length(DNames)
        D_matrix = transformStructTo3DMatrix(D_AfricaRoot,DNames(D));
        regionD = cut3D(D_matrix,coordsAfrica.Lat,coordsAfrica.Lon,currentRegion);
        D_RegionalRoot = transformMatrix3DToStruct(regionD,D_RegionalRoot,DNames(D));
        % for imonth = 1:length(D_RegionalRoot)
        %     D_RegionalRoot(imonth).(DNames(D)) = regionD(:,:,imonth);
        % end %imonth

        regionDpercent = calculateTimeSeries(regionDpercent,D_RegionalRoot,DNames(D)); % Add new field
    end

    % Add data into structure array
    filteredAfricaRegions(i).Acronym = currentRegion.Acronym;
    filteredAfricaRegions(i).Name = currentRegion.Name;
    filteredAfricaRegions(i).Lat = regionlat;
    filteredAfricaRegions(i).Lon = regionlon;
    filteredAfricaRegions(i).Data = regionDpercent;

end
save('output\filteredAfricaRegions2.mat','filteredAfricaRegions2','-v7.3')
%% Plot regional time series (filtered)
load('output\filteredAfricaRegions.mat','filteredAfricaRegions')
load('output\avgSM_Africa_8day.mat', 'missingDatePeriods')
DNames = ["D0","D1","D2","D3","D4"];
DColors = ["#ffec52","#ffdb6b","#ff9f0f","#ef482a","#9d2001"];

for iregion = 1:length(filteredAfricaRegions)
% for iregion = 1:1
    currentRegionData = filteredAfricaRegions(iregion).Data;
    yearOfCenter = ymd([currentRegionData.centerDate]);
    for y = 2015:2023 % Years of SMAP data
    % for y = 2022
        datesInYear = [currentRegionData(yearOfCenter==y).centerDate]';

        % Filter out missing date periods for year y
        centerInd = floor((size(missingDatePeriods,2)+1)/2);
        yearOfCenterMissing = ymd(missingDatePeriods(:,centerInd));
        missingDatesInYear = [missingDatePeriods(yearOfCenterMissing==y,:)];
        % yearvec = datevec(centerDatePeriod); 
        % yearvec = yearvec(:,1);
        % datesInYear = centerDatePeriod(yearvec==y);

        fig = figure('Position',[100 200 1800 500]);
        % newfig = figure('Position',[100 200 1400 500]);

        for D = 1:length(DNames)
            % DpercentInYear = DpercentInYear(yearvec==y,:);
            % drawTimeSeriesPlot(regionalTimeSeries(i).Acronym,datesInYear,DpercentInYear);
            field = "percentIn"+DNames(D);
            percentD = [currentRegionData.(field)]';
            percentDInYear = percentD(yearOfCenter==y);
            % testpercentd = repelem(percentDInYear,[5,repelem(8,length(percentDInYear)-1)]);

            % drawTimeSeriesPlot(newfig,filteredAfricaRegions(iregion).Acronym,datesDaily,missingDatesInYear,testpercentd,DNames(D),DColors(D))
            drawTimeSeriesPlot(fig,filteredAfricaRegions(iregion).Acronym,datesInYear,missingDatesInYear,percentDInYear,DNames(D),DColors(D))
        end %D Thresholds
        hold off;
        saveas(gcf,['output/Figures/RegionalResults/TimeSeriesFiltered/noTitle/TimeSeries_',num2str(y),'_',filteredAfricaRegions(iregion).Acronym],'jpeg')
        saveas(gcf,['output/Figures/RegionalResults/TimeSeriesFiltered/noTitle/fig/TimeSeries_',num2str(y),'_',filteredAfricaRegions(iregion).Acronym],'fig')

    end %year
    % drawTimeSeriesPlot(regionalTimeSeries(i).Acronym,centerDatePeriod,regionalTimeSeries(i).Dpercent)
    % saveas(gcf,['test/redo/TimeSeries_' regionalTimeSeries(i).Acronym],'jpeg')
    % saveas(gcf,['test/redo/TimeSeries_' regionalTimeSeries(i).Acronym],'fig')
end %iregion
%% Map of regions
% load('output\regionalTimeSeries.mat')
regionSHP = shaperead('output\AfricaRegions\regionSHP.shp','UseGeoCoords',true);
worldFile = 'input\World_Continents\World_Continents.shp';
world = shaperead(worldFile,'UseGeoCoords',true);
row = find(strcmp({world.CONTINENT},'Africa')==1); %Find row exclusive to Africa
shapeAfrica = world(row);
geoAfrica = checkCoordinateReferenceSystem(worldFile,shapeAfrica); %Return geocrs if not already
figure
geoshow(geoAfrica,'FaceColor',[0.4902 0.4902 0.4902],'EdgeColor','none','FaceAlpha',0.3); hold on
grid minor
set(gca,'XColor','none','YColor','none');

% Set position for region label
posLabelX = {7,5,-7,13,31,21}; posLabelY = {37,22,10,1,5,-22};
[regionSHP.posLabelX] = posLabelX{:}; [regionSHP.posLabelY] = posLabelY{:};

for i = 1:length(regionSHP)
    geoshow(regionSHP(i).Lat,regionSHP(i).Lon,'Color','k','LineWidth',1.5)
    text(regionSHP(i).posLabelX,regionSHP(i).posLabelY,regionSHP(i).Acronym,'FontSize',14,'FontName','TimesNewRoman')
    hold on;
end
