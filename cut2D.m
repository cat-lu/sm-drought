function [cutMatrix2D,lat,lon,insideBound,rowIndexRange,columnIndexRange] = cut2D(inputMatrix,inputLat,inputLon,boundary)

% Function that cuts down 2D matrix to desired shapefile OR bounding box 

% INPUT: inputMatrix = array to cut (size: Nlat x Nlon)
%        inputLat = latitudes array for inputMatrix (size: Nlat x Nlon)
%        inputLon = longitudes array for inputMatrix (size: Nlat x Nlon)
%        boundary = shapefile (geographic data structure array)
%                   OR bounding box [minlat,maxlat; minlon,maxlon]
% OUTPUT: Matrix = array in given boundary shape

% Check if input is shapefile or bounding box
if isa(boundary,'double')
    % Create bounding box from coordinates
    latbound = [boundary(1,1) boundary(1,1) boundary(1,2) boundary(1,2) boundary(1,1)]; 
    lonbound = [boundary(2,1) boundary(2,2) boundary(2,2) boundary(2,1) boundary(2,1)];
else
    assert(isa(boundary,'struct'),'Input is type %s, not structure array with geographic data',class(boundary))
    latbound = boundary.Lat;
    lonbound = boundary.Lon;
end

% Find number of SMAP coordinates located inside or on boundary

% Returns indices in SMAP file which are inside lat and lon bound
%insideBound = inpolygon(inputLon,inputLat,lonbound,latbound);
% Faster way of inpolygon?
polygon = polyshape(lonbound,latbound);
polygonRegions = regions(polygon);
insideBound = zeros(size(inputLat));
for i = 1:height(polygonRegions) % Iterate over each polygon
    vertices = polygonRegions(i).Vertices;
    tempBound = inpolygon(inputLon,inputLat,vertices(:,1),vertices(:,2));
    insideBound = max(insideBound,tempBound);
end

[rowInPoly,columnInPoly] = find(insideBound); % Indices of 1's (inside bound)

buffer = 0; % Adds buffer around country outline, default=10 can change size
rowIndexRange = min(rowInPoly)-buffer : max(rowInPoly)+buffer;
columnIndexRange = min(columnInPoly)-buffer : max(columnInPoly)+buffer;

insideBound = double(insideBound); % Change logical to double array for next step
insideBound(insideBound==false) = NaN; % Change zero (outside bound) into NaN

cutMatrix2D = inputMatrix(rowIndexRange,columnIndexRange).*insideBound(rowIndexRange,columnIndexRange);
lat = inputLat(rowIndexRange,columnIndexRange);
lon = inputLon(rowIndexRange,columnIndexRange);

end