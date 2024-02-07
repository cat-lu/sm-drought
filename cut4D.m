function [cutMatrix4D,lat,lon] = cut4D(inputMatrix,inputLat,inputLon,boundary)

% Function that cuts down 4d matrix to desired shapefile OR bounding box 

% INPUT: inputMatrix = array to cut (size: Nlat x Nlon x Ndate x Ngroup)
%        inputLat = latitudes array for inputMatrix (size: Nlat x Nlon)
%        inputLon = longitudes array for inputMatrix (size: Nlat x Nlon)
%        boundary = shapefile (geographic data structure array)
%                   OR bounding box [minlat,maxlat; minlon,maxlon]
% OUTPUT: Matrix = array in given boundary shape

% Initialize array using first group
[Nlat,Nlon,Ndate] = size(cut3D(inputMatrix(:,:,:,1),inputLat,inputLon,boundary));
Ngroups = size(inputMatrix,4);
cutMatrix4D = NaN(Nlat,Nlon,Ndate,Ngroups);

for i = 1:Ngroups
    [groupMatrix,lat,lon] = cut3D(inputMatrix,inputLat,inputLon,boundary);
    cutMatrix4D(:,:,:,i) = groupMatrix;
end %Ngroups

end