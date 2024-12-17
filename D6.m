clear; clc;
import D6.*
%% Part 1
filename = "D6 Data.txt";
data = readlines(filename);

map = PatrolMap("data",data);

tic
while map.guard.isInBounds && ~map.guard.isInLoop
    map.step();
end
toc
map.exportGrid('bUseDirectionSymbols',true);

nDistinctPositions = sum(map.pathWalked,"all");
fprintf("Number of distinct positions: %i\n\n", nDistinctPositions)

%% Part 2
originalGrid = map.grid;
gridSize = map.gridSize;
nGridPositions = numel(originalGrid);
initialPosition = map.guard.initialPosition;

tic
% 6 workers: ~172-184s
% 12 workers: ~118-125s
nWorkers = 12;
positionCausesLoop = false(size(originalGrid));
parfor (iPosition = 1:nGridPositions,nWorkers)
    if originalGrid(iPosition) == "#"
        continue
    end

    if originalGrid(iPosition) == "^"
        continue
    end

    modifiedGrid = originalGrid;
    modifiedGrid(iPosition) = "#";
    map = PatrolMap("grid",modifiedGrid);

    while map.guard.isInBounds && ~map.guard.isInLoop
        map.step();
        if map.guard.isInLoop
            positionCausesLoop(iPosition) = true;
        end
    end
end
toc

nPositionsThatCauseLoop = sum(positionCausesLoop,"all");
fprintf("Number of positions that cause loop: %i\n", nPositionsThatCauseLoop)