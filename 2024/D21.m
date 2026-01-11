clear; clc;

codes = readlines("D21 Data.txt");
codes = codes(codes ~= "");

% codes = ["029A";
%          "980A";
%          "179A";
%          "456A";
%          "379A"];

%% Part 1

N_DIRECTIONAL_KEYPAD_ROBOTS = 19;
nStages = N_DIRECTIONAL_KEYPAD_ROBOTS + 1;

tic
nCodes = numel(codes);
optimalRoutes = cell(nCodes, 1);
optimalRouteLengths = nan(nCodes, 1);

cache = configureDictionary("cell", "string");
bfsCache = configureDictionary("string", "cell");
for ii = 1:nCodes
    thisCode = convertStringsToChars(codes(ii));
    [optimalRoute, cache, bfsCache] = findOptimalRoute(thisCode, 1, nStages, cache, bfsCache);
    l = strlength(optimalRoute);
    optimalRouteLengths(ii) = l(1);
    optimalRoutes{ii} = optimalRoute;

    % fprintf("%s (%i): %s\n", thisCode, l, optimalRoute);
    % replayRoute(optimalRoute, nStages);
end
codeNumerics = str2double(extract(codes, digitsPattern()));
complexities = codeNumerics .* optimalRouteLengths;
sumComplexities = sum(complexities);
toc

fprintf("Sum of complexities = %i\n", sumComplexities);

%% Functions
function [optimalRoute, cache, bfsCache] = findOptimalRoute(code, stage, nStages, cache, bfsCache)
code = convertStringsToChars(code);

if stage > nStages
    optimalRoute = code;
    return
end

% For the same code, the optimal route will differ depending on how many stages there are left behind it.
cacheKey = {{code, stage}};
if cache.isKey(cacheKey)
    optimalRoute = cache(cacheKey);
    % Dictionary stores char as strings
    optimalRoute = convertStringsToChars(optimalRoute);
    return
end

% Since the directional keyboards have start position at A, and always end at A to make the robot that it's controlling
% press its keypad, this means that the starting key for every robot is always A whenever we come back to it in our DFS.
START_KEY =           'A';

DIRECTIONAL_KEYPAD = [' ^A';
                      '<v>'];

NUMERIC_KEYPAD     = ['789';
                      '456';
                      '123';
                      ' 0A'];

if stage == 1
    keypad = NUMERIC_KEYPAD;
else
    keypad = DIRECTIONAL_KEYPAD;
end

code_ = [START_KEY, code];
nStepsBetweenKeys = numel(code_) - 1;

optimalRoute = '';
for ii = 1:nStepsBetweenKeys
    [codesNextStage, bfsCache] = bfs(keypad, code_(ii), code_(ii + 1), bfsCache);
    nCodesNextStage = numel(codesNextStage);
    
    nextRoute = '';
    minRouteLengthThisStep = Inf;
    for jj = 1:nCodesNextStage
        [potentialRoute, cache, bfsCache] = findOptimalRoute(codesNextStage(jj), stage + 1, nStages, cache, bfsCache);

        routeLength = numel(potentialRoute);
        if routeLength >= minRouteLengthThisStep
            continue
        end

        nextRoute = potentialRoute;
        minRouteLengthThisStep = routeLength;
    end

    optimalRoute = [optimalRoute, nextRoute];
end

if isempty(optimalRoute)
    return
end

cache(cacheKey) = optimalRoute;
end


function [routes, cache] = bfs(keypad, startKey, targetKey, cache)
arguments
    keypad (:,:) char
    startKey (1,1) char
    targetKey (1,1) char
    cache dictionary = configureDictionary("string", "cell")
end

if cache.isKey(string([startKey, targetKey]))
    routes = cache{string([startKey, targetKey])};
    return
end

if targetKey == startKey
    routes = "A";
    return;
end

DIRECTIONS = int8(...
   [1,  0; ...
    0, -1; ...
   -1,  0; ...
    0, 1]);

assert(any(keypad == targetKey, "all"), "Target key is not found in keypad.")

keyStringMap = dictionary(num2cell(DIRECTIONS, 2), ["v"; "<"; "^"; ">"]);
targetKeypadWidth = width(keypad);
targetKeypadHeight = height(keypad);

distanceMap = configureDictionary("cell", "double");
queue = Queue();

startPosition = find(keypad == startKey);
assert(isscalar(startPosition), "Found 0 or more than 1 start positions.");
startPosition = int8(ind2sub_fast(startPosition));

queue.append(startPosition);
iter = 0;
routes = string.empty();
while queue.hasElements()
    iter = iter + 1;
    route = queue.pop();
    position = route(end,:);
    distance = height(route) - 1;

    % Skip non-optimal paths but allow same noded to appear in multiple optimal paths.
    if distanceMap.isKey({position}) && distance > distanceMap({position})
        continue
    end
    distanceMap({position}) = distance;

    key = keypad(position(1), position(2));

    if key == ' '
        continue
    end

    if key == targetKey
        route = keyStringMap(num2cell(diff(route, 1), 2)).';
        route(end+1) = "A"; %#ok<*AGROW>
        route = join(route, "");

        routes(end + 1) = route;
        continue
    end

    nextPositions = position + DIRECTIONS;
    nextPositions = nextPositions(isInBounds(nextPositions), :);
    for ii = 1:height(nextPositions)
        nextRoute = [route; nextPositions(ii,:)];
        queue.append(nextRoute);
    end
