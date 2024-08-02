function drawTimeSeriesPlot(fig,name,datesArray,missingDatePeriods,percentData,label,color) 

% Function that draws the time series plot for a given region and dates

% INPUT: fig                = figure window for output
%        name               = name of area of interest (string)
%        datesArray         = array of dates used in percentData (datetime array)
%        percentData        = array of percentages in evaluated drought threshold
%                             (size: Nlat x Nlon)
%        missingDatePeriods = array of dates with no SMAP data (datetime
%                             array, size: number of periods x period
%                             length)
%        label              = fieldname of drought category to be evaluated 
%                             (string or char)
%        color              = color hexcode of drought category in plot (string)

% Plot percentage area under specified drought threshold
area(datesArray,percentData,'EdgeColor',color,'FaceColor',color,'DisplayName',label)
hold on

% Plot missing SMAP data dates
for iperiod = 1:size(missingDatePeriods,1)
    dt = size(missingDatePeriods,2); % Date period length

    % Create gray region for missing data (add 1 to end date for whole day)
    % Add gray region to beginning and end of time averaging
    xregion(missingDatePeriods(iperiod,1)-ceil((dt+1)/2),missingDatePeriods(iperiod,end)+floor((dt+1)/2),...
            'HandleVisibility', 'off','FaceAlpha',1,'FaceColor',[0.8 0.8 0.8])
    hold on
end

% Plot abels
title([name ' Percent Area in Drought Monitor Categories'])
xlabel('Date')
ylabel(['Percent Area (%) of ' name])

% Limit x-axis to beginning and end of year, y-axis to 0-100%
xlim([datetime(year(datesArray(1)),1,1),datetime(year(datesArray(end)),12,31)])
ylim([0 100])

% Add legend of drought categories
legend('Location','northoutside','Orientation','horizontal')
legend('boxoff')

% Keep only month labels on x-axis (declutter figure)
xticklabels({"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"})

end