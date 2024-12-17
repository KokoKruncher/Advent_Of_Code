clear; clc;

%% Part 1
filename = "D7 Data.txt";
data = readlines(filename);

[testValueArray,testElementsArray] = formatData(data);

tic
allowedOperators = ["*" "+"];
bSuccess = false(size(testValueArray));
nTestValues = numel(testValueArray);
for iTestValue = 1:nTestValues
    testValue = testValueArray(iTestValue);
    testElements = testElementsArray{iTestValue};
    nTestElements = numel(testElements);
    nOperators = nTestElements - 1;

    operatorPermutations = getPermutations(allowedOperators,nOperators);

    nPermutations = height(operatorPermutations);
    for iPermutation = 1:nPermutations
        operators = operatorPermutations(iPermutation,:);
        operatorsPadded = [operators, ""];
        
        expression = createExpression(testElements,operators);
        evaluatedExpression = eval(expression);
        
        if evaluatedExpression == testValue
            bSuccess(iTestValue) = true;
            break
        end
    end
end
toc

successfulCalibrationResults = testValueArray(bSuccess);
totalCalibrationResult = sum(successfulCalibrationResults,'all');
fprintf("Total calibration results: %i\n", totalCalibrationResult)



function permutationMatrix = getPermutations(elements,nPlaces)
arguments
    elements (:,1) {mustBeA(elements,["double", "string"])}
    nPlaces (1,1) double
end
nElements = numel(elements);
nPermutations = nElements^nPlaces;

% preallocate matrix
if class(elements) == "double"
    permutationMatrix = nan(nPermutations,nPlaces);
elseif class(elements) == "string"
    permutationMatrix = strings(nPermutations,nPlaces);
else
    error("Elements are of an unsupported class. Pick either double or string.")
end

for iCol = 1:nPlaces
    nRepElem = nElements^(nPlaces - iCol);
    nRepMat = nElements^(iCol-1);
    permutationMatrix(:,iCol) = repmat(repelem(elements,nRepElem), nRepMat, 1);
end
end



function [testValueArray,testElementsArray] = formatData(data)
dataCell = mat2cell(data,ones(size(data)));

% use loop because cellfun treats string arrays like cells of character
% vectors for compatibility which complicates things.
nRows = numel(data);
testValueArray = nan(nRows,1);
testElementsArray = cell(nRows,1);
for iRow = 1:nRows
    fullString = dataCell{iRow};
    fullStringSplitted = split(fullString,[": "," "]);
    testValueArray(iRow) = str2double(fullStringSplitted(1));
    testElementsArray{iRow} = fullStringSplitted(2:end)';
end
end



function expression = createExpression(elements,operators)
arguments
    elements (1,:) {mustBeA(elements,"string")}
    operators (1,:) {mustBeA(operators,"string")}
end
assert(numel(elements) == numel(operators) + 1,"Elements must be 1 more than operators")

% operations done left to right ignoring BODMAS
% so, put a bracker after each element as well as all the required brackets
% before 1st element
elements = elements + ")";
nElements = numel(elements);
openingBrackets = join(repmat("(",1,nElements),"");
elements(1) = openingBrackets + elements(1);

operatorsPadded = [operators ""];
tmp = [elements', operatorsPadded'];
tmp = tmp';
tmp = tmp(:);
expression = join(tmp(1:end-1),"");
end