function outputStruct = cutStruct3D(inputStruct,field,inputLat,inputLon,boundary)

inputMatrix = transformStructTo3DMatrix(inputStruct,field);
outputMatrix = cut3D(inputMatrix,inputLat,inputLon,boundary);
outputStruct = transformMatrix3DToStruct(outputMatrix,inputStruct,field);

end