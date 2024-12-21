clear; clc;

%% Part 1
filename = "D7 Data.txt";
data = readlines(filename);
tic
% setup parallel pool for brute forcing this shit
nWorkers = 12;
if isempty(gcp('nocreate'))
    parpool(nWorkers);
end

[testValueArray,testNumbersArray] = formatData(data);

allowedOperators = ["*" "+"];
bSuccess = false(size(testValueArray));
nTestValues = numel(testValueArray);
parfor (iTestValue = 1:nTestValues,nWorkers)
    testValue = testValueArray(iTestValue);
    testNumbers = testNumbersArray{iTestValue};
    nTestNumbers = numel(testNumbers);
    nOperators = nTestNumbers - 1;

    operatorPermutations = getPermutations(allowedOperators,nOperators);

    nPermutations = height(operatorPermutations);
    for iPermutation = 1:nPermutations
        operators = operatorPermutations(iPermutation,:);
        evaluatedExpression = evaluateCustomOperators(testNumbers,operators,testValue);
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

%% Part 2

% only need to test equations that were not successful
newTestValueArray = testValueArray(~bSuccess);
newTestNumbersArray = testNumbersArray(~bSuccess);

% mpiprofile on
tic
newAllowedOperators = ["||" "*" "+"];
new_bSuccess = false(size(newTestValueArray));
nTestValues = numel(newTestValueArray);
parfor (iTestValue = 1:nTestValues,nWorkers)
    testValue = newTestValueArray(iTestValue);
    testNumbers = newTestNumbersArray{iTestValue};
    nTestNumbers = numel(testNumbers);
    nOperators = nTestNumbers - 1;

    operatorPermutations = getPermutations(newAllowedOperators,nOperators);

    % since permutations without "||" were already tested, only test
    % permutations with "||"
    indxContainsConcat = any(contains(operatorPermutations,"||"),2);
    operatorPermutations = operatorPermutations(indxContainsConcat,:);

    nPermutations = height(operatorPermutations);
    for iPermutation = 1:nPermutations
        operators = operatorPermutations(iPermutation,:);
        evaluatedExpression = evaluateCustomOperators(testNumbers,operators,testValue);
        if evaluatedExpression == testValue
            new_bSuccess(iTestValue) = true;
            break
        end
    end
end
toc
% delete(gcp('nocreate'))
% mpiprofile viewer

newSuccessfulCalibrationResults = newTestValueArray(new_bSuccess);
newTotalCalibrationResult = sum(newSuccessfulCalibrationResults,'all') + ...
                            totalCalibrationResult;
fprintf("New total calibration results: %i\n", newTotalCalibrationResult)



function permutationMatrix = getPermutations(operators,nPlaces)
arguments
    operators (:,1) {mustBeA(operators,["double", "string"])}
    nPlaces (1,1) double
end
nOperators = numel(operators);
nPermutations = nOperators^nPlaces;

% preallocate matrix
if class(operators) == "double"
    permutationMatrix = nan(nPermutations,nPlaces);
elseif class(operators) == "string"
    permutationMatrix = strings(nPermutations,nPlaces);
else
    error("Elements are of an unsupported class. Pick either double or string.")
end

for iCol = 1:nPlaces
    nRepElem = nOperators^(nPlaces - iCol);
    nRepMat = nOperators^(iCol-1);
    permutationMatrix(:,iCol) = repmat(repelem(operators,nRepElem), nRepMat, 1);
end
end



function [testValueArray,testNumbersArray] = formatData(data)
dataCell = mat2cell(data,ones(size(data)));

% use loop because cellfun treats string arrays like cells of character
% vectors for compatibility which complicates things.
nRows = numel(data);
testValueArray = nan(nRows,1);
testNumbersArray = cell(nRows,1);
for iRow = 1:nRows
    fullString = dataCell{iRow};
    fullStringSplitted = split(fullString,[": "," "]);
    testValueArray(iRow) = str2double(fullStringSplitted(1));
    testNumbersArray{iRow} = str2double(fullStringSplitted(2:end)');
end

end



function evaluatedExpression = evaluateCustomOperators(testNumbers,operators,testValue)
% evaluated the expression from left to right, including the custom
% operator "||" which concatenates two numbers into one
arguments
    testNumbers (1,:) double
    operators (1,:) string
    testValue (1,1) double
end
% testNumbers = str2double(testNumbers);

nOperators = numel(operators);
currentValue = testNumbers(1);
for iOperator = 1:nOperators
    nextNumber = testNumbers(iOperator + 1);

    % performance bottleneck is extracting string from string array, changing operators to
    % be represented by numbers would be faster.
    currentOperator = operators(iOperator);
    
    % if-else in this case ~20x faster than switch-case
    if currentOperator == "||"
        % concatenate numbers
        nDigitsToAdd = floor(log10(nextNumber))+1;
        currentValue = currentValue*(10^nDigitsToAdd) + nextNumber;
    elseif currentOperator == "+"
        currentValue = currentValue + nextNumber;
    elseif currentOperator == "*"
        currentValue = currentValue*nextNumber;
    else
        error("Unknown operator: %s",currentOperator)
    end
    
    % all operations increase the value of currentValue, so if overshot, already failed
    if currentValue > testValue
        break
    end
end
evaluatedExpression = currentValue;
end