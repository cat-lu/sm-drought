function [matrix,lat,lon] = cut(inputMatrix,inputLat,inputLon,boundary)

% Function that cuts down matrix to desired shapefile OR bounding box 

% INPUT: inputMatrix = array to cut (size: Nlat x Nlon)
%        inputLat = latitudes array for inputMatrix (size: Nlat x Nlon)
%        inputLon = longitudes array for inputMatrix (size: Nlat x Nlon)
%        boundary = shapefile OR bounding box [minlat,maxlat; minlon,maxlon]
% OUTPUT: Matrix = array in given boundary shape

% Check if input is shapefile or bounding box
if isa(boundary,'double')
    % Create bounding box from coordinates
    latbound = [boundary(1,1) boundary(1,1) boundary(1,2) boundary(1,2) boundary(1,1)]; 
    lonbound = [boundary(2,1) boundary(2,2) boundary(2,2) boundary(2,1) boundary(2,1)];
else
    assert(isa(boundary,'struct'),'Input is type %s, not structure array',class(boundary))
    assert(all(size(boundary)==[1,1]),'Specify one region in shapefile')
    shp = shaperead(boundary,'UseGeoCoords',true);
    latbound = shp.Lat;
    lonbound = shp.Lon;
end

% Find number of SMAP coordinates located inside or on boundary

% Returns indices in SMAP file which are inside lat and lon bound
insideBound = inpolygon(inputLon,inputLat,lonbound,latbound);
[rowInPoly,columnInPoly] = find(insideBound); % Indices of 1's (inside bound)

buffer = 0; % Adds buffer around country outline, default=10 can change size
rowIndexRange = min(rowInPoly)-buffer : max(rowInPoly)+buffer;
columnIndexRange = min(columnInPoly)-buffer : max(columnInPoly)+buffer;

insideBound = double(insideBound); % Change logical to double array for next step
insideBound(insideBound==false) = NaN; % Change zero (outside bound) into NaN

matrix = inputMatrix(rowIndexRange,columnIndexRange).*insideBound(rowIndexRange,columnIndexRange);
lat = inputLat(rowIndexRange,columnIndexRange);
lon = inputLon(rowIndexRange,columnIndexRange);

end