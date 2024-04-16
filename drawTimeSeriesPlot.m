function drawTimeSeriesPlot(fig,name,datesArray,missingDates,percentData,label,color) 

% Function that draws the time series plot for a given region

% INPUT: name = Name of region (string)
%        datesArray = array of dates used in percentData
%        percentData = 
%        missingDates = 
%        label = fieldname of D Threshold to be evaluated (string or char)
%        color =  

set(0, 'DefaultAxesFontSize',14)
set(0,'defaultlinelinewidth',2)
set(0, 'DefaultAxesFontName','TimesNewRoman')
set(0,'DefaultAxesTitleFontWeight','normal')
% D0 = bar(datesArray,Dpercent(:,2),'stacked','EdgeColor','#ffec52','FaceColor','#ffec52'); hold on
% D1 = bar(datesArray,Dpercent(:,3),'stacked','EdgeColor','#ffdb6b','FaceColor','#ffdb6b'); hold on
% D2 = bar(datesArray,Dpercent(:,4),'stacked','EdgeColor','#ff9f0f','FaceColor','#ff9f0f'); hold on
% D3 = bar(datesArray,Dpercent(:,5),'stacked','EdgeColor','#ef482a','FaceColor','#ef482a'); hold on
% D4 = bar(datesArray,Dpercent(:,6),'stacked','EdgeColor','#9d2001','FaceColor','#9d2001'); hold on
% D0 = area(datesArray,percentData(:,2),'EdgeColor','#ffec52','FaceColor','#ffec52'); hold on
% D1 = area(datesArray,percentData(:,3),'EdgeColor','#ffdb6b','FaceColor','#ffdb6b'); hold on
% D2 = area(datesArray,percentData(:,4),'EdgeColor','#ff9f0f','FaceColor','#ff9f0f'); hold on
% D3 = area(datesArray,percentData(:,5),'EdgeColor','#ef482a','FaceColor','#ef482a'); hold on
area(datesArray,percentData,'EdgeColor',color,'FaceColor',color,'DisplayName',label)
hold on

% Plot missing SMAP data dates
for iperiod = 1:size(missingDates,1)
    dt = size(missingDates,2);
    % Create gray region for missing data (add 1 to end date for whole day)
    % Add gray region to beginning and end of time averaging
    xregion(missingDates(iperiod,1)-ceil((dt+1)/2),missingDates(iperiod,end)+floor((dt+1)/2),...
            'HandleVisibility', 'off','FaceAlpha',1,'FaceColor',[0.8 0.8 0.8])
    hold on
    % disp(['start ',string(missingDates(iperiod,1)),'end ',string(missingDates(iperiod,end))])
end

title([name ' Percent Area in Drought Monitor Categories'])
xlabel('Date')
ylabel(['Percent Area (%) of ' name])
% xlim([datesArray(1),datesArray(end)])
xlim([datetime(year(datesArray(1)),1,1),datetime(year(datesArray(end)),12,31)])
ylim([0 60])
legend
% xticklabels({"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"})

end