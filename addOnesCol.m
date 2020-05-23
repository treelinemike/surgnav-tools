% add produce an augmented matrix by adding a column of ones
% this takes standard coordinates and makes them homogeneous coordinates

function hCoords = addOnesCol( inputMatrix )
    hCoords = [inputMatrix ones(size(inputMatrix,1),1)];
end