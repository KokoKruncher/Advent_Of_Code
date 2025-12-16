clear; clc; close all;

allIdString = readlines("D02_Data.txt");
allIdString = allIdString(allIdString ~= "");

%% Part 1
% Perform checks in numbers world to ignore leading zeros
idRanges = split(allIdString, ",");
idRanges = str2double(split(idRanges, "-"));

ids = arrayfun(@(min, maxId) (min:maxId).', idRanges(:,1), idRanges(:,2), 'UniformOutput', false);
ids = vertcat(ids{:});

invalidIds1 = findIdsRepeatedTwice(ids);

fprintf("Sum of invalid IDs, part 1: %i\n", sum(invalidIds1))

%% Part 2
invalidIds2 = findIdsWithRepeatingSequence(ids);

fprintf("Sum of invalid IDs, part 2: %i\n", sum(invalidIds2))

%% Functions
function idsRepeatedTwice = findIdsRepeatedTwice(ids)
% Odd number of digits can't have twice repeated pattern
nDigits = floor(log10(ids) + 1);
isCandidate = isEven(nDigits);

ids = ids(isCandidate);
nDigits =  nDigits(isCandidate);

lastHalf = mod(ids, 10.^(nDigits/2));
firstHalf = (ids - lastHalf) ./ (10.^(nDigits/2));
isRepeatedTwice = firstHalf == lastHalf;

idsRepeatedTwice = ids(isRepeatedTwice);
end


function idsWithRepeatingSequence = findIdsWithRepeatingSequence(ids)
nDigits = floor(log10(ids) + 1);
isRepeatingSequence = false(size(ids));
nIds = numel(ids);

% hPool = parpool('Threads', 4);
for ii = 1:nIds
    isRepeatingSequence(ii) = isIdRepeatingSequence(ids(ii), nDigits(ii));
end
% hPool.delete();

idsWithRepeatingSequence = ids(isRepeatingSequence);
end


function bRepetitive = isIdRepeatingSequence(id, nDigits)
bRepetitive = true;

if nDigits < 2
    bRepetitive = false;
    return
end

nDigitsInGroup = allFactors(nDigits);

nGroupings = numel(nDigitsInGroup);
for ii = 1:nGroupings
    thisNumDigits = nDigitsInGroup(ii);

    firstDigitIndices = 1:thisNumDigits:nDigits;
    lastDigitIndices = firstDigitIndices + (thisNumDigits - 1);
    groupDigits = extractDigitsBetween(id, firstDigitIndices, lastDigitIndices, nDigits);

    if all(groupDigits == groupDigits(1))
        return
    end
end

bRepetitive = false;
end


function digits = extractDigitsBetween(num, firstIndices, lastIndices, nDigits)
% nDigits = floor(log10(num) + 1);
% 
% assert(all(firstIndices <= nDigits), "First index must be less than or equal to the number of digits.")
% assert(all(lastIndices <= nDigits), "Last index must be less than or equal to the number of digits.")
% assert(all(firstIndices <= lastIndices), "First index must be less than or equal to last index.")

digits = floor(mod(num, 10.^(nDigits + 1 - firstIndices)) ./ (10.^(nDigits - lastIndices))).';
end


function TF = isEven(n)
TF = mod(n, 2) == 0;
end


function factors = allFactors(n)
candidates = 1:floor(n ./ 2);
isFactor = mod(n, candidates) == 0;
factors = candidates(isFactor);
end