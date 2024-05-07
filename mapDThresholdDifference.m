function mapDThresholdDifference(fig,DThresholds,month,lat,lon,outlineLat,outlineLon,threshold1Field,threshold2Field)

% Function that maps the difference in D Thresholds 
% 
% INPUT: fig = figure
%        DThresholds = structure array with fields
%        month = month to plot (number 1 to 12)
%        lat = latitude in area of interest (Nlat x Nlon)
%        lon = longitude in area of interest (Nlat x Nlon)
%        threshold1Field = string of drought threshold name for comparison
%        threshold2Field = string of drought threshold name for comparison

red = [200, 0, 0]/256; white = [1,1,1];
redWhiteGradient = [linspace(white(1),red(1),500)', linspace(white(2),red(2),500)', linspace(white(3),red(3),500)'];

D_diff = [DThresholds(month).(threshold1Field)]-[DThresholds(month).(threshold2Field)];
pcolor(lon,lat,D_diff);
hold on
shading flat
colormap(redWhiteGradient)
% colorbar()

% P = prctile(D_diff,[10 90],'all');
% disp(P);
clim([0 0.03])

geoshow(outlineLat,outlineLon,'LineWidth',0.01,'Color','k') 
set(gca,'xtick',[])
set(gca,'ytick',[])

end