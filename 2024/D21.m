clear; clc;

codes = readlines("D21 Data.txt");
codes = codes(codes ~= "");

% codes = ["029A";
%          "980A";
%          "179A";
%          "456A";
%          "379A"];

%% Part 1
fprintf("Part 1:\n");

N_DIRECTIONAL_KEYPAD_ROBOTS = 2;
nStages = N_DIRECTIONAL_KEYPAD_ROBOTS + 1;

tic
nCodes = numel(codes);
optimalRoutes = cell(nCodes, 1);
optimalRouteLengths = nan(nCodes, 1);

routeCache = configureDictionary("cell", "string");
bfsCache = configureDictionary("string", "cell");
for ii = 1:nCodes
    thisCode = convertStringsToChars(codes(ii));

    [optimalRoute, routeCache, bfsCache] = findOptimalRoute(thisCode, 1, nStages, routeCache, bfsCache);
    l = strlength(optimalRoute);
    optimalRouteLengths(ii) = l(1);
    optimalRoutes{ii} = optimalRoute;

    % fprintf("%s: %i\n", thisCode, l);

    % Printing the route takes a long time for high number of robots
    fprintf("%s (%i): %s\n", thisCode, l, optimalRoute);
    replayRoute(optimalRoute, nStages);
end
codeNumerics = str2double(extract(codes, digitsPattern()));
complexities = codeNumerics .* optimalRouteLengths;
sumComplexities = sum(complexities);
toc

fprintf("Sum of complexities = %i\n", sumComplexities);

%% Part 2
fprintf("\nPart 2:\n");

N_DIRECTIONAL_KEYPAD_ROBOTS = 25;
nStages = N_DIRECTIONAL_KEYPAD_ROBOTS + 1;

tic
nCodes = numel(codes);
optimalRoutes = cell(nCodes, 1);
optimalRouteLengths = nan(nCodes, 1);

routeLengthCache = configureDictionary("cell", "double");
bfsCache = configureDictionary("string", "cell");
for ii = 1:nCodes
    thisCode = convertStringsToChars(codes(ii));

    % Not enough memory and computational power to ever calculate the actual route, so just calculate the route length.
    [optimalRouteLengths(ii), routeLengthCache, bfsCache] ...
        = findOptimalRouteLength(thisCode, 1, nStages, routeLengthCache, bfsCache);

    fprintf("%s: %i\n", thisCode, optimalRouteLengths(ii));  
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
    minRouteLengthThisStage = Inf;
    for jj = 1:nCodesNextStage
        [potentialRoute, cache, bfsCache] = findOptimalRoute(codesNextStage(jj), stage + 1, nStages, cache, bfsCache);

        routeLength = numel(potentialRoute);
        if routeLength >= minRouteLengthThisStage
            continue
        end

        nextRoute = potentialRoute;
        minRouteLengthThisStage = routeLength;
    end

    optimalRoute = [optimalRoute, nextRoute];
end

if isempty(optimalRoute)
    return
end

cache(cacheKey) = optimalRoute;
end


function [optimalRouteLength, cache, bfsCache] = findOptimalRouteLength(code, stage, nStages, cache, bfsCache)
code = convertStringsToChars(code);

if stage > nStages
    optimalRouteLength = strlength(code);
    return
end

cacheKey = {{code, stage}};
if cache.isKey(cacheKey)
    optimalRouteLength = cache(cacheKey);
    % Dictionary stores char as strings
    optimalRouteLength = convertStringsToChars(optimalRouteLength);
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

code = [START_KEY, code];
nStepsBetweenKeys = numel(code) - 1;

optimalRouteLength = 0;
for ii = 1:nStepsBetweenKeys
    [codesNextStage, bfsCache] = bfs(keypad, code(ii), code(ii + 1), bfsCache);
    nCodesNextStage = numel(codesNextStage);

    minRouteLength = Inf;
    for jj = 1:nCodesNextStage
        [potentialRouteLength, cache, bfsCache] ...
            = findOptimalRouteLength(codesNextStage(jj), stage + 1, nStages, cache, bfsCache);

        if potentialRouteLength >= minRouteLength
            continue
        end

        minRouteLength = potentialRouteLength;
    end

    optimalRouteLength = optimalRouteLength + minRouteLength;
end
cache(cacheKey) = optimalRouteLength;
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

% Minimize number of key changes so that the next robot has to do less work, and can just press 'A' lots of times.
% For example, instead of
% <^<^A
% do,
% <<^^A
routes = routes(:);
nRoutes = numel(routes);
nKeyChanges = nan(nRoutes, 1);
for ii = 1:nRoutes
    nKeyChanges(ii) = countKeyChanges(routes(ii));
end
minKeyChanges = min(nKeyChanges);
routes = routes(nKeyChanges == minKeyChanges);

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


    function N = countKeyChanges(route)
        route = convertStringsToChars(route);
        N = nnz(diff(route));
    end
end


function replayRoute(route, nStages)
assert(nStages > 0);

% 3 Stages =  N D D H
DIRECTIONAL_KEYPAD = [' ^A';
                      '<v>'];

NUMERIC_KEYPAD     = ['789';
                      '456';
                      '123';
                      ' 0A'];

DIRECTIONS =...
   [1,  0; ...
    0, -1; ...
   -1,  0; ...
    0,  1; ...
    0,  0];

directionMap = dictionary();
directionMap("v") = 1;
directionMap("<") = 2;
directionMap("^") = 3;
directionMap(">") = 4;
directionMap("A") = 5;

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

    output{ii} = replayStage(route, keypad, DIRECTIONS, directionMap);
end

fprintf("Replaying:\n");
for ii = 1:nStages
    fprintf("Stage %i: %s\n", ii, output{ii});
end
fprintf("\n\n");
end


function output = replayStage(stageRoute, keypad, DIRECTIONS, directionMap)
START_KEY = 'A';

keypadHeight = height(keypad);
startPosition = ind2sub_fast(find(keypad == START_KEY));

stageRouteString = convertCharsToStrings(stageRoute);
stageRouteString = split(stageRouteString, "");
stageRouteString = stageRouteString(2 : end - 1);
stageRouteString = stageRouteString(:);

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