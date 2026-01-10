clear; clc;

START_KEY          = 'A';

DIRECTIONAL_KEYPAD = [' ^A';
                      '<v>'];

NUMERIC_KEYPAD     = ['789';
                      '456';
                      '123';
                      ' 0A'];

% D D D N
N_STAGES = 3;




code = '456A';
routeCache = configureDictionary("string", "string");
for iStage = 1:N_STAGES
    if iStage == 1
        keypad = NUMERIC_KEYPAD;
    else
        code = route;
        keypad = DIRECTIONAL_KEYPAD;
    end

    nKeys = numel(code);
    route = cell(1, nKeys);
    for iKey = 1:nKeys
        if iKey == 1
            startKey = START_KEY;
        else
            startKey = code(iKey - 1);
        end

        targetKey = code(iKey);
        [route{iKey}, routeCache] = bfs(keypad, startKey, targetKey, routeCache);
    end
    route = char(join(horzcat(route{:}), ""));
end

%% Functions
function [route, routeCache] = bfs(keypad, startKey, targetKey, routeCache)
arguments
    keypad (:,:) char
    startKey (1,1) char
    targetKey (1,1) char
    routeCache dictionary = configureDictionary("string", "string")
end

if routeCache.isKey({startKey, targetKey})
    route = routeCache(string([startKey, targetKey]));
    route = enumerateString(route);
    return
end

if targetKey == startKey
    route = "A";
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

seen = Set();
queue = Queue();

startPosition = find(keypad == startKey);
assert(isscalar(startPosition), "Found 0 or more than 1 start positions.");
startPosition = int8(ind2sub_fast(startPosition));

queue.append(startPosition);
iter = 0;
while queue.hasElements()
    iter = iter + 1;
    route = queue.pop();
    position = route(end,:);
    
    if seen.contains(position)
        continue
    end
    seen.add(position);

    key = keypad(position(1), position(2));
    
    if key == ' '
        continue
    end

    if key == targetKey
        break
    end

    nextPositions = position + DIRECTIONS;
    nextPositions = nextPositions(isInBounds(nextPositions), :);
    for ii = 1:height(nextPositions)
        nextRoute = [route; nextPositions(ii,:)];
        queue.append(nextRoute);
    end
end

route = keyStringMap(num2cell(diff(route, 1), 2)).';
route(end+1) = "A";

routeCache(string([startKey, targetKey])) = join(route, "");

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