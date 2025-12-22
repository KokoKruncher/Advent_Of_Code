clear; clc; close all

%% Part 1 & Part 2
filename = "D12 Data.txt";
input = readlines(filename);

gardenMap = parseInput(input);
neighbours = constructGraph(gardenMap);

components = analyseComponents(gardenMap, neighbours);

componentIds = 1:components.numEntries;
totalPrice1 = sum([components(componentIds).area] .* [components(componentIds).perimeter]);
totalPrice2 = sum([components(componentIds).area] .* [components(componentIds).nSides]);

fprintf("Total price, part 1 = %i\n", totalPrice1);
fprintf("Total price, part 2 = %i\n", totalPrice2);


%% Functions
function gardenMap = parseInput(input)
gardenMap = split(input,"");
gardenMap = gardenMap(:,2:end-1);
end


function component = analyseComponents(gardenMap, neighbours)
gardenSize = size(gardenMap);
component = configureDictionary("double", "struct");
isInKnownComponent = false(gardenSize);
iComponent = 0;
while any(~isInKnownComponent, "all")
    if iComponent > 1000
        error("bruh")
    end
    iComponent = iComponent + 1;
    node = find(~isInKnownComponent, 1, "first");
    isConnected = false(gardenSize);
    isConnected = findConnectedComponent(node, neighbours, isConnected);

    ThisComponent = struct();
    ThisComponent.area = nnz(isConnected);

    % Debug
    ThisComponent.letter = gardenMap(node);
    ThisComponent.isConnected = isConnected;

    % A lone node has 4 sides with length of 1.
    % Each node that neighbours it reduces the contribution of the square to the total perimeter by 1.
    % If a node is completely internal (surrounded on all 4 sides), then it's contribution would be 0.
    neighbourKernel = [0, 1, 0; ...
                       1, 0, 1; ...
                       0, 1, 0];
    perimeterConvolution = conv2(isConnected, neighbourKernel, "same");
    ThisComponent.perimeter = sum(isConnected .* (4 - perimeterConvolution), "all");

    % The number of sides in a polygon is equal to the number of corners/vertices.
    % Initial idea was to use a kernel of [1, 1; 1, 1], and if the convolution was 1, it was a convex corner and if the
    % convolution was 3, it was a concave corner.
    % But this cannot handle the edge case below:
    %
    % AAAAAA
    % AAABBA
    % AAABBA
    % ABBAAA
    % ABBAAA
    % AAAAAA
    %
    % All the A's form one region and the B's form two regions. In between the two B's the fences of the A region meet
    % diagonally and there are 2 corners there, but the convolution would result in a value of 2, which won't be picked
    % up as a corner.
    %
    % To handle this, use a kernel of [-1, 1; 1, -1] instead.
    % If the absolute value of the convolution is 1, then it is a traditional corner.
    % But if the absolute value is 2, then it is where 2 corners of the fence of a single region meet.
    % To count the number of corners, simply sum the absolute value of the convolution result.
    cornerKernel = [-1, 1; ...
                    1, -1];
    cornerConvolution = conv2(isConnected, cornerKernel);
    ThisComponent.nSides = sum(abs(cornerConvolution), "all");

    component(iComponent) = ThisComponent;
    isInKnownComponent = isInKnownComponent | isConnected;
end
end


function isConnected = findConnectedComponent(node, neighbours, isConnected)
% DFS
if isConnected(node)
    return
end

isConnected(node) = true;

if ~neighbours.isKey(node)
    return
end

connectedNodes = neighbours{node};
for thisNode = connectedNodes(:).'
    isConnected = findConnectedComponent(thisNode, neighbours, isConnected);
end
end


function neighbours = constructGraph(gardenMap)
directions = [1, 0; ...
             0, -1; ...
             -1, 0; ...
             0, 1];
nDirections = height(directions);

mapWidth = width(gardenMap);
mapHeight = height(gardenMap);
mapSize = size(gardenMap);
nElements = numel(gardenMap);

neighbours = configureDictionary("double", "cell");
for index = 1:nElements
    letter = gardenMap(index);
    position = toSubscripts(index);

    for iDirection = 1:nDirections
        newPosition = position + directions(iDirection,:);
        if ~isInBounds(newPosition)
            continue
        end

        newLetter = gardenMap(newPosition(1), newPosition(2));
        if newLetter ~= letter
            continue
        end
        
        newIndex = toLinearIndex(newPosition);
        if neighbours.isKey(index)
            neighbours{index}(end+1) = newIndex;
        else
            neighbours{index} = newIndex;
        end
    end
end

% Nested functions
    function subscripts = toSubscripts(linearIndex)
        [row, col] = ind2sub(mapSize, linearIndex);
        subscripts = [row, col];
    end


    function linearIndex = toLinearIndex(subscripts)
        linearIndex = sub2ind(mapSize, subscripts(1), subscripts(2));
    end


    function tf = isInBounds(subscripts)
        tf = false;

        if subscripts(1) < 1 || subscripts(1) > mapHeight
            return
        end

        if subscripts(2) < 1 || subscripts(2) > mapWidth
            return
        end

        tf = true;
    end
end