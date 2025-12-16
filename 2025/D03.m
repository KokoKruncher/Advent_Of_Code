clear; clc; close all;

joltages = readlines("D03_Data.txt");
joltages = joltages(joltages ~= "");
joltages = str2double(num2cell(char(joltages)));

%% Part 1
maxJoltages1 = findMaxJoltage(joltages, 2);
outputJoltage1 = sum(maxJoltages1);
fprintf("Output Joltage, part 1 = %i\n", outputJoltage1);

%% Part 2
maxJoltages2 = findMaxJoltage(joltages, 12);
outputJoltage2 = sum(maxJoltages2);
fprintf("Output Joltage, part 2 = %i\n", outputJoltage2);

%% Functions
function maxJoltages = findMaxJoltage(joltages, nDigits)
assert(nDigits <= width(joltages), "Number of digits in output joltage cannot exceed number of joltage array columns.");
nRows = height(joltages);
maxJoltages = nan(nRows, nDigits);

remainingDigits = joltages;
for iDigit = 1:nDigits-1
    nColumnsToSave = nDigits - (iDigit - 1) - 1;
    [theseDigits, iTheseDigits] = max(remainingDigits(:,1:end-(nColumnsToSave)), [], 2, "omitnan");
    maxJoltages(:, iDigit) = theseDigits;

    for iRow = 1:nRows
        remainingDigits(iRow, 1:iTheseDigits(iRow)) = nan;
    end
end
maxJoltages(:, end) = max(remainingDigits, [], 2, "omitnan");

maxJoltages = sum(maxJoltages .* 10.^(nDigits-1:-1:0), 2);
end