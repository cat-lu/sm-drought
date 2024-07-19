function [cutMatrix3D,lat,lon] = cut3D(inputMatrix,inputLat,inputLon,boundary)

% Function that cuts down a 3D matrix to desired shapefile OR bounding box
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

% Use existing logical array (insideBound) for 3D boundary
[cutMatrix2D,lat,lon,insideBound,rowIndexRange,columnIndexRange] = cut2D(inputMatrix(:,:,1),inputLat,inputLon,boundary);
Ndate = size(inputMatrix,3);
[Nlat,Nlon] = size(cutMatrix2D);
cutMatrix3D = NaN(Nlat,Nlon,Ndate); % Initialize

% Assumes each day has same coordinates, cut based on lat-lon coordinates
for i = 1:Ndate
    dateMatrix = inputMatrix(rowIndexRange,columnIndexRange,i).*insideBound(rowIndexRange,columnIndexRange);
    cutMatrix3D(:,:,i) = dateMatrix;
end % Ndates

end
