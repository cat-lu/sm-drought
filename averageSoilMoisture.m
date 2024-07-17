function [avgSM,missingDatePeriods] = averageSoilMoisture(SM_combined,dt,minObservedDates)

% Function that returns averages the given soil moisture data over time 
% block dt if days with data is greater than minimum observed dates

% INPUT:  SM_combined      = structure array with fields SM and Date
%                            (dates in SM_combined.Date are desired range)
%         dt               = time step (over which soil moisture is averaged)
%         minObservedDates = minimum number of dates with observed SMAP
%                            values in a dt-time block to qualify for averaging 
% OUTPUT: avgSM              = structure array with fields SM, startDate, centerDate, endDate
%         missingDatePeriods = date periods with no data or not enough days
%                              (<= minObservedDates) for averaging

% Find number of dates in SM_combined and calculate # of time blocks
Ndate = length(SM_combined); % Number of dates
Nperiod = floor(Ndate/dt); % Number of time blocks
[Nlat,Nlon] = size(SM_combined(1).SM);

% Initialize outputs
avgSM = struct('SM',cell(1,Nperiod),'startDate',cell(1,Nperiod),...
        'centerDate',cell(1,Nperiod),'endDate',cell(1,Nperiod));
missingDatePeriods = [];

dayCount = 0; % Initialize day counter within dt-time block
SM_period = NaN(Nlat,Nlon,dt); % Initialize SM matrix of dt-time block
periodCount = 1; % Initialize date period counter
nullCount = 0; % Initialize counter for arrays with no data

for i = 1 : Nperiod*dt
    dayCount = dayCount+1;
    SM_period(:,:,dayCount) = SM_combined(i).SM; % Add SM to temp matrix

    if isequaln(SM_period(:,:,dayCount),NaN(Nlat,Nlon)) % If equal to empty array
        nullCount = nullCount+1;
    end

    if dayCount == dt
        % Track start, center and end dates of dt-time block
        i_beg = i-dt+1; 
        i_center = floor((i_beg+i)/2);
        avgSM(periodCount).startDate = SM_combined(i_beg).Date;
        avgSM(periodCount).centerDate = SM_combined(i_center).Date;
        avgSM(periodCount).endDate = SM_combined(i).Date;
        
        if dt-nullCount >= minObservedDates
            % Average soil moisture in time block of dt days (calculates mean along
            % third dimension, omitting NaN values)
            avgSM(periodCount).SM = mean(SM_period,3,'omitnan');
        else
            % Adds array of NaNs if not enough observed dates
            avgSM(periodCount).SM = NaN(Nlat,Nlon);
            missingRange = SM_combined(i_beg).Date : SM_combined(i).Date;
            missingDatePeriods = [missingDatePeriods; missingRange];
        end

        % Track progress of code block
        disp(['Date period ',num2str(periodCount),' of ',num2str(Nperiod)])
        
        dayCount = 0; % Reset counter after each time block
        nullCount = 0;
        periodCount = periodCount+1;
        SM_period = NaN(Nlat,Nlon,dt);
    end

end % Loop number of time blocks available
end %function