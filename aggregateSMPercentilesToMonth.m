function aggPct = aggregateSMPercentilesToMonth(startDate,endDate,DThresholds,avgSM,pct,pctValues,porosity)

[yearArray,monthArray] = ymd(startDate:calmonths(1):endDate);
Nmonth = length(monthArray);
aggPct = struct('Year',cell(1,Nmonth),'Month',cell(1,Nmonth),...
        'periodCount',cell(1,Nmonth),'Percentiles',cell(1,Nmonth),...
        'droughtLabels',cell(1,Nmonth));

iperiod = 1;
for imonth = 1:Nmonth
    numPeriods = 0;
    currentMonth = monthArray(imonth);
    % runningSum = 0; 
    monthStruct = struct('Pct',{});
    % Check first if number of periods does not exceed available, then if
    % in current month
    while (iperiod<=length(avgSM)) & (month(avgSM(iperiod).centerDate) == currentMonth)
        numPeriods = numPeriods+1;

        % Calculate percentiles from beta cdf
        SM = avgSM(iperiod).SM ./ porosity; % Divide by porosity (betafit used on 0-1 range)
        periodPct = betacdf(SM, DThresholds(currentMonth).a, DThresholds(currentMonth).b);
        
        % Add to structure array to average later (to take into account NaN)
        monthStruct(numPeriods).Pct = periodPct;
        % runningSum = runningSum+periodPct; % Add together periods in same month
        
        iperiod = iperiod+1;

    end % while in month
    % avgMonthPercentile = runningSum./numPeriods;
    if ~isempty(monthStruct)
        pctMatrix = transformStructTo3DMatrix(monthStruct,"Pct");
        avgMonthPercentile = mean(pctMatrix,3,'omitnan');
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