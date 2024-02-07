function [SM_combined,lat,lon] = cutAndCombineDailySM(folder,startDate,endDate,boundary)

% Function that combines individual SMAP files (.mat) into one matrix given
% folder directory and date range (requires access to daily SMAP files)
% Note: Days with missing SMAP data will show up as array of NaNs

% INPUT: folder = directory of folder with individual SMAP files
%        startDate = desired start date in array [yyyy,mm,dd]
%        endDate = desired end date in array [yyyy,mm,dd]
%        boundary = shapefile (geographic data structure array) 
%                   OR bounding box [minlat,maxlat; minlon,maxlon]
% OUTPUT: SM_combine = SMAP matrix (size: Nlat x Nlon x Ndates)

% Load SMAP latitude and longitude coordinates in input folder
load([cd '/input/SMAPCenterCoordinates9KM.mat'],'SMAPCenterLatitudes','SMAPCenterLongitudes')

% Range of desired inputted dates
datet = datetime(startDate(1),startDate(2),startDate(3)) : ...
        datetime(endDate(1),endDate(2),endDate(3));
[yr,mo,dy] = ymd(datet); % Separate year, month, day arrays

% Loop to initialize size of combined array 
for i = 1:length(datet)
    % Construct correct date
    yr_i = num2str(yr(i)); 
    mo_i = num2str(mo(i),'%02d'); %Add zero if single digit
    dy_i = num2str(dy(i),'%02d'); 
    filename = ['SMAP_R18290_005_',yr_i,'_',mo_i,'_',dy_i,'.mat'];

    if isfile(fullfile(folder,filename))
        data = load(fullfile(folder,filename));
        SM_am = data.SM_am; % Pick the fieldname to suit.
        % test = cut(SM_am,SMAPCenterLatitudes,SMAPCenterLongitudes,boundary);
        [SM_cut,lat,lon,insideBound,rowIndexRange,columnIndexRange] = cut2D(SM_am,SMAPCenterLatitudes,SMAPCenterLongitudes,boundary);
        % disp(['Size of SM: ',num2str(size(SM_cut)),', Lat: ',num2str(size(lat)),', Lon: ',num2str(size(lon)),', 1 out: ',num2str(size(test))])%All should be same size
        SM_combined = NaN(size(SM_cut,1),size(SM_cut,2),length(datet));
        break
    end %if file exists
end %idate

%dates = cell(1,length(datet));

for i = 1:length(datet)
    % Construct correct date
    yr_i = num2str(yr(i)); 
    mo_i = num2str(mo(i),'%02d'); %Add zero if single digit
    dy_i = num2str(dy(i),'%02d'); 
    filename = ['SMAP_R18290_005_',yr_i,'_',mo_i,'_',dy_i,'.mat'];

    if isfile(fullfile(folder,filename))
        data = load(fullfile(folder,filename));
        SM_am = data.SM_am; % pick the fieldname to suit.
        
        % Assumes data coordinates are aligned
        SM_cut = SM_am(rowIndexRange,columnIndexRange).*insideBound(rowIndexRange,columnIndexRange);

        % [SM_cut,lat,lon] = cut2D(SM_am,SMAPCenterLatitudes,SMAPCenterLongitudes,boundary);
        SM_combined(:,:,i) = SM_cut;
        % dates{1,i} = data.tday;
    % else
    %     dates{2,i} = datetime(yr(i),mo(i),dy(i));% Check if it gets correct missing dates
    end
    
    % To display progress in code
    disp(['Day ',num2str(i),' of ',num2str(length(datet))])
end

end

