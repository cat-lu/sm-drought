function matrix3D = transformStructTo3DMatrix(struct,field)

% Function that returns a 3D matrix combining all rows in structure array
% based on field
% INPUT:  struct   = structure array to build 3D matrix from
%         field    = string array of relevant field
% OUTPUT: matrix3D = 3D matrix combining elements in struct based on field

% Combine all elements in field's structure array into list
matrixSize = [size(struct(1).(field)), length(struct)];
combinedArray = [struct.(field)];
matrix3D = reshape(combinedArray,matrixSize); % Reshape into final 3D matrix

end
