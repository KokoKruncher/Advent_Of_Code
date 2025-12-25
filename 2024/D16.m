clear; clc; close all;

maze = readlines("D16 Data.txt");
maze(maze == "") = [];

%% Part 1
% Based on Jonathon Paulson's solution:
% https://youtu.be/ro2SSxd21JM?si=Odq_xvm0c0oM6pnu

EAST = 4; % East

tic
[minimumScore, scoresForwards, endDirectionIndex] = dijkstra(maze, EAST);
toc

%% Part 2

tic
[~, scoresBackwards] = dijkstra(maze, endDirectionIndex, "backwards", true);
toc

isOnBestPaths = false(size(char(maze)));
states = scoresForwards.keys;
for ii = 1:scoresForwards.numEntries
    thisState = states(ii);

    if ~scoresBackwards.isKey(thisState)
        continue
    end

    if scoresForwards(thisState) + scoresBackwards(thisState) ~= minimumScore
        continue
    end

    position = thisState{:}([1, 2]);
    isOnBestPaths(position(1), position(2)) = true;
end

nPositionsOnBestPaths = nnz(isOnBestPaths);

fprintf("\nUsing Dijkstra's algorithm:\nMinimum score = %i\nNumber of positions in best paths = %i\n", ...
    minimumScore, nPositionsOnBestPaths);

%% Functions
function [minimumScore, scores, endDirectionIndex] = dijkstra(maze, startDirectionIndex, args)
% First time coding up Dijkstra's algorithm.
% If you let Dijkstra run even after reaching the target node, it will find distances from the start node to every other
% reachable node in the graph.
%
% Typically, Dijkstra is used in the context of finding paths with lowest weight between nodes.
% But more generally, nodes can be thought to represent distinct states of singular or even multiple parameters.
%
% In this case, instead of having nodes be the tile position, it can be a state vector of position, direction and score.
% Thus, turning can be considered to be a state transition that is separate to walking.
%
% This lets us avoid the problem in part 2 where when comparing paths, the score at a position can be different by 1000
% as 1 path needs to make 1 less turn than the other in order to reach that tile, but needs to make another turn later
% on to face the correct direction to move to the next tile.
%
% By considering direction in the state vector, each position can have up to 2 states on a path, giving another chance
% for 2 paths that cross the same tile to have the same cost as well.
arguments
    maze char
    startDirectionIndex (1,1) double
    args.backwards (1,1) logical = false
end

if args.backwards
    mazeBackwards = maze;
    mazeBackwards(maze == 'S') = 'E';
    mazeBackwards(maze == 'E') = 'S';
    maze = mazeBackwards;
end

SCORE_WALK = 1;
SCORE_TURN = 1000;

% If ~args.backwards,
% Direction index ++ => turning right
% Direction index -- => turning left
DIRECTIONS = [1, 0; ...
              0, -1; ...
              -1, 0; ...
              0, 1];

if args.backwards
    DIRECTIONS = -DIRECTIONS;
end

N_DIRECTIONS = height(DIRECTIONS);
STRAIGHT = 0;
LEFT = -1;
RIGHT = 1;

START_SCORE = 0;

maze = char(maze);
mazeSize = size(maze);
mazeHeight = mazeSize(1);
mazeWidth = mazeSize(2);

[startPosition(1), startPosition(2)] = ind2sub(mazeSize, find(maze == 'S'));
[endPosition(1), endPosition(2)] = ind2sub(mazeSize, find(maze == 'E'));

scores = configureDictionary("cell", "double");
minimumScore = [];
statesToCheck = PriorityQueue();

startDirectionIndex = makeInRange(startDirectionIndex);
scores({[startPosition, startDirectionIndex]}) = START_SCORE;
statesToCheck.push([startPosition, startDirectionIndex], START_SCORE);
iter = 0;
while statesToCheck.hasElements()
    iter = iter + 1;

    if iter > 1e5
        error("Max iterations!")
    end

    [state, score] = statesToCheck.pop();
    position = state(1:2);
    directionIndex = state(3);
    
    % if seen.contains({position, directionIndex, score})
    %     continue
    % end
    % seen.add({position, directionIndex, score});

    if iter > 1 && scores.isKey({state}) && score >= scores({state})
        continue
    end

    scores({state}) = score;

    if isequal(position, endPosition)
        minimumScore = score;
        endDirectionIndex = directionIndex;
        break
    end

    % Next potential states are either walking straight ahead, turning left in place, or turing right in place
    pushNextState(STRAIGHT);
    pushNextState(LEFT);
    pushNextState(RIGHT);
end

fprintf("Number of iterations = %i\n", iter);

% Nested functions
    function tf = isInBounds(positions)
        tf = positions(:,1) >= 1 & positions(:,1) <= mazeHeight & positions(:,2) >= 1 & positions(:,2) <= mazeWidth;
    end


    function tf = isWalkable(positions)
        tf = maze(sub2ind(mazeSize, positions(:,1), positions(:,2))) ~= '#';
    end


    function directionIndex = makeInRange(directionIndex)
        directionIndex = mod(directionIndex - 1, N_DIRECTIONS) + 1;
    end


    function pushNextState(directionIncrement)
        nextDirectionIndex = makeInRange(directionIndex + directionIncrement);
        nextDirection = DIRECTIONS(nextDirectionIndex,:);
        nextStepPosition = position + nextDirection;

        if ~isWalkable(nextStepPosition) || ~isInBounds(nextStepPosition)
            return
        end

        % Step != state!
        if directionIncrement == 0
            nextStatePosition = nextStepPosition;
            nextStateScore = score + SCORE_WALK;
        else
            nextStatePosition = position;
            nextStateScore = score + SCORE_TURN;
        end

        % statesToCheck.push({position, rightDirectionIndex}, score + SCORE_TURN);
        statesToCheck.push([nextStatePosition, nextDirectionIndex], nextStateScore);
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

