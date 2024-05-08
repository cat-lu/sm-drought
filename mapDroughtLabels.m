function mapDroughtLabels(fig,SM_withDroughtLabels,lat,lon,outlineLat,outlineLon)

% Given an array of SM drought labels (Nlat x Nlon) and latitude +
% longitude values in an area, map the location with drought categories
% 
% INPUT: SM_withDroughtLabels = 2D array 
%        lat = 
%        lon = 

DColors = hex2rgb(["#ffec52","#ffdb6b","#ff9f0f","#ef482a","#9d2001"]);

pcolor(lon,lat,SM_withDroughtLabels);
hold on
colormap(DColors)
shading flat
geoshow(outlineLat,outlineLon,'LineWidth',1,'Color','k')
hold on

set(gca,'xtick',[])
set(gca,'ytick',[])
% set(map,'alphadata',0)

% colorbar('Ticks',[0.4 1.2 2 2.8 3.6],'TickLabels',{"D0","D1","D2","D3","D4"});

end %function