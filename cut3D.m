function [cutMatrix3D,lat,lon] = cut3D(inputMatrix,inputLat,inputLon,boundary)

% Function that cuts down 3D matrix to desired shapefile OR bounding box 

% INPUT: inputMatrix = array to cut (size: Nlat x Nlon x Ndate)
%        inputLat = latitudes array for inputMatrix (size: Nlat x Nlon)
%        inputLon = longitudes array for inputMatrix (size: Nlat x Nlon)
%        boundary = shapefile (geographic data structure array)
%                   OR bounding box [minlat,maxlat; minlon,maxlon]
% OUTPUT: Matrix = array in given boundary shape

% Initialize array using input dates and coordinates from first date
%[Nlat,Nlon] = size(cut2D(inputMatrix(:,:,1),inputLat,inputLon,boundary));
[cutMatrix2D,lat,lon,insideBound,rowIndexRange,columnIndexRange] = cut2D(inputMatrix(:,:,1),inputLat,inputLon,boundary);
Ndate = size(inputMatrix,3);
[Nlat,Nlon] = size(cutMatrix2D);
cutMatrix3D = NaN(Nlat,Nlon,Ndate);

% Assumes each day has same coordinates, cut based on lat-lon coordinates
for i = 1:Ndate
    %[dateMatrix,lat,lon] = cut2D(inputMatrix(:,:,i),inputLat,inputLon,boundary);
    dateMatrix = inputMatrix(rowIndexRange,columnIndexRange,i).*insideBound(rowIndexRange,columnIndexRange);
    cutMatrix3D(:,:,i) = dateMatrix;
end % Ndates

end
