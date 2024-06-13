%% Beta Parameterization Plot
clear; clc
load('output/SM_Africa_shapefile.mat','coordsAfrica')
load('output/avgSM_Africa_8day.mat', 'avgSM_Africa');
load('output/DThresholdsAfrica_8daySurface.mat','D_AfricaSurface')
load('output/porosityAfrica.mat')
%% Cut and combine daily soil moisture files using Africa shapefile
worldFile = 'input\World_Continents\World_Continents.shp';
world = shaperead(worldFile,'UseGeoCoords',true);
row = find(strcmp({world.CONTINENT},'Africa')==1); %Find row exclusive to Africa
shapeAfrica = world(row);
geoAfrica = checkCoordinateReferenceSystem(worldFile,shapeAfrica); %Return geocrs if not already
%% 
% Choose lat-lon coordinates
a_param = transformStructTo3DMatrix(D_AfricaSurface,'a'); 
b_param = transformStructTo3DMatrix(D_AfricaSurface,'b');
SM_matrix = transformStructTo3DMatrix(avgSM_Africa,'SM');
lat = coordsAfrica.Lat; lon = coordsAfrica.Lon;

ilat = 500;
ilon = 600;
imonth = 8;
[~, centerMonth] = ymd([avgSM_Africa.centerDate]); % Find month of center dates
monthIndex = find(centerMonth == imonth);
x = squeeze(SM_matrix(ilat,ilon,monthIndex))./porosityAfrica(ilat,ilon);
x2 = linspace(0,0.6,50);
y = betapdf(x2,a_param(ilat,ilon,imonth),b_param(ilat,ilon,imonth));
example1 = betapdf(x2,a_param(ilat,ilon,1),b_param(ilat,ilon,1));
example2 = betapdf(x2,a_param(ilat,ilon,4),b_param(ilat,ilon,4));
example3 = betapdf(x2,a_param(ilat,ilon,7),b_param(ilat,ilon,7));
example4 = betapdf(x2,a_param(ilat,ilon,10),b_param(ilat,ilon,10));

figure('Position',[100 200 700 500])
plot(x2,y,'LineWidth',3,'DisplayName','Beta distribution fit'); hold on
histogram(x,15,'Normalization','pdf','DisplayName','Soil moisture histogram'); hold on
% plot(x2,example1,'LineWidth',1,'LineStyle','--','DisplayName','Example Beta distribution: January'); hold on
% plot(x2,example2,'LineWidth',1,'LineStyle','--','DisplayName','Example Beta distribution: April'); hold on
% plot(x2,example3,'LineWidth',1,'LineStyle','--','DisplayName','Example Beta distribution: July'); hold on
% plot(x2,example4,'LineWidth',1,'LineStyle','--','DisplayName','Example Beta distribution: October'); hold on
plot(x2,example1,'LineWidth',1,'LineStyle','--','HandleVisibility','off'); hold on
plot(x2,example2,'LineWidth',1,'LineStyle','--','HandleVisibility','off'); hold on
plot(x2,example3,'LineWidth',1,'LineStyle','--','HandleVisibility','off'); hold on
plot(x2,example4,'LineWidth',1,'LineStyle','--','HandleVisibility','off'); hold on
xlim([0 0.6])
xlabel('Soil Moisture (m^3/m^3)')
ylabel('Probability Density')
pointLabel = ['(August, coord: [',num2str(lat(ilat,ilon)),', ',num2str(lon(ilat,ilon)),'])'];
title('Beta Distribution PDF',['Month of August at [',num2str(lat(ilat,ilon)),', ',num2str(lon(ilat,ilon)),']',])
legend('Location','northeast')
hold off
%% location of plot
figure(2) 
ilat = 300; ilon = 250;
geoshow(geoAfrica,'FaceColor','green','FaceAlpha',0.1); hold on
scatter(coordsAfrica.Lon(ilat,ilon),coordsAfrica.Lat(ilat,ilon),50,'filled')
xlim([-30 65])
grid('minor')
xlabel('Longitude (deg)')
ylabel('Latitude (deg)')
%% Plot of drought thresholds
figure(3)
% ilat = 500; ilon = 600;
ilat = 300; ilon = 250;
months = 1:12;
hex = ["#e6ddd5","#ffff00","#fcd37f","#ffaa00","#e60000","#730000"];
DNames = ["Median","D0","D1","D2","D3","D4"];
for D = 1:length(DNames)
    D_matrix = transformStructTo3DMatrix(D_AfricaSurface,DNames(D));
    if D == 1
        plot(squeeze(D_matrix(ilat,ilon,:)),'DisplayName','Median Soil Moisture','Color',hex(1),'LineWidth',3); hold on
    else
        area(squeeze(D_matrix(ilat,ilon,:)),'DisplayName',DNames(D),'FaceColor',hex(D),'EdgeColor',hex(D)); hold on
    end
end
% plot(squeeze(D_AfricaSurface(ilat,ilon,:,1)),'DisplayName','Median Soil Moisture','Color',hex(1),'LineWidth',3); hold on
% area(squeeze(D_AfricaSurface(ilat,ilon,:,2)),'DisplayName','D0','FaceColor',hex(2),'EdgeColor',hex(2)); hold on
% area(squeeze(D_AfricaSurface(ilat,ilon,:,3)),'DisplayName','D1','FaceColor',hex(3),'EdgeColor',hex(3)); hold on
% area(squeeze(D_AfricaSurface(ilat,ilon,:,4)),'DisplayName','D2','FaceColor',hex(4),'EdgeColor',hex(4)); hold on
% area(squeeze(D_AfricaSurface(ilat,ilon,:,5)),'DisplayName','D3','FaceColor',hex(5),'EdgeColor',hex(5)); hold on
% area(squeeze(D_AfricaSurface(ilat,ilon,:,6)),'DisplayName','D4','FaceColor',hex(6),'EdgeColor',hex(6)); hold off
set(gca,'xtick',1:12,'xticklabel',{'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'})
legend('Location','northwest','FontSize',10,'Box','off','Direction','normal')
ylabel('Soil moisture (m^3/m^3)')
xlabel('Month')
title('Drought Thresholds',['Location: (',num2str(coordsAfrica.Lat(ilat,ilon)),', ',num2str(coordsAfrica.Lon(ilat,ilon)),')',])
ylim([0 0.3])
xlim([1 12])
