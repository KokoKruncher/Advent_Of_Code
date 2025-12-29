clear; clc; close all;

corruptedCoords = readlines("D18 Data.txt");
corruptedCoords = corruptedCoords(corruptedCoords ~= "");
corruptedCoords = str2double(split(corruptedCoords, ","));

% Convert from 0-indexed to 1-indexed
corruptedCoords = corruptedCoords + 1;

%% Part 1
N_FALLEN_BYTES = 1024;
isCorrupted = generateCorruptedGrid(corruptedCoords, N_FALLEN_BYTES);

minSteps = solveMinimumSteps(isCorrupted);

fprintf("Minimum number of steps to exit = %i\n", minSteps);

%% Part 2
% Adding more corrupted coordinates after the path has been blocked cannot cause the path to become unblocked.
% Therefore, the array isPathBlocked[nFallenBytes] is a sorted boolean array
% e.g. [0, 0, 0, ... 0, 1, 1, 1, ... 1]
% Hence, we can perform a binary search to reduce the number of times we search for a path

% Binary search for first occurence of TRUE
nCorruptedCoords = height(corruptedCoords);
lowValue = N_FALLEN_BYTES + 1;
highValue = nCorruptedCoords;
iFirst = nan; 
while lowValue <= highValue
     midValue = floor((lowValue + highValue) / 2);
     midValueIsBlocked = isThisNumberBlocking(midValue, corruptedCoords);
     if midValueIsBlocked
        iFirst = midValue;
        highValue = midValue - 1;
     else
         lowValue = midValue + 1;
     end
end

if isnan(iFirst)
    error("Solution not found!");
end

% Make sure to convert back to 0-based indexing!
blockingByte = corruptedCoords(iFirst,:) - 1;
fprintf("Blocking byte = %i,%i\n", blockingByte);

%% Functions
function isCorrupted = generateCorruptedGrid(corruptedCoords, nFallenBytes)
assert(nFallenBytes <= height(corruptedCoords))

MAX_WIDTH = 71;
MAX_HEIGHT = 71;

isCorrupted = false(MAX_WIDTH, MAX_HEIGHT);
for ii = 1:nFallenBytes
    isCorrupted(corruptedCoords(ii,1), corruptedCoords(ii,2)) = true;
end
end


function [minSteps, isTargetFound] = solveMinimumSteps(isCorrupted)
maxWidth = width(isCorrupted);
maxHeight = height(isCorrupted);

START_POSITION = [1, 1];
END_POSITION = [maxHeight, maxWidth];

if isCorrupted(START_POSITION(1), START_POSITION(2))
    minSteps = nan;
    isTargetFound = false;
    return
end

[minSteps, isTargetFound] = bfs(START_POSITION, END_POSITION, [maxHeight, maxWidth], isCorrupted);
end


function [nStepsToTarget, isTargetFound] = bfs(startPosition, targetPosition, bounds, isCorrupted)
arguments
    startPosition (1,2) double
    targetPosition (1,2) double
    bounds (1,2) double
    isCorrupted (:,:) logical
end
DIRECTIONS = [1, 0; ...
    0, -1; ...
    -1, 0; ...
    0, 1];
START_N_STEPS = 0;

seen = Set();
stepsMap = dictionary();
queue = Queue();

queue.append([startPosition, START_N_STEPS]);
stepsMap({startPosition}) = 0;
iter = 0;
while queue.hasElements()
    iter = iter + 1;
    % if iter > 100e3
    %     error("Max iterations!")
    % end
    state = queue.pop();
    position = state(1:2);
    nSteps = state(3);

    if seen.contains(position)
        continue
    end

    seen.add({position});
    stepsMap({position}) = nSteps;

    if isequal(position, targetPosition)
        break
    end

    nextPositions = position + DIRECTIONS;
    nextPositions = nextPositions(isInBounds(nextPositions), :);
    for ii = 1:height(nextPositions)
        thisPosition = nextPositions(ii,:);
        if seen.contains(thisPosition)
            continue
        end

        if isCorrupted(thisPosition(1), thisPosition(2))
            continue
        end

        queue.append([thisPosition, nSteps + 1]);
    end
end

nStepsToTarget = stepsMap.lookup({targetPosition}, "FallbackValue", nan);
isTargetFound = ~isnan(nStepsToTarget);

% Nested functions
    function tf = isInBounds(positions)
        rows = positions(:,1);
        cols = positions(:,2);

        tf = rows > 0 & rows <= bounds(1) & cols > 0 & cols <= bounds(2);
    end
end


function tf = isThisNumberBlocking(nFallenBlocks, corruptedCoords)
isCorrupted = generateCorruptedGrid(corruptedCoords, nFallenBlocks);
[~, tf] = solveMinimumSteps(isCorrupted);
tf = ~tf;
end
