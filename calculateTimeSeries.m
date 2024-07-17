function avgSM = calculateTimeSeries(avgSM,DThresholds,field)

% Function that returns percentage of a given area that falls under each
% drought threshold field in a given time (adds field to input struct
% array)

% INPUT:  avgSM       = structure array with fields SM, startDate,
%                       centerDate, endDate
%         DThresholds = structure array with fields Month, drought categories 
%                       (and subsequent SM values), a, and b (beta distribution 
%                       fitting parameters)
%         field       = fieldname of drought threshold to be evaluated (string or char)
% OUTPUT: avgSM       = input structure array with additional fields of percentage
%                       area in drought for each drought category (e.g. percentInD0)

assert(isfield(DThresholds,field),"Input fieldname does not exist in input structure array")
monthNames = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];

% Number of date periods in SM data
Nperiod = length(avgSM);
    
for idate = 1:Nperiod
    imonth = month(avgSM(idate).centerDate); % Get month of current date period
    % Confirm DThresholds data is ordered by month (e.g April matches index 4)
    assert(isequal(DThresholds(imonth).Month,monthNames(imonth)),...
        "Months and data in struct array are not ordered") 

    % Calculate number of pixels where SM value is less than chosen drought
    % threshold for area
    countBelowThreshold = nnz(avgSM(idate).SM <= DThresholds(imonth).(field));
    % Calculate total area (non-NaN values)
    totalArea = min(nnz(~isnan(DThresholds(imonth).(field))), ...
        nnz(~isnan(avgSM(idate).SM)));
    % Turn count into percentage
    percentInD = countBelowThreshold/totalArea.*100;

    % Create new field and add to input structure array
    newFieldName = "percentIn"+field;
    avgSM(idate).(newFieldName) = percentInD;

end %idate

end  
