function mapSoilMoisture(fig,SM,date,lat,lon,outlineLat,outlineLon)

% Function that maps soil moisture at a given time according to SMAP Color
% Limits
% 
% INPUT: fig        = figure window for output 
%        SM         = structure array with fields SM, startDate, centerDate,
%                     endDate
%        date       = date of interest (datetime array)
%        lat        = latitude in area of interest (size: Nlat x Nlon)
%        lon        = longitude in area of interest (size: Nlat x Nlon)
%        outlineLat = latitude of coast outline 
%        outlineLon = longitude of coast outline

% Load SMAP specific colormap
load('input/SMAP_Color_SoilMoisture.mat')

% Find which date period includes inputted date
dateInd = find(isbetween(date,[SM.startDate],[SM.endDate]));

% Plot SM values based on date and coordinates
pcolor(lon,lat,SM(dateInd).SM); hold on
shading flat

% SMAP Color Specifications
clim(SMAP_Color_Limit)
colormap(SMAP_Color_SoilMoisture/256) % Divide by 256 for RGB
colorbar

% Plot boundary outline
geoshow(outlineLat,outlineLon,'LineWidth',0.01,'Color','k')
set(gca,'xtick',[]) % Remove x and y axis labels and ticks
set(gca,'ytick',[])

end
