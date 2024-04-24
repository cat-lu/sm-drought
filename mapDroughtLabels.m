function mapDroughtLabels(fig,SM_withDroughtLabels,lat,lon,outlineLat,outlineLon)

% Given an array of SM drought labels (Nlat x Nlon) and latitude +
% longitude values in an area, map the location with drought categories
% 
% INPUT: avgSM = structure array
%        DThresholds = 
%        lat = 
%        lon = 

DColors = hex2rgb(["#ffec52","#ffdb6b","#ff9f0f","#ef482a","#9d2001"]);

map = pcolor(lon,lat,SM_withDroughtLabels);
hold on
colormap(DColors)
shading flat
geoshow(outlineLat,outlineLon,'LineWidth',1,'Color','k')
set(gca,'xtick',[])
set(gca,'ytick',[])
set(map,'alphadata',0)
 
cbar = colorbar;
customTick = [1,2,3,4,5];
customLabels = {"D0","D1","D2","D3","D4"};
cbar.Ticks = customTick;
cbar.TickLabels = customLabels;

end %function