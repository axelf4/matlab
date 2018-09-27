function [output] = SymmetricMatrix(A)
%SYMMETRICMATRIX Returns whether the matrix is symmetrical
%   Detailed explanation goes here
output = isequal(A, A');
end

