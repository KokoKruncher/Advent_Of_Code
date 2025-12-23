clear; clc; close all;

maze = readlines("D16 Data.txt");
maze(maze == "") = [];

%% Part 1
tic
minimumScore = dijkstra(maze);
toc
fprintf("Minimum score using Dijkstra's algorithm = %i\n", minimumScore);

%% Functions
function minimumScore = dijkstra(maze)
SCORE_WALK = 1;
SCORE_TURN = 1000;
DIRECTIONS = [1, 0; ...
              0, -1; ...
              -1, 0; ...
              0, 1];
START_DIRECTION = [0, 1]; % East

maze = char(maze);
mazeSize = size(maze);
mazeHeight = mazeSize(1);
mazeWidth = mazeSize(2);

isInBounds = @(positions) positions(:,1) >= 1 & positions(:,1) <= mazeHeight ...
                        & positions(:,2) >= 1 & positions(:,2) <= mazeWidth;

isWalkable = @(positions) ismember(maze(sub2ind(mazeSize, positions(:,1), positions(:,2))), 'SE.');

[startPosition(1), startPosition(2)] = ind2sub(mazeSize, find(maze == 'S'));
[endPosition(1), endPosition(2)] = ind2sub(mazeSize, find(maze == 'E'));

score = dictionary();
nodesToCheck = PriorityQueue(1000);

score({startPosition}) = 0;
nodesToCheck.push([startPosition, START_DIRECTION], 0);
iter = 0;
while nodesToCheck.hasElements()
    iter = iter + 1;
    [currentNodeInfo, currentScore] = nodesToCheck.pop();
    currentPosition = currentNodeInfo(1:2);
    currentDirection = currentNodeInfo(3:4);

    if isequal(currentPosition, endPosition)
        break
    end

    neighbourPositions = currentPosition + DIRECTIONS;
    
    isValid = isWalkable(neighbourPositions) & isInBounds(neighbourPositions);
    neighbourPositions = neighbourPositions(isValid,:);
    neighbourDirections = DIRECTIONS(isValid,:);
    isSameDirection = all(neighbourDirections == currentDirection, 2);

    nNeighbourPositions = height(neighbourPositions);
    for ii = 1:nNeighbourPositions
        thisNeighbourPosition = neighbourPositions(ii,:);
        
        if score.isKey({thisNeighbourPosition})
            continue
        end

        addedScore = SCORE_WALK + ~isSameDirection(ii) * SCORE_TURN;
        thisNeighbourScore = currentScore + addedScore;
        score({thisNeighbourPosition}) = thisNeighbourScore;

        thisNeighbourDirection = neighbourDirections(ii,:);
        nodesToCheck.push([thisNeighbourPosition, thisNeighbourDirection], thisNeighbourScore);
    end
end

if ~score.isKey({endPosition})
    error("Did not reach end of maze!");
end

minimumScore = score({endPosition});
fprintf("Number of iterations = %i\n", iter)
end