end

routes = routes(:);
cache(string([startKey, targetKey])) = {routes};

% Nested functions
    function sub = ind2sub_fast(index)
        index = index(:);
        rows = 1 + mod(index - 1, targetKeypadHeight);
        cols = ceil(index / targetKeypadHeight);
        sub = [rows, cols];
    end


    function ok = isInBounds(positions)
        rows = positions(:,1);
        cols = positions(:,2);
        ok = rows >= 1 & rows <= targetKeypadHeight & cols >= 1 & cols <= targetKeypadWidth;
    end
end


function replayRoute(route, nStages)
% 3 Stages =  N D D H
DIRECTIONAL_KEYPAD = [' ^A';
                      '<v>'];

NUMERIC_KEYPAD     = ['789';
                      '456';
                      '123';
                      ' 0A'];

assert(nStages > 0);

output = cell(nStages, 1);
for ii = 1:nStages
    if ii == nStages
        keypad = NUMERIC_KEYPAD;
    else
        keypad = DIRECTIONAL_KEYPAD;
    end

    if ii > 1
        route = output{ii - 1};
    end

    output{ii} = replayStage(route, keypad);
end

fprintf("Replaying:\n");
for ii = 1:nStages
    fprintf("Stage %i: %s\n", ii, output{ii});
end
fprintf("\n\n");
end


function output = replayStage(stageRoute, keypad)
START_KEY = 'A';

DIRECTIONS =...
   [1,  0; ...
    0, -1; ...
   -1,  0; ...
    0,  1; ...
    0,  0];

keypadHeight = height(keypad);
keypadWidth = width(keypad);
startPosition = ind2sub_fast(find(keypad == START_KEY));

stageRouteString = convertCharsToStrings(stageRoute);
stageRouteString = split(stageRouteString, "");
stageRouteString = stageRouteString(2 : end - 1);
stageRouteString = stageRouteString(:);

directionMap = dictionary();
directionMap("v") = 1;
directionMap("<") = 2;
directionMap("^") = 3;
directionMap(">") = 4;
directionMap("A") = 5;

directionIndex = directionMap(stageRouteString);
direction = DIRECTIONS(directionIndex,:);
positions = startPosition + cumsum(direction, 1);
linearIndices = sub2ind_fast(positions);
keys = keypad(linearIndices);
output = keys(stageRoute == 'A');

% Nested functions
    function sub = ind2sub_fast(index)
        index = index(:);
        rows = 1 + mod(index - 1, keypadHeight);
        cols = ceil(index / keypadHeight);
        sub = [rows, cols];
    end


    function index = sub2ind_fast(sub)
        rows = sub(:,1);
        cols = sub(:,2);
        index = (cols - 1) * keypadHeight + rows;
    end
end


% function output = replayStage(stageRoute, keypad)
% START_KEY = 'A';
% 
% DIRECTIONS =...
%    [1,  0; ...
%     0, -1; ...
%    -1,  0; ...
%     0, 1];
% 
% keypadHeight = height(keypad);
% keypadWidth = width(keypad);
% output = '';
% startPosition = ind2sub_fast(find(keypad == START_KEY));
% currentPosition = startPosition;
% nKeyPresses = numel(stageRoute);
% bPress = false;
% for ii = 1:nKeyPresses
%     thisKey = stageRoute(ii);
%     switch thisKey
%         case 'v'
%             directionIndex = 1;
%         case '<'
%             directionIndex = 2;
%         case '^'
%             directionIndex = 3;
%         case '>'
%             directionIndex = 4;
%         case 'A'
%             bPress = true;
%         otherwise
%             warning("Found invalid key: %s", thisKey)
%             continue
%     end
% 
%     if ~bPress
%         thisDirection = DIRECTIONS(directionIndex, :);
%         nextPosition = currentPosition + thisDirection;
% 
%         if ~isInBounds(nextPosition)
%             error("Next position not in bounds!");
%         end
% 
%         currentPosition = nextPosition;
%     end
% 
%     currentKey = keypad(currentPosition(1), currentPosition(2));
% 
%     if bPress
%         output = [output, currentKey];
%         bPress = false;
%     end
% end
% 
% % Nested functions
%     function sub = ind2sub_fast(index)
%         index = index(:);
%         rows = 1 + mod(index - 1, keypadHeight);
%         cols = ceil(index / keypadHeight);
%         sub = [rows, cols];
%     end
% 
% 
%     function ok = isInBounds(positions)
%         rows = positions(:,1);
%         cols = positions(:,2);
%         ok = rows >= 1 & rows <= keypadHeight & cols >= 1 & cols <= keypadWidth;
%     end
% end