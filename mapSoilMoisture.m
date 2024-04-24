function mapSoilMoisture(fig,SM,date,lat,lon,outlineLat,outlineLon)

% Function that maps soil moisture at a given time according to SMAP Color
% Limits
% 
% INPUT: SM = structure array with fields SM, startDate, centerDate,
%             endDate
%        date = date to plot (datetime array)
%        lat = latitude in area of interest (Nlat x Nlon)
%        lon = longitude in area of interest (Nlat x Nlon)

load('input/SMAP_Color_SoilMoisture.mat')

dateInd = find(isbetween(date,[SM.startDate],[SM.endDate]));
pcolor(lon,lat,SM(dateInd).SM); hold on
shading flat
clim(SMAP_Color_Limit)
colormap(SMAP_Color_SoilMoisture/256)
colorbar

geoshow(outlineLat,outlineLon,'LineWidth',0.01,'Color','k')
set(gca,'xtick',[])
set(gca,'ytick',[])

end
