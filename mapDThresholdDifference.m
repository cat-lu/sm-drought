function mapDThresholdDifference(fig,DThresholds,month,lat,lon,outlineLat,outlineLon,threshold1Field,threshold2Field)

% Function that maps the difference in specified drought thresholds 
% (threshold1field minus threshold2field) for a given month and area 
% 
% INPUT: fig             = figure window for output
%        DThresholds     = structure array with fields Month, drought categories 
%                          (and subsequent SM values), a, and b (beta distribution 
%                          fitting parameters)
%        month           = month of interest (number with value 1-12)
%        lat             = latitude in area of interest (size: Nlat x Nlon)
%        lon             = longitude in area of interest (size: Nlat x Nlon)
%        outlineLat      = latitude of coast outline 
%        outlineLon      = longitude of coast outline
%        threshold1Field = string of 1st drought threshold name for comparison
%        threshold2Field = string of 2nd drought threshold name for comparison

% Create red white gradient colorbar to display drought threshold diff
red = [200, 0, 0]/256; white = [1,1,1];
redWhiteGradient = [linspace(white(1),red(1),500)', linspace(white(2),red(2),500)', linspace(white(3),red(3),500)'];

% Subtract threshold2 from threshold2 for difference array
D_diff = [DThresholds(month).(threshold1Field)]-[DThresholds(month).(threshold2Field)];

% Plot based on difference and coordinates
pcolor(lon,lat,D_diff);
hold on
shading flat
colormap(redWhiteGradient)

% Limit max of colorbar to 0.3 for more visible difference
clim([0 0.03])

% Plot boundary outline 
geoshow(outlineLat,outlineLon,'LineWidth',0.01,'Color','k') 

set(gca,'xtick',[]) % Remove x and y axis labels and ticks
set(gca,'ytick',[])

end