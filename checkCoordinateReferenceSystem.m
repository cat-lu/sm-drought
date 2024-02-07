function geoStruct = checkCoordinateReferenceSystem(filename,inputStruct)

% Function that checks if structure array is in geographic coordinate
% reference system (geocrs) and returns geographic data structure array

% INPUT: struct = structure array of shapefile
% OUTPUT: geoStruct = geographic data structure array (includes Lat and
%                     Lon)

info = shapeinfo(filename);
refSystem = info.CoordinateReferenceSystem;
geoStruct = inputStruct; % Initialize new array with same properties
if isa(refSystem,'projcrs')
    [lat,lon] = projinv(refSystem,inputStruct.Lon,inputStruct.Lat);
    geoStruct.Lat = lat;
    geoStruct.Lon = lon;
end