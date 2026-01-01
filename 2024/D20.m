clear; clc; close all;

map = readlines("D20 Data.txt");
map = map(map ~= "");
map = char(map);

%% Part 1
tic
[originalTime, pathPositions, timeLeft, skips] = calculateTimeSaved(map, 2);
t = toc;

skips = skips.entries();
skips = renamevars(skips, "Key", "StartEndPositions");
skips = renamevars(skips, "Value", "TimeSaved");

tabulate(skips.TimeSaved(skips.TimeSaved >= 0));

nSkipsSaving100 = nnz(skips.TimeSaved >= 100);
fprintf("Function evaluation time: %.3f\n", t);
fprintf("Number of skips saving at least 100 picoseconds = %i\n", nSkipsSaving100);

%% Functions
function [originalTime, pathPositions, timeLeft, timeSaved] = calculateTimeSaved(map, nSkipsMax)
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
nSkipsMax = 20;
timeSaved = dictionary();
nPositions = height(pathPositions);

combinationIndices = table2array(combinations(1:nPositions, 1:nPositions));
skipStartPositions = pathPositions(combinationIndices(:,1), :);
skipEndPositions = pathPositions(combinationIndices(:,2), :);
skipDistance = manhattanDistance(skipStartPositions, skipEndPositions);

isValidSkip = skipDistance <= nSkipsMax;
skipStartPositions = skipStartPositions(isValidSkip,:);
skipEndPositions = skipEndPositions(isValidSkip,:);
skipDistance = skipDistance(isValidSkip);

nValidSkips = numel(skipDistance);

% skipIds = nan(2 * nValidSkips, 2);
% skipIds(1 : 2 : 2 * nValidSkips, :) = skipStartPositions;
% skipIds(2 : 2 : 2 * nValidSkips, :) = skipEndPositions;
% skipIds = mat2cell(skipIds, repmat(2, nValidSkips, 1));
% 
% skipStartPositions = num2cell(skipStartPositions, 2);
% skipEndPositions = num2cell(skipEndPositions, 2);
% 
% timeSaved(skipIds) = timeLeft(skipStartPositions) - timeLeft(skipEndPositions) - skipDistance;


% for ii = 1:nValidSkips
%     thisStartPosition = skipStartPositions(ii,:);
%     thisEndPosition = skipEndPositions(ii,:);
%     thisSkip = [thisStartPosition; thisStartPosition];
% 
%     timeSaved({thisSkip}) = timeLeft({thisStartPosition}) - timeLeft({thisEndPosition}) - skipDistance(ii);
% end


skipIds = cell(nValidSkips, 1);
skipStartPositionsCell = cell(nValidSkips, 1);
skipEndPositionsCell = cell(nValidSkips, 1);
for ii = 1:nValidSkips
    thisStartPosition = skipStartPositions(ii,:);
    thisEndPosition = skipEndPositions(ii,:);

    skipIds{ii} = [thisStartPosition; thisEndPosition];
    skipStartPositionsCell{ii} = thisStartPosition;
    skipEndPositionsCell{ii} = thisEndPosition;
end

timeSaved(skipIds) = timeLeft(skipStartPositionsCell) - timeLeft(skipEndPositionsCell) - skipDistance;

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


function d = manhattanDistance(position1, position2)
d =  sum(abs(position1 - position2), 2);
end





