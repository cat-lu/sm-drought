function aggPct = aggregateSMPercentilesToMonth(startDate,endDate,avgSM,DThresholds,pct,pctValues,porosity)

% Function that averages the percentiles that SM values fall into for each
% month (reducing noise) and returns the monthly percentiles and subsequent
% drought labels (based on USDM drought categories). 
% 
% INPUT:  startDate   = desired start date in array [yyyy,mm,dd]
%         endDate     = desired end date in array [yyyy,mm,dd]
%         avgSM       = structure array with fields SM, startDate,
%                       centerDate, endDate
%         DThresholds = structure array with fields Month, drought categories 
%                       (and subsequent SM values), a, and b (beta distribution 
%                       fitting parameters)
%         porosity    = porosity matrix for given area (size: Nlat x Nlon)
%         pct         = array of desired percentiles for beta distribution fitting
%         pctLabels   = string array of labels for desired percentiles
% OUTPUT: aggPct      = structure array with fields Month, Year,
%                       periodCount (number of periods aggregated for each month), 
%                       Percentiles (averaged monthly SM percentiles), and 
%                       droughtLabels (NaN = No Drought/Missing Data, 0 = D0, 1 = D1, 
%                       2 = D2, 3 = D3, 4 = D4)

% Create arrays of months and years for all months between start and end dates
[yearArray,monthArray] = ymd(startDate:calmonths(1):endDate);
% Total number of months for aggregation
Nmonth = length(monthArray);
% Initialize output structure array
aggPct = struct('Year',cell(1,Nmonth),'Month',cell(1,Nmonth),...
        'periodCount',cell(1,Nmonth),'Percentiles',cell(1,Nmonth),...
        'droughtLabels',cell(1,Nmonth));

iperiod = 1; % Track date period index
for imonth = 1:Nmonth
    numPeriods = 0; % Track number of periods in each month
    currentMonth = monthArray(imonth);
    monthStruct = struct('Pct',{}); % Initialize empty struct for each month
    
    % Check first if number of periods does not exceed available, then if
    % period is in current month (based on centerDate)
    while (iperiod<=length(avgSM)) & (month(avgSM(iperiod).centerDate) == currentMonth)
        numPeriods = numPeriods+1;

        % Calculate percentiles from beta cdf
        SM = avgSM(iperiod).SM ./ porosity; % Divide by porosity (betafit used on 0-1 range)
        periodPct = betacdf(SM, DThresholds(currentMonth).a, DThresholds(currentMonth).b);
        
        % Add to structure array to average later (to take into account NaN)
        monthStruct(numPeriods).Pct = periodPct;
        
        iperiod = iperiod+1; 
    end % while in month

    if ~isempty(monthStruct) % Month has dates to average
        % Transform into 3D matrix to average on third dimension (Nperiod)
        pctMatrix = transformStructTo3DMatrix(monthStruct,"Pct");
        avgMonthPercentile = mean(pctMatrix,3,'omitnan');
        % Find drought labels based on percentiles
        avgDroughtLabels = classifyDroughtFromPercentiles(avgMonthPercentile,pct,pctValues);
        
        % Input into structure array
        aggPct(imonth).Year = yearArray(imonth);
        aggPct(imonth).Month = monthArray(imonth); 
        aggPct(imonth).periodCount = numPeriods;
        aggPct(imonth).Percentiles = avgMonthPercentile;
        aggPct(imonth).droughtLabels = avgDroughtLabels;
    end %if
    
    % Track progress in code
    disp(['Month ',num2str(imonth),' of ',num2str(Nmonth)])
end % imonth

end %function