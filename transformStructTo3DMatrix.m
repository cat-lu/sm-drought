function matrix3D = transformStructTo3DMatrix(struct,field)

% Function that returns a 3D matrix combining all rows in struct array
% based on field
% INPUT: struct = 
%        field = 
% OUTPUT: matrix = 

matrixSize = [size(struct(1).(field)), length(struct)];
combinedArray = [struct.(field)];
matrix3D = reshape(combinedArray,matrixSize);

end
