clear; clc; close all;

problems = readlines("D06_Data.txt");
problems = problems(problems ~= "");
problems = strip(problems);
problems = split(problems);

numbers = str2double(problems(1:end-1,:));
operators = problems(end,:);

%% Part 1
nProblems = width(problems);
results1 = nan(1, nProblems);

for ii = 1:nProblems
    thisOperator = operators(ii);
    switch thisOperator
        case "+"
            results1(ii) = sum(numbers(:,ii));
        case "*"
            results1(ii) = prod(numbers(:,ii));
        otherwise
            error("Unknown operator: %s", thisOperator);
    end
end

grandTotal1 = sum(results1);
fprintf("Grand total, part 1 = %i\n", grandTotal1);

%% Part 2
txt = readlines("D06_Data.txt");
txt = txt(txt ~= "");
txt = convertStringsToChars(txt);

numbers = txt(1:end-1);
numbers = vertcat(numbers{:});
operators = split(strip(convertCharsToStrings(txt(end))));
nProblems = numel(operators);

isSpace = numbers == ' ';
isSeparator = all(isSpace, 1);
iSeparator = find(isSeparator).';
assert(numel(iSeparator) == (nProblems - 1));

iSplit = [[1; iSeparator+1], [iSeparator-1; numel(isSeparator)]];
assert(height(iSplit) == nProblems);
splitNumbers = cell(nProblems, 1);

nRows = height(numbers);
for ii = 1:nProblems
    rawNumbersArray = numbers(1:nRows, iSplit(ii,1):iSplit(ii,2));
    rawNumbersArray = str2double(num2cell(rawNumbersArray));

    nNumbers = width(rawNumbersArray);
    parsedNumbers = nan(nNumbers, 1);
    for jj = nNumbers:-1:1
        thisColumn = rawNumbersArray(:,jj);
        thisColumn = thisColumn(~isnan(thisColumn));
        nDigits = numel(thisColumn);
        thisColumn = thisColumn .* (10 .^ ((nDigits - 1):-1:0)).';
        thisColumn = sum(thisColumn);

        parsedNumbers(jj) = thisColumn;
    end
    splitNumbers{ii} = parsedNumbers(end:-1:1);
end

results2 = nan(1, nProblems);
for ii = 1:nProblems
    thisOperator = operators(ii);
    switch thisOperator
        case "+"
            results2(ii) = sum(splitNumbers{ii});
        case "*"
            results2(ii) = prod(splitNumbers{ii});
        otherwise
            error("Unknown operator: %s", thisOperator);
    end
end

grandTotal2 = sum(results2);
fprintf("Grand total, part 2 = %i\n", grandTotal2);