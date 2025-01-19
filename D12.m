clear; clc; close all

%% Part 1
filename = "D12 Data.txt";
% input = readlines(filename);
input = ["RRRRIICCFF"; ...
"RRRRIICCCF"; ...
"VVRRRCCFFF"; ...
"VVRCCCJFFF"; ...
"VVVVCJJCFE"; ...
"VVIVCCJJEE"; ...
"VVIIICJJEE"; ...
"MIIIIIJJEE"; ...
"MIIISIJEEE"; ...
"MMMISSJEEE"];

gardenMap = parseInput(input);

gardenGraph = mapToGraph(gardenMap);

% each node starts off with a perimiter of 4 (1 on each side). every new edge decreases
% its perimeter by 1.
[nodeRegionIndx,regionAreas] = gardenGraph.conncomp;
nRegions = max(nodeRegionIndx);
regionPerimeters = nan(size(regionAreas));
nodeDegrees = gardenGraph.degree();
for iRegion = 1:nRegions
    isNodeInRegion = nodeRegionIndx == iRegion;
    nNodesInRegion = nnz(isNodeInRegion);
    regionPerimeters(iRegion) = sum(4 - nodeDegrees(isNodeInRegion));
end
fencePrices = regionPerimeters.*regionAreas;
totalFencePrice = sum(fencePrices);

fprintf("Total fence price: %i\n",totalFencePrice)

%% Part 2
nSides = nan(nRegions,1);
for iRegion = 1:nRegions
    isNodeInRegion = nodeRegionIndx == iRegion;

    regionNodes = gardenGraph.Nodes(isNodeInRegion,:);
    [vertexRows,vertexCols] = gridIndxToVertex(regionNodes.iRow,regionNodes.iCol);

    % debug
    % plotRegionAndVertices(regionNodes.iRow,regionNodes.iCol,vertexRows,vertexCols)

    vertexGraph = createVertexGraph(vertexRows,vertexCols);
    
    % vertices not on the side (outside or inside if it exists) have degree equal to 8
    isInsideRegionArea = vertexGraph.degree == 8;
    regionSidesGraph = vertexGraph.rmnode(find(isInsideRegionArea));

    % diagonal edges have weight 0.5
    isDiagonalEdge = regionSidesGraph.Edges.Weights == 0.5;
    regionSidesGraph = regionSidesGraph.rmedge(find(isDiagonalEdge));

    % the last stragglers of internal edges are those connecting "blocks" that are poking
    % out of the main shape by 1 block (in a 1 block cycle), making nodes that are of
    % degree 3
    regionSidesGraph = removeLastInternalEdges(regionSidesGraph);

    allCycles = regionSidesGraph.allcycles();
    nCycles = numel(allCycles);
    if nCycles == 2
        disp("Found 2 cycles")
    elseif nCycles == 0 || nCycles > 2
        error("Watafak, found %i cycles",nCycles)
    end
    
    nDirectionChanges = nan(nCycles,1);
    for iCycle = 1:nCycles
        thisCycle = allCycles{iCycle};
        coords = [regionSidesGraph.Nodes.iRow(thisCycle), ...
            regionSidesGraph.Nodes.iCol(thisCycle)];
        directions = diff(coords,1,1);
        differenceToPreviousDirection = diff(directions,1,1);
        isDirectionChange = any(differenceToPreviousDirection ~= 0, 2);
        nDirectionChanges(iCycle) = nnz(isDirectionChange);
    end
    nSides(iRegion) = sum(nDirectionChanges);
end

figure
x = vertexGraph.Nodes.iCol;
y = vertexGraph.Nodes.iRow;
z = zeros(size(x));
plot(vertexGraph,'XData',x,'YData',y)

figure
x = regionSidesGraph.Nodes.iCol;
y = regionSidesGraph.Nodes.iRow;
z = zeros(size(x));
plot(regionSidesGraph,'XData',x,'YData',y)
%% Functions
function plotRegionAndVertices(iRowRegion,iColRegion,iRowVertex,iColVertex)
iRowRegion = iRowRegion - min(iRowRegion) + 1 + 0.5;
iColRegion = iColRegion - min(iColRegion) + 1 + 0.5;

figure
hold on
scatter(iColRegion,iRowRegion,"DisplayName","Region")
scatter(iColVertex,iRowVertex,"DisplayName","Vertex")
hold off
grid on
legend
xlabel("Column")
ylabel("Row")
end



function gardenMap = parseInput(input)
gardenMap = split(input,"");
gardenMap = gardenMap(:,2:end-1);
end



function regionSidesGraph = removeLastInternalEdges(regionSidesGraph)
[~,allCycleEdges] = regionSidesGraph.allcycles();
isOneBlockCycle = cellfun(@numel,allCycleEdges) == 4;

if ~any(isOneBlockCycle)
    return
end

oneBlockCycleEdges = allCycleEdges(isOneBlockCycle);
oneBlockCycleEdges = [oneBlockCycleEdges{:}]; % concat into one row vector

nNodes = regionSidesGraph.numnodes;
sourceNodes = regionSidesGraph.Edges.EndNodes(:,1);
targetNodes = regionSidesGraph.Edges.EndNodes(:,2);
nodeDegrees = regionSidesGraph.degree();
degreeOfNodeId = dictionary(1:nNodes,nodeDegrees');
sourceNodeDegrees = degreeOfNodeId(sourceNodes);
targetNodeDegrees = degreeOfNodeId(targetNodes);
isEdgeToNodesOfDegree3 = targetNodeDegrees == 3 & sourceNodeDegrees == 3;
iEdgeToNodesOfDegree3 = find(isEdgeToNodesOfDegree3);

isInternalEdge = ismember(oneBlockCycleEdges,iEdgeToNodesOfDegree3);

if ~any(isInternalEdge)
    return
end

internalEdges = oneBlockCycleEdges(isInternalEdge);
regionSidesGraph = regionSidesGraph.rmedge(internalEdges);
end