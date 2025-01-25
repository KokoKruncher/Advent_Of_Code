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
% Number of sides = number of corner nodes. Corner nores are nodes with degree 2 and with
% an edge weight sum of 3. This eliminates nodes of degree 2 where it's neighbours form a
% straight line with it.
isNodeDegree2 = gardenGraph.degree() == 2;
nodesDegree2 = find(isNodeDegree2);
isEdgeOfNodeDegree2 = any(ismember(gardenGraph.Edges.EndNodes,nodesDegree2),2);
edgeTableOfNodesDegree2 = gardenGraph.Edges(isEdgeOfNodeDegree2,:);

% Can't vectorise this because some corners are next to other corners, which means some
% edges need to be considered more than once
nNodesDegree2 = nnz(isNodeDegree2);
isCornerNode = false(nNodesDegree2,1);
for ii = 1:nNodesDegree2
    thisNode = nodesDegree2(ii);
    isEdgeOfThisNode = any(edgeTableOfNodesDegree2.EndNodes == thisNode,2);
    assert(nnz(isEdgeOfThisNode) == 2)
    edgeWeightSum = sum(edgeTableOfNodesDegree2.Weight(isEdgeOfThisNode));
    if edgeWeightSum == 3
        isCornerNode(ii) = true;
    end
end
cornerNodes = nodesDegree2(isCornerNode);

% redefine isCornerNode to reference the entire list of nodes instead of just nodes of
% degree 2.
nNodesTotal = height(gardenGraph.Nodes);
isCornerNode = ismember((1:nNodesTotal)',cornerNodes);

nSidesInRegion = nan(1,nRegions);
for iRegion = 1:nRegions
    isNodeInRegion = nodeRegionIndx == iRegion;
    nRegionCornerNodes = nnz(isNodeInRegion' & isCornerNode);
    nSidesInRegion(iRegion) = nRegionCornerNodes;
end
fencePrices2 = nSidesInRegion.*regionAreas;
totalFencePrice2 = sum(fencePrices2);

fprintf("Total fence price 2: %i\n",totalFencePrice2)

% nSidesInRegion = nan(nRegions,1);
% for iRegion = 1:nRegions
%     isNodeInRegion = nodeRegionIndx == iRegion;
% 
%     % vertices are where the fence posts are
%     regionNodes = gardenGraph.Nodes(isNodeInRegion,:);
%     vertexGraph = createVertexGraph(regionNodes.iRow,regionNodes.iCol);
% 
%     % debug
%     % 
% 
%     % vertices not on the side (outside or inside if it exists) have degree equal to 8
%     isInsideRegionArea = vertexGraph.degree == 8;
%     regionSidesGraphOld = vertexGraph.rmnode(find(isInsideRegionArea));
% 
%     % diagonal edges have weight 0.5
%     isDiagonalEdge = regionSidesGraphOld.Edges.Weights == 0.5;
%     regionSidesGraphOld = regionSidesGraphOld.rmedge(find(isDiagonalEdge));
% 
%     % the last stragglers of internal edges are those connecting "blocks" that are poking
%     % out of the main shape by 1 block (in a 1 block cycle), making nodes that are of
%     % degree 3 or sometimes 4
%     regionSidesGraph = removeLastInternalEdges(regionSidesGraphOld);
% 
%     allCycles = regionSidesGraph.allcycles();
%     nCycles = numel(allCycles);
%     if nCycles == 2
%         disp("Found 2 cycles")
%     elseif nCycles == 0 || nCycles > 2
%         error("Watafak, found %i cycles",nCycles)
%     end
% 
%     if nCycles == 2
%         hAxes = plotRegionAndVertices(regionNodes.iRow,regionNodes.iCol, ...
%             vertexGraph.Nodes.iRow,vertexGraph.Nodes.iCol);
%         hold(hAxes,'on');
%         x = regionSidesGraphOld.Nodes.iCol;
%         y = regionSidesGraphOld.Nodes.iRow;
%         plot(regionSidesGraphOld,'XData',x,'YData',y,'EdgeColor','red')
% 
%         x = regionSidesGraph.Nodes.iCol;
%         y = regionSidesGraph.Nodes.iRow;
%         hPlot = plot(regionSidesGraph,'XData',x,'YData',y,'EdgeColor','green');
%         hold(hAxes,'off')
%     end
% 
% 
%     nDirectionChanges = nan(nCycles,1);
%     for iCycle = 1:nCycles
%         thisCycle = allCycles{iCycle};
% 
%         % important to include the final move back to the first node as that can have a
%         % change in direction too
%         nodesInLoop = [thisCycle,thisCycle(1)];
%         coords = [regionSidesGraph.Nodes.iRow(nodesInLoop), ...
%             regionSidesGraph.Nodes.iCol(nodesInLoop)];
%         directions = diff(coords,1,1);
%         differenceToPreviousDirection = diff(directions,1,1);
%         isDirectionChange = any(differenceToPreviousDirection ~= 0, 2);
%         nDirectionChanges(iCycle) = nnz(isDirectionChange) + 1; % add initial direction
% 
%        if nCycles == 2
%            highlight(hPlot,thisCycle,circshift(thisCycle,1))
%        end
%     end
%     nSidesInRegion(iRegion) = sum(nDirectionChanges);
% 
%     % figure
%     % x = vertexGraph.Nodes.iCol;
%     % y = vertexGraph.Nodes.iRow;
%     % plot(vertexGraph,'XData',x,'YData',y)
%     % 
%     % iLetter = find(nodeRegionIndx == iRegion,1,"first");
%     % letter = gardenGraph.Nodes.letter(iLetter);
%     % figure
%     % x = regionSidesGraph.Nodes.iCol;
%     % y = regionSidesGraph.Nodes.iRow;
%     % plot(regionSidesGraph,'XData',x,'YData',y)
%     % title(letter)
% end
% 
% fencePrices2 = nSidesInRegion(:).*regionAreas(:);
% totalFencePrice2 = sum(fencePrices2);
% 
% fprintf("Total fence price 2: %i\n",totalFencePrice2)



%% Functions
function hAxes = plotRegionAndVertices(iRowRegion,iColRegion,iRowVertex,iColVertex)
iRowRegion = iRowRegion - min(iRowRegion) + 1 + 0.5;
iColRegion = iColRegion - min(iColRegion) + 1 + 0.5;

figure
hAxes = axes;
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
[allCycleNodes,allCycleEdges] = regionSidesGraph.allcycles();
nCycles = numel(allCycleEdges);

if any(regionSidesGraph.degree == 6)
    disp("Found node degree 6")
end

if nCycles == 1
    return
end

cycleSizes = cellfun(@numel,allCycleEdges);
if any(cycleSizes < 4)
    error("Encountered cycle with less than 4 edges")
end

[~,iLargestCycle] = max(cycleSizes);
edgesLargestCycle = allCycleEdges{iLargestCycle};

isOneBlockCycle = cycleSizes == 4;
oneBlockCycleEdges = allCycleEdges(isOneBlockCycle);
oneBlockCycleNodes = allCycleNodes(isOneBlockCycle);

nNodes = regionSidesGraph.numnodes;
nodeDegrees = regionSidesGraph.degree();
degreeOfNodeId = dictionary(1:nNodes,nodeDegrees');

nOneBlockCycles = nnz(isOneBlockCycle);
isInsideEdgeOfRegion = false(nOneBlockCycles,1);
for i = 1:nOneBlockCycles
    thisCycleNodes = oneBlockCycleNodes{i};
    thisCycleNodeDegrees = degreeOfNodeId(thisCycleNodes);
    
    if all(thisCycleNodeDegrees == 2)
        isInsideEdgeOfRegion(i) = true;
    end
end
nInsideEdgesOfRegion = nnz(isInsideEdgeOfRegion);

if nInsideEdgesOfRegion > 1
    error("Detected %i inside edges of region. Max should be 1",nInsideEdgesOfRegion)
end

if any(isInsideEdgeOfRegion)
    edgesInsideEdgeOfRegion = oneBlockCycleEdges{isInsideEdgeOfRegion};
else
    edgesInsideEdgeOfRegion = [];
end

validEdges = [edgesLargestCycle(:); edgesInsideEdgeOfRegion(:)];

nEdgesInitial = regionSidesGraph.numedges;
allEdgesInitial = 1:nEdgesInitial;
edgesToRemove = setdiff(allEdgesInitial,validEdges);
regionSidesGraph = regionSidesGraph.rmedge(edgesToRemove);

% isOneBlockCycle = cellfun(@numel,allCycleEdges) == 4;
% 
% if ~any(isOneBlockCycle)
%     return
% end
% 
% oneBlockCycleEdges = allCycleEdges(isOneBlockCycle);
% oneBlockCycleEdges = [oneBlockCycleEdges{:}]; % concat into one row vector
% 
% nNodes = regionSidesGraph.numnodes;
% sourceNodes = regionSidesGraph.Edges.EndNodes(:,1);
% targetNodes = regionSidesGraph.Edges.EndNodes(:,2);
% nodeDegrees = regionSidesGraph.degree();
% degreeOfNodeId = dictionary(1:nNodes,nodeDegrees');
% sourceNodeDegrees = degreeOfNodeId(sourceNodes);
% targetNodeDegrees = degreeOfNodeId(targetNodes);
% cond1 = targetNodeDegrees == 3 & sourceNodeDegrees == 3;
% cond2 = targetNodeDegrees == 3 & sourceNodeDegrees == 4;
% cond3 = targetNodeDegrees == 4 & sourceNodeDegrees == 3;
% isEdgeToNodesOfDegree3OrDegree3And4 = cond1 | cond2 | cond3;
% iEdgeToNodesOfDegree3 = find(isEdgeToNodesOfDegree3OrDegree3And4);
% 
% isInternalEdge = ismember(oneBlockCycleEdges,iEdgeToNodesOfDegree3);
% 
% if ~any(isInternalEdge)
%     return
% end
% 
% internalEdges = oneBlockCycleEdges(isInternalEdge);
% regionSidesGraph = regionSidesGraph.rmedge(internalEdges);
end