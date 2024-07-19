function [cutMatrix2D,lat,lon,insideBound,rowIndexRange,columnIndexRange] = cut2D(inputMatrix,inputLat,inputLon,boundary)

% Function that cuts down a 2D matrix to a desired shapefile OR bounding box 
% given this boundary, input 2D matrix and its corresponding coordinates
% (latitudes and longitudes)

% INPUT:  inputMatrix = 2D array to cut (size: Nlat x Nlon)
%         inputLat    = latitudes array for inputMatrix (size: Nlat x Nlon)
%         inputLon    = longitudes array for inputMatrix (size: Nlat x Nlon)
%         boundary    = shapefile (geographic data structure array)
%                       OR bounding box [minlat,maxlat; minlon,maxlon]
% OUTPUT: cutMatrix2D      = 2D array in given boundary shape
%         lat              = boundary's latitudes array based on inputLat
%         lon              = boundary's longitudes array based on inputLat
%         insideBound      = 2D array of NaNs and 1's with pixels inside
%                            boundary shown as 1, pixels outside boundary 
%                            shown as NaN (size: Nlat x Nlon)
%         rowIndexRange    = list of rows in inputMatrix within boundary
%         columnIndexRange = list of columns in inputMatrix within boundary

% Check if input is shapefile or bounding box
if isa(boundary,'double')
    % Create bounding box from coordinates
    latbound = [boundary(1,1) boundary(1,1) boundary(1,2) boundary(1,2) boundary(1,1)]; 
    lonbound = [boundary(2,1) boundary(2,2) boundary(2,2) boundary(2,1) boundary(2,1)];
else
    assert(isa(boundary,'struct'),'Input is type %s, not structure array with geographic data',class(boundary))
    % Retrieve coordinates from shapefile
    latbound = boundary.Lat;
    lonbound = boundary.Lon;
end

% Find SMAP coordinates located inside or on boundary

% Returns indices in SMAP file which are inside lat and lon bound
polygon = polyshape(lonbound,latbound); % Create polygon of boundary
% Separates polygon into separate regions if shapes are not connected
polygonRegions = regions(polygon); 
insideBound = zeros(size(inputLat)); % Initialize

for i = 1:height(polygonRegions) % Iterate over each region
    vertices = polygonRegions(i).Vertices;
    % Logical array if polygon vertices inside input
    tempBound = inpolygon(inputLon,inputLat,vertices(:,1),vertices(:,2));
    % Combine polygon regions into 1 logical array
    insideBound = max(insideBound,tempBound);
end

[rowInPoly,columnInPoly] = find(insideBound); % Indices of 1's (inside bound)

buffer = 0; % Optional: Adds buffer around country outline
% List of all relevant rows and columns (inside/on boundary)
rowIndexRange = min(rowInPoly)-buffer : max(rowInPoly)+buffer;
columnIndexRange = min(columnInPoly)-buffer : max(columnInPoly)+buffer;

insideBound = double(insideBound); % Change logical to double array for next step
insideBound(insideBound==false) = NaN; % Change zero (outside bound) into NaN

% Slice inputMatrix to only relevant rows/columns and multiply with logical 
% array to only keep data in boundary (Note: NaN multiplied by any value in 
% inputMatrix equals NaN, while 1 keeps value)
cutMatrix2D = inputMatrix(rowIndexRange,columnIndexRange).*insideBound(rowIndexRange,columnIndexRange);

% Slice SMAP latitude and longitude arrays to only relevant rows/columns
lat = inputLat(rowIndexRange,columnIndexRange);
lon = inputLon(rowIndexRange,columnIndexRange);

end