clear; clc;

codes = readlines("D21 Data.txt");
codes = codes(codes ~= "");

% codes = ["029A";
%          "980A";
%          "179A";
%          "456A";
%          "379A"];

%% Part 1
tic
nCodes = numel(codes);
optimalRouteLengths = nan(nCodes, 1);

for ii = 1:nCodes
    thisCode = codes(ii);
    optimalRoutes = findOptimalRoutes(thisCode);
    l = strlength(optimalRoutes);
    optimalRouteLengths(ii) = l(1);
end

codeNumerics = str2double(extract(codes, digitsPattern()));
complexities = codeNumerics .* optimalRouteLengths;
sumComplexities = sum(complexities);
toc

fprintf("Sum of complexities = %i\n", sumComplexities);

%% Functions
function optimalRoutes = findOptimalRoutes(code)
START_KEY          = "A";

DIRECTIONAL_KEYPAD = [' ^A';
    '<v>'];

NUMERIC_KEYPAD     = ['789';
    '456';
    '123';
    ' 0A'];

% D D D N
N_STAGES = 3;

routePermutations = {convertCharsToStrings(code)};
cache = configureDictionary("string", "cell");
chunkCache = configureDictionary("string", "cell");
for iStage = 1:N_STAGES
    for ii = 1:numel(routePermutations)
        routePermutations{ii} = makeSelfSufficient(routePermutations{ii}, START_KEY);
    end

    if iStage == 1
        keypad = NUMERIC_KEYPAD;
    else
        keypad = DIRECTIONAL_KEYPAD;
    end

    nPermutations = numel(routePermutations);
    permutationsNextStage = {};
    for iPermutation = 1:nPermutations
        thisPermutation = routePermutations{iPermutation}; % Strings row vec
        nChunks = numel(thisPermutation);
        
        additionalPermutations = {};
        for iChunk = 1:nChunks
            thisChunk = thisPermutation(iChunk);

            if chunkCache.isKey(thisChunk)
                chunkRoutes = chunkCache{thisChunk};
            else
                thisChunkChar = convertStringsToChars(thisChunk);
                nSteps = numel(thisChunkChar) - 1;
                chunkRoutes = cell(1, nSteps);
                for iStep = 1:nSteps
                    startKey = thisChunkChar(iStep);
                    targetKey = thisChunkChar(iStep + 1);
                    [chunkRoutes{iStep}, cache] = bfs(keypad, startKey, targetKey, cache);
                end

                chunkCache(thisChunk) = {chunkRoutes};
            end
            additionalPermutations = [additionalPermutations, chunkRoutes];
        end

        additionalPermutations = combinations(additionalPermutations{:}).Variables;
        additionalPermutations = num2cell(additionalPermutations, 2);

        permutationsNextStage = [permutationsNextStage; additionalPermutations];
    end

    routePermutations = permutationsNextStage;
end

nRoutes = numel(routePermutations);
routes = strings(nRoutes, 1);
for ii = 1:nRoutes
    routes(ii) = join(routePermutations{ii}, "");
end

routeLengths = strlength(routes);
[~, iOptimal] = min(routeLengths);
optimalRoutes = routes(iOptimal);
end


function [routes, cache] = bfs(keypad, startKey, targetKey, cache)
arguments
    keypad (:,:) char
    startKey (1,1) char
    targetKey (1,1) char
    cache dictionary = configureDictionary("string", "cell")
end

if cache.isKey({startKey, targetKey})
    routes = cache(string([startKey, targetKey]));
    return
end

if targetKey == startKey
    routes = {"A"};
    return;
end

DIRECTIONS = int8([1, 0; ...
    0, -1; ...
    -1, 0; ...
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
    function out = enumerateString(str)
        out = split(str, "");
        out = out(2 : end - 1);
    end
    function sub = ind2sub_fast(index)
        index = index(:);
        rows = 1 + mod(index - 1, targetKeypadHeight);
        cols = ceil(index / targetKeypadHeight);
        sub = [rows, cols];
    end

% function index = sub2ind_fast(sub)
%     rows = sub(:,1);
%     cols = sub(:,2);
%     index = (cols - 1) * targetKeypadHeight + rows;
% end

    function ok = isInBounds(positions)
        rows = positions(:,1);
        cols = positions(:,2);
        ok = rows >= 1 & rows <= targetKeypadHeight & cols >= 1 & cols <= targetKeypadWidth;
    end
end


function chunkCombinations = makeSelfSufficient(chunkCombinations, START_KEY)
% Makes all the combinations self-sufficient by adding the last step of the previous chunk to the front of the current
% chunk

chunkCombinations(:,1) = START_KEY + chunkCombinations(:,1);
allColumnsExceptLast = chunkCombinations(:, 1 : end - 1); 
chunkCombinations(:, 2:end) = extract(allColumnsExceptLast, strlength(allColumnsExceptLast)) + chunkCombinations(:, 2:end);
end