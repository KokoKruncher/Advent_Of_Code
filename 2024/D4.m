clear; clc;

%% Part 1
filename = "D4 Data.txt";
data = fileread(filename);
dataMatrix = formatDataIntoMatrix(data);
wordToFind = "XMAS";

% search all diagonals
diagonalsDirection1 = extractDiagonalStrings(dataMatrix); % south-east
diagonalsDirection2 = extractDiagonalStrings(flipud(dataMatrix)); % north-east
diagonalStrings = [diagonalsDirection1; diagonalsDirection2];

nDiagonals = numel(diagonalStrings);
nAppearancesDiagonals = countBothOrders(diagonalStrings,wordToFind);
fprintf("Diagonals: %i\n",nAppearancesDiagonals)

% search all rows
rowStrings = join(dataMatrix,"");
nAppearancesRows = countBothOrders(rowStrings,wordToFind);
fprintf("Rows: %i\n",nAppearancesRows)

% search all cols
colStrings = join(dataMatrix',"");
nAppearancesCols = countBothOrders(colStrings,wordToFind);
fprintf("Cols: %i\n",nAppearancesCols)

% add all appearances
nAppearances = nAppearancesDiagonals + nAppearancesRows + nAppearancesCols;
fprintf("Total appearances of '%s': %i\n\n",wordToFind,nAppearances)

%% Part 2
nElements = numel(dataMatrix);
matrixSize = size(dataMatrix);
assert(numel(matrixSize) == 2,"Must be 2D matrix.")
matrixHeight = matrixSize(1);
matrixWidth = matrixSize(2);

subMatrixHeight = 3;
subMatrixWidth = 3;
nX_MAS = 0;
for i = 1:nElements % top left element of sub-matrix
    [rowIndx,colIndx] = ind2sub(matrixSize,i);
    if rowIndx > (matrixHeight - subMatrixHeight + 1)
        continue
    end
    
    if colIndx > (matrixWidth - subMatrixWidth + 1)
        continue
    end
    
    subMatrixRowIndx = rowIndx:(rowIndx + subMatrixHeight - 1);
    subMatrixColIndx = colIndx:(colIndx + subMatrixWidth - 1);
    subMatrix = dataMatrix(subMatrixRowIndx,subMatrixColIndx);
    
    isX_MAS = checkForX_MAS(subMatrix);
    if isX_MAS
        nX_MAS = nX_MAS + 1;
    end
end
fprintf("Number of MAS in X shape: %i\n",nX_MAS)


    
function dataMatrix = formatDataIntoMatrix(data)
data = string(data);

% split the data by newline into column vector
dataColumnVec = split(data,newline);

% errase carriage return at end of each cell
dataColumnVec = erase(dataColumnVec,string(char(13)));

% split all vectors to form one matrix of one character in each cell
dataMatrix = split(dataColumnVec,"");

% remove empty columns either side
dataMatrix(:,1) = []; dataMatrix(:,end) = [];
end



function nAppearances = countBothOrders(string,wordToCount)
% returns the amount of times a word occurs in a string array in both
% forwards and reverse direction
stringReverse = reverse(string);
nForwards = count(string,wordToCount);
nReverse = count(stringReverse,wordToCount);
nAppearances = sum(nForwards,'all') + sum(nReverse,"all");
end



function diagonalStringsArray = extractDiagonalStrings(dataMatrix)
% extracts all strings going south-east in the matrix
matrixSize = size(dataMatrix);
assert(numel(matrixSize) == 2,"Must be 2D matrix.")
nElements = numel(dataMatrix);

allLinearIndx = reshape(1:nElements,matrixSize);
nDiagonals = sum(matrixSize,'all') - 1;
diagonalStringsArray = strings(nDiagonals,1);

kDiagonalArray = -matrixSize(1)+1:1:matrixSize(2)-1;
for i = 1:nDiagonals
    kDiagonal = kDiagonalArray(i);
    diagonalLinearIdx = diag(allLinearIndx,kDiagonal);
    diagonalString = join(dataMatrix(diagonalLinearIdx),"");
    diagonalStringsArray(i) = diagonalString;
end
end



function isX_MAS = checkForX_MAS(mat)
arguments
    mat (3,3) string
end
matrixSize = size(mat);
nElements = numel(mat);
allLinearIndx = reshape(1:nElements,matrixSize);
diag1 = mat(diag(allLinearIndx)); % south-east diagonal
diag2 = mat(diag(flipud(allLinearIndx))); % north-east diagonal

stringDiag1 = join(diag1,"");
stringDiag2 = join(diag2,"");

is_MAS_diag1 = countBothOrders(stringDiag1,"MAS") == 1;
is_MAS_diag2 = countBothOrders(stringDiag2,"MAS") == 1;
isX_MAS = is_MAS_diag1 && is_MAS_diag2;
end