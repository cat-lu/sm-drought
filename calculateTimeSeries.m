function avgSM = calculateTimeSeries(avgSM,DThresholds,field)

% Function that returns percentage of a given area that falls under each
% drought threshold field in a given time (adds field to input struct
% array)

% INPUT: avgSM = structure array with fields SM, startDate,
%                centerDate, endDate
%        DThresholds = structure array with fields Month, percentiles given
%                in pct, a, and b (beta distribution fitting parameters)
%        field = fieldname of D Threshold to be evaluated (string or char)
% OUTPUT: percentInD = structure array with fields percentIn given
%                pctLabels and Date

assert(isfield(DThresholds,field),"Input fieldname does not exist in input structure array")
monthNames = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];

% [Nlat,Nlon,Ndays] = size(avgSM);
%percentInD = zeros(Ndays,size(DThresholds,4));
Nperiod = length(avgSM);
    
for idate = 1:Nperiod
    % imonth = month(datesArray(idate)); % Get month of current date period
    imonth = month(avgSM(idate).centerDate);
    assert(isequal(DThresholds(imonth).Month,monthNames(imonth)),...
        "Months and data in struct array are not ordered")

    countBelowThreshold = nnz(avgSM(idate).SM <= DThresholds(imonth).(field));
    totalArea = min(nnz(~isnan(DThresholds(imonth).(field))), ...
        nnz(~isnan(avgSM(idate).SM))); % Calculates total area (non-NaN values)
    percentInD = countBelowThreshold/totalArea.*100; % Turns count into percentage

    newFieldName = "percentIn"+field;
    avgSM(idate).(newFieldName) = percentInD;

    % for ilat = 1:Nlat
    %     for ilon = 1:Nlon
            % for d = 1:size(DThresholds,4)
                % if avgSM(ilat,ilon,idate) <= DThresholds(ilat,ilon,imonth,d)
                %     percentInD(idate,d) = percentInD(idate,d)+1;
                % 
                % end %if  

            % % end %d
    %     end %ilon
    % end %ilat
end %idate

end  
