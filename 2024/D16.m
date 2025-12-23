clear; clc; close all;

maze = readlines("D16 Test 1.txt");
maze(maze == "") = [];

%% Part 1 & Part 2
tic
[minimumScore, nPositionsInBestPaths] = dijkstra(maze);
toc

fprintf("Using Dijkstra's algorithm:\nMinimum score = %i\nNumber of positions in best paths = %i\n", ...
    minimumScore, nPositionsInBestPaths);

%% Functions
function [minimumScore, nPositionsOnBestPaths] = dijkstra(maze)
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
explored = configureDictionary("cell", "logical");
previous = configureDictionary("cell", "cell");
nodesToCheck = PriorityQueue(1000);

score({startPosition}) = 0;
appendPrevious(startPosition, []);
nodesToCheck.push([startPosition, START_DIRECTION], 0);

iter = 0;
while nodesToCheck.hasElements()
    iter = iter + 1;

    [currentNodeInfo, currentScore] = nodesToCheck.pop();
    currentPosition = currentNodeInfo(1:2);
    currentDirection = currentNodeInfo(3:4);
    
    if explored.isKey({currentPosition})
        continue
    end
    
    explored({currentPosition}) = true;

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
        addedScore = SCORE_WALK + ~isSameDirection(ii) * SCORE_TURN;
        thisNeighbourScore = currentScore + addedScore;
        
        if score.isKey({thisNeighbourPosition}) && (thisNeighbourScore - score({thisNeighbourPosition})) > SCORE_TURN
            % If the the score for this neighbour is equal to a previously found score for this neighbour, then we have
            % found a new path to this neighbour that is the same score as the previous shortest path. So, keep track of
            % it too.
            %
            % But the score of a specific tile depends on where you came from. If you come up to a tile that you've
            % already seen and that you know is on the shortest path, you must have come up to it from a different
            % direction, which necessitates that either you or the previous path would need to make a turn at this tile.
            %
            % So, we need to make an allowance where the score of this new path can be up to 1000 more than the score of
            % the previously found path and still be considered equivalent.
            continue
        end

        appendPrevious(thisNeighbourPosition, currentPosition);
        score({thisNeighbourPosition}) = thisNeighbourScore;

        thisNeighbourDirection = neighbourDirections(ii,:);
        nodesToCheck.push([thisNeighbourPosition, thisNeighbourDirection], thisNeighbourScore);
    end
end

if ~score.isKey({endPosition})
    error("Did not reach end of maze!");
end

fprintf("Number of iterations = %i\n", iter);

minimumScore = score({endPosition});

% Reverse start and end positions as the functoin wants to know the next nodes, not previous nodes
positionsOnBestPaths = findPositionsPaths_DAG(endPosition, startPosition, previous);
nPositionsOnBestPaths = height(positionsOnBestPaths);

% visualisePath(maze, positionsOnBestPaths);

% Nested functions
    function appendPrevious(pos, prevPos)
        if previous.isKey({pos})
            previous{{pos}}(end+1,:) = prevPos;
        else
            previous{{pos}} = prevPos;
        end
    end
end


function positionsOnPaths = findPositionsPaths_DAG(startPosition, endPosition, edges)
positionsOnPaths = {};
seen = configureDictionary("cell", "logical");
onPath = configureDictionary("cell", "logical");
dfs(startPosition, endPosition, edges, [], seen, onPath);

positionsOnPaths = vertcat(positionsOnPaths{:});
positionsOnPaths = unique(positionsOnPaths, "rows");

% Nested functions
    function [seen, onPath] = dfs(sourceNode, endNode, edges, currentPath, seen, onPath)
        if seen.isKey({sourceNode})
            if onPath.isKey({sourceNode})
                positionsOnPaths{end+1} = currentPath;
            end

            return
        end

        seen({sourceNode}) = true;
        currentPath(end+1,:) = sourceNode;

        if isequal(sourceNode, endNode)
            positionsOnPaths{end+1} = currentPath;

            nPositionsInCurrentPath = height(currentPath);
            currentPath = num2cell(currentPath, 2);
            for ii = 1:nPositionsInCurrentPath
                onPath(currentPath(ii)) = true;
            end

            return
        end

        neighbours = edges{{sourceNode}};
        if isempty(neighbours)
            return
        end

        nNeighbours = height(neighbours);
        for ii = 1:nNeighbours
            [seen, onPath] = dfs(neighbours(ii,:), endNode, edges, currentPath, seen, onPath);
        end
    end
end


function visualisePath(maze, path)
arguments
    maze char
    path (:,2) double
end

path = sub2ind(size(maze), path(:,1), path(:,2));
maze(path) = 'O';

fprintf("Paths:\n");
disp(maze);
end

