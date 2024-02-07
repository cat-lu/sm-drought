function [averageSM,endDatePeriod] = averageSoilMoisture(SM_matrix,startDate,endDate,dt)

% Function that returns averages the given soil moisture data over time 
% block dt

% INPUT: SM_matrix = SMAP matrix (size: Nlat x Nlon x Ndates)
%        startDate = desired start date in array [yyyy,mm,dd]
%        endDate = desired end date in array [yyyy,mm,dd]
%        dt = time step (over which soil moisture is averaged)
% OUTPUT: averageSM = averaged soil moisture matrix 
%                     (size: Nlat x Nlon x floor(Ndates/dt))
%         endDatePeriod = array of end dates (last date of each time block)

% Range of desired inputted dates
dateRange = datetime(startDate(1),startDate(2),startDate(3)):datetime(endDate(1),endDate(2),endDate(3));

% Accumulate in Time Blocks of size dt and Mark End-Date of Block
[Nlat,Nlon,Ndate] = size(SM_matrix); 
Nperiod = floor(Ndate/dt);
averageSM = NaN(Nlat,Nlon,Nperiod);
endDatePeriod = NaT(Nperiod,1);

i_t = 0; %Initialize iterations for number of periods

for i = 1:dt:Ndate-(dt-1)
    i_t = i_t + 1;
    i_beg = i;
    i_end = i+(dt-1);
    
    % Average soil moisture in time block of dt days (calculates mean along
    % third dimension, omitting NaN values)
    averageSM(:,:,i_t) = mean(SM_matrix(:,:,i_beg:i_end),3,'omitnan');

    % Track end day of dt time block
    endDatePeriod(i_t,1) = dateRange(i_end);

    % Track progress of code block
    disp(['Date period ',num2str(i_t),' of ',num2str(Nperiod)])
end
end %function