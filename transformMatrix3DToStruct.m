function struct = transformMatrix3DToStruct(Matrix3D,struct,field)

% Function that returns existing structure array with new field and data
% determined by 3D Matrix
%
% INPUT: Matrix3D = 3D matrix which is added to struct in the third dim
%        struct = structure array to add 3D matrix to 
%        field = string array of fieldname to edit or add
% OUTPUT: struct = resulting struct with 3DMatrix added

for icount = 1:size(Matrix3D,3)
    struct(icount).(field) = Matrix3D(:,:,icount);
end

end

