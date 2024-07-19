function outputStruct = cutStruct3D(inputStruct,field,inputLat,inputLon,boundary)

% Function that cuts down a structure array based on a desired shapefile 
% OR bounding box, input 2D matrix and its corresponding coordinates
% (latitudes and longitudes)

% INPUT:  inputStruct = 2D array to cut (size: Nlat x Nlon)
%         field       = string array for structure array fieldname
%         inputLat    = latitudes array for matrix from struct (size: Nlat x Nlon)
%         inputLon    = longitudes array for matrix from struct (size: Nlat x Nlon)
%         boundary    = shapefile (geographic data structure array)
%                       OR bounding box [minlat,maxlat; minlon,maxlon]
% OUTPUT: outputStruct = resulting structure array in given boundary shape

% Get 3D matrix from structure array
inputMatrix = transformStructTo3DMatrix(inputStruct,field);
% Cut 3D matrix based on boundary
outputMatrix = cut3D(inputMatrix,inputLat,inputLon,boundary);
% Transform back into structure array
outputStruct = transformMatrix3DToStruct(outputMatrix,inputStruct,field);

end