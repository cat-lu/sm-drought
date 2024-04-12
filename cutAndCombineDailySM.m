function [SM_combined,coords,missingDates] = cutAndCombineDailySM(folder,startDate,endDate,boundary)

% Function that combines individual SMAP files (.mat) into one matrix given
% folder directory and date range (requires access to daily SMAP files)
% Note: Days with missing SMAP data will show up as array of NaNs

% INPUT: folder = directory of folder with individual SMAP files
%        startDate = desired start date in array [yyyy,mm,dd]
%        endDate = desired end date in array [yyyy,mm,dd]
%        boundary = shapefile (geographic data structure array) 
%                   OR bounding box [minlat,maxlat; minlon,maxlon]
% OUTPUT: SM_combined = structure array with fields SM and Date
%         coords = structure array with fields Lat and Lon
%         missingDates = array of dates with no SMAP data

% Load SMAP latitude and longitude coordinates in input folder
load([cd '/input/SMAPCenterCoordinates9KM.mat'],'SMAPCenterLatitudes','SMAPCenterLongitudes')

% Range of desired inputted dates
datet = datetime(startDate(1),startDate(2),startDate(3)) : ...
        datetime(endDate(1),endDate(2),endDate(3));
[yr,mo,dy] = ymd(datet); % Separate year, month, day arrays

% Pre-allocate structure array with combined soil moisture and date
SM_combined = struct('SM',cell(1,length(datet)),'Date',cell(1,length(datet)));
% Keep track of dates with no data
missingDates = [];

% Loop to find lat-lon of boundary aligned with SMAP (runs cut2D once)
for i = 1:length(datet)
    % Construct correct date
    yr_i = num2str(yr(i)); 
    mo_i = num2str(mo(i),'%02d'); %Add zero if single digit
    dy_i = num2str(dy(i),'%02d'); 
    filename = ['SMAP_R18290_005_',yr_i,'_',mo_i,'_',dy_i,'.mat'];

    % Check if file exists (data is not missing)
    if isfile(fullfile(folder,filename))
        data = load(fullfile(folder,filename));
        SM_am = data.SM_am; % Find the pass of SM wanted
        % Cut soil moisture based on boundary input
        [~,lat,lon,insideBound,rowIndexRange,columnIndexRange] = cut2D(SM_am,SMAPCenterLatitudes,SMAPCenterLongitudes,boundary);
        noData = NaN(size(lat)); % Create array to represent days with no data
        % Add latitude and longitude to struct array
        coords.Lat = lat; coords.Lon = lon; 
        break % break for loop once cut2D is run (coordinates aligned)
    end %if file exists
end %idate


for i = 1:length(datet)
    % Construct correct date
    yr_i = num2str(yr(i)); 
    mo_i = num2str(mo(i),'%02d'); %Add zero if single digit
    dy_i = num2str(dy(i),'%02d'); 
    filename = ['SMAP_R18290_005_',yr_i,'_',mo_i,'_',dy_i,'.mat'];
    % Add date to structure array of combined soil moisture
    SM_combined(i).Date = datetime(yr(i),mo(i),dy(i));

    % Check if file exists (data is not missing)
    if isfile(fullfile(folder,filename))
        data = load(fullfile(folder,filename));
        SM_am = data.SM_am; % Find the pass of SM wanted
        
        % Assumes data coordinates are aligned (cut SM according to previous for loop's range)
        SM_cut = SM_am(rowIndexRange,columnIndexRange).*insideBound(rowIndexRange,columnIndexRange);
        SM_combined(i).SM = SM_cut; 
        
    else % Fill SM with NaN if file does not exist
        SM_combined(i).SM = noData; 
        missingDates = [missingDates; datetime(yr(i),mo(i),dy(i))];
    end
    
    % To display progress in code
    disp(['Day ',num2str(i),' of ',num2str(length(datet))])
end

end

