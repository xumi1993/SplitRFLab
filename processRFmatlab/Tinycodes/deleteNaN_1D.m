function newmatrix = deleteNaN_1D(matrix)

idx = isnan(matrix);
matrix(idx) = [];
newmatrix = matrix;
return