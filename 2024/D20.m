clear; clc; close all;

map = readlines("D20 Data.txt");
map = map(map ~= "");
map = char(map);

%% Part 1
[originalTime, pathPositions, timeLeft, skips] = calculateTimeSaved(map);

skips = skips.entries();
skips = renamevars(skips, "Key", "StartEndPositions");
skips = renamevars(skips, "Value", "TimeSaved");

tabulate(skips.TimeSaved(skips.TimeSaved >= 0));

nSkipsSaving100 = nnz(skips.TimeSaved >= 100);
fprintf("Number of skips saving at least 100 picoseconds = %i\n", nSkipsSaving100);

%% Functions
function [originalTime, pathPositions, timeLeft, timeSaved] = calculateTimeSaved(map)
START = 'S';
END = 'E';
PATH = '.';
DIRECTIONS = [-1, 0;
    0, 1;
    1, 0;
    0, -1];
N_DIRECTIONS = height(DIRECTIONS);

%% Initial pass
% Time taken to go from '.' to 'E' is also 1 picosecond, so +1
originalTime = nnz(map == '.') + 1;

mapSize = size(map);
[startPosition(1), startPosition(2)] = ind2sub(mapSize, find(map == START));
[~, ~, startDirectionIndex] = getNext(startPosition);

pathPositions = nan(originalTime + 1, 2);
pathPositions(1,:) = startPosition;
pathDirectionIndices = nan(originalTime + 1, 1);
pathDirectionIndices(1) = startDirectionIndex;
timeLeft = dictionary();
timeLeft({startPosition}) = originalTime;
currentPosition = startPosition;
currentDirectionIndex = startDirectionIndex;
time = 0;
while true
    time = time + 1;
    [nextPosition, nextLetter, nextDirectionIndex] = getNext(currentPosition, currentDirectionIndex);

    pathPositions(time + 1, :) = nextPosition;
    pathDirectionIndices(time + 1, :) = nextDirectionIndex;
    timeLeft({nextPosition}) = originalTime - time;

    if nextLetter == END
        break
    end

    currentPosition = nextPosition;
    currentDirectionIndex = nextDirectionIndex;
end

%% Skipping
N_SKIPS = 2;

% Relative to previous skip/step
% Not worth skipping backwards unless it's at the start
RELATIVE_SKIP_DIRECTION_INDICES = createCombinationsNTimes([-1, 0, 1], N_SKIPS);
RELATIVE_SKIP_DIRECTION_INDICES_START = createCombinationsNTimes([-1, 0, 1, 2], N_SKIPS);
timeSaved = dictionary();
for ii = 1:height(pathPositions)
    skipStartPosition = pathPositions(ii,:);
    skipStartDirectionIndex = pathDirectionIndices(ii,:);
    
    if ii ~= 1
        skipDirectionIndices = RELATIVE_SKIP_DIRECTION_INDICES;
    else
        skipDirectionIndices = RELATIVE_SKIP_DIRECTION_INDICES_START;
    end

    skipDirectionIndices = cumsum(skipDirectionIndices, 2); % relative to skipStartDirectionIndex
    skipDirectionIndices = skipStartDirectionIndex + skipDirectionIndices; % absolute direction index
    skipDirectionIndices = makeInRange(skipDirectionIndices);
    
    nCombinations = height(skipDirectionIndices);
    for iCombination = 1:nCombinations
        skipEndPosition = skipStartPosition + sum(DIRECTIONS(skipDirectionIndices(iCombination,:), :), 1);

        if ~timeLeft.isKey({skipEndPosition})
            continue
        end

        timeSaved({[skipStartPosition; skipEndPosition]}) ...
            = timeLeft({skipStartPosition}) - timeLeft({skipEndPosition}) - N_SKIPS;
    end
end

%% Nested functions
    function [nextPosition, nextLetter, directionIndex] = getNext(position, currentDirectionIndex)
        if nargin > 1
            % LEFT, STRAIGHT, RIGHT
            directionIndex = currentDirectionIndex + [-1; 0; 1];
        else
            % ALL 4 DIRECTIONS
            directionIndex = (0:3).';
        end

        directionIndex = makeInRange(directionIndex);
        possibleNextPositions = position + DIRECTIONS(directionIndex,:);

        isNextInBounds = isInBounds(possibleNextPositions);
        possibleNextPositions = possibleNextPositions(isNextInBounds,:);
        directionIndex = directionIndex(isNextInBounds);

        possibleNextLetters = getLetters(possibleNextPositions);
        isNext = possibleNextLetters == PATH | possibleNextLetters == END;

        assert(nnz(isNext) == 1);
        nextPosition = possibleNextPositions(isNext,:);
        directionIndex = directionIndex(isNext);
        nextLetter = possibleNextLetters(isNext);
    end


    function directionIndex = makeInRange(directionIndex)
        directionIndex = 1 + mod(directionIndex - 1, N_DIRECTIONS);
    end


    function tf = isInBounds(positions)
        rows = positions(:,1);
        cols = positions(:,2);

        mapSize = size(map);
        mapHeight = mapSize(1);
        mapWidth = mapSize(2);

        tf = rows >= 1 & rows <= mapHeight & cols >= 1 & cols <= mapWidth;
    end


    function letters = getLetters(positions)
        positions = sub2ind(size(map), positions(:,1), positions(:,2));
        letters = map(positions);
    end
end


function combinations = createCombinationsNTimes(vec, nTimes)
nElements = numel(vec);
nCombinations = nElements ^ nTimes;

% Odometer pattern
% https://uk.mathworks.com/matlabcentral/answers/357969-using-recursive-function-to-calculate-all-possible-peptide-combinations#answer_282766
combinations = nan(nCombinations, nTimes);
vecIndex  = ones(1, nTimes);
for ii = 1:nCombinations
    combinations(ii,:) = vec(vecIndex);
    for jj = 1:nTimes
        vecIndex(jj) = vecIndex(jj) + 1;
        if vecIndex(jj) > nElements
            vecIndex(jj) = 1;
        else
            break
        end
    end
end
end





