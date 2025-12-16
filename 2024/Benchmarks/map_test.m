% To compare speeds of accessing data using regular arrays, containers.Map and
% dictionaries. Both without and with converting of indices

clear; clc;

nRows = 50;
nCols = 50;
nElements = nRows*nCols;

logicalArray = false(nRows,nCols);
logicalArray(1:2:nElements) = true;

map = containers.Map(1:nElements,logicalArray(:));
d = dictionary(1:nElements,logicalArray(:)');

indxArray = repmat(1:nElements,1,1e2);

%% Linear indx
fprintf("Linear indx, no conversion.\n\n")

disp("Logical array:")
tic
for indx = indxArray
    a = logicalArray(indx);
end
toc


disp("Map:")
tic
for indx = indxArray
    a = map(indx);
end
toc

disp("Dictionary:")
tic
for indx = indxArray
    a = d(indx);
end
toc

%% With conversion
matrixSize = size(logicalArray);


fprintf("\nWith conversion:\n\n")

disp("Logical array:")
tic
for indx = indxArray
    [row,col] = ind2sub(matrixSize,indx);
    a = logicalArray(row,col);
end
toc

[rows,cols] = ind2sub(matrixSize,indxArray);
nIndxArrayElements = numel(indxArray);
disp("Map:")
tic
for iLinearIndx = 1:nIndxArrayElements
    row = rows(iLinearIndx);
    col = cols(iLinearIndx);
    linearIndx = sub2ind(matrixSize,row,col);
    a = map(indx);
end
toc

disp("Dictionary:")
tic
for iLinearIndx = 1:nIndxArrayElements
    row = rows(iLinearIndx);
    col = cols(iLinearIndx);
    linearIndx = sub2ind(matrixSize,row,col);
    a = d(indx);
end
toc

%% isKey

fprintf("\nisKey:\n\n")

n = 1e6;

disp("Map:")
tic
for i = 1:n
    TF = map.isKey(i);
end
toc

disp("Dictionary:")
tic
for i = 1:n
    TF = d.isKey(i);
end
toc