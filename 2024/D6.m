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

% only place new obstacles in places where th guard will actually reach
gridPositionsToCheck = find(map.pathWalked);

% don't place new obstacles on initial position
initialPosition = map.guard.initialPosition;
initialPosition = sub2ind(map.gridSize,initialPosition(1),initialPosition(2));
gridPositionsToCheck = gridPositionsToCheck(gridPositionsToCheck ~= initialPosition);


% 6 workers: ~26s
% 12 workers: ~23s
nWorkers = 6;
if isempty(gcp("nocreate"))
    parpool(nWorkers);
end

tic
nGridPositionsToCheck = numel(gridPositionsToCheck);
bPositionCausesLoop = false(size(gridPositionsToCheck));
parfor (iPosition = 1:nGridPositionsToCheck,nWorkers)
    obstaclePosition = gridPositionsToCheck(iPosition);
    modifiedGrid = originalGrid; 
    modifiedGrid(obstaclePosition) = "#";
    map = PatrolMap("grid",modifiedGrid);

    while map.guard.isInBounds && ~map.guard.isInLoop
        map.step();
        if map.guard.isInLoop
            bPositionCausesLoop(iPosition) = true;
        end
    end
end
toc
delete(gcp('nocreate'))

nPositionsThatCauseLoop = sum(bPositionCausesLoop,"all");
fprintf("Number of positions that cause loop: %i\n", nPositionsThatCauseLoop)