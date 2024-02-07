function drawTimeSeriesPlot(name,datesArray,Dpercent)

% Function that draws the time series plot for a given region

% INPUT: fig
%        name = Name of region (string)
%        datesArray = array of dates used in Dpercent
%        Dpercent = array of percentage of area in each drought threshold
%        (size: Ndays x 5); 5 corresponds to D0-D4 classification

figure('Position',[100 200 1400 500])
%figure('Position',[100 200 1400 500])
area(datesArray,Dpercent(:,1),'DisplayName','D0-D4','EdgeColor','#ffec52','FaceColor','#ffec52'); hold on
area(datesArray,Dpercent(:,2),'DisplayName','D1-D4','EdgeColor','#ffdb6b','FaceColor','#ffdb6b'); hold on
area(datesArray,Dpercent(:,3),'DisplayName','D2-D4','EdgeColor','#ff9f0f','FaceColor','#ff9f0f'); hold on
area(datesArray,Dpercent(:,4),'DisplayName','D3-D4','EdgeColor','#ef482a','FaceColor','#ef482a'); hold on
area(datesArray,Dpercent(:,5),'DisplayName','D4','EdgeColor','#9d2001','FaceColor','#9d2001')
title([name ' Percent Area in Drought Monitor Categories'])
xlabel('Date')
%ylim([0 .1])
ylabel(['Percent Area of ' name])
legend

end