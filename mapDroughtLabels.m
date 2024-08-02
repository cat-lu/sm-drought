function mapDroughtLabels(fig,SM_withDroughtLabels,lat,lon,outlineLat,outlineLon)

% Given an array of SM drought labels (Nlat x Nlon) and latitude +
% longitude values in an area, map the location with drought categories
% 
% INPUT: fig                  = figure window for output
%        SM_withDroughtLabels = array of drought labels (0-4) for a given area
%                               (size: Nlat x Nlon)
%        lat                  = latitude in area of interest (size: Nlat x Nlon)
%        lon                  = longitude in area of interest (size: Nlat x Nlon)
%        outlineLat           = latitude of coast outline 
%        outlineLon           = longitude of coast outline

% Color hexcodes used for drought monitoring categories (D0-D4)
DColors = hex2rgb(["#ffec52","#ffdb6b","#ff9f0f","#ef482a","#9d2001"]);

% Plot based on drought labels and coordinates
pcolor(lon,lat,SM_withDroughtLabels);
hold on
colormap(DColors)
shading flat

% Plot outline boundary
geoshow(outlineLat,outlineLon,'LineWidth',1,'Color','k')
hold on
set(gca,'xtick',[]) % Remove x and y axis labels and ticks
set(gca,'ytick',[])

% Label colorbar tick values at even intervals (D0-D4)
colorbar('Ticks',[0.4 1.2 2 2.8 3.6],'TickLabels',{"D0","D1","D2","D3","D4"});

end %function