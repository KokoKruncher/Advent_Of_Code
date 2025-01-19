clear; clc;

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

% create node table to ensure that nodes without edges (area = 1) are accounted for
nPlots = numel(gardenMap);
nodeTable = table();
nodeTable.letter = gardenMap(:);

edgeTable = table();
edgeTable.EndNodes = nan(2*nPlots,2);
gardenWidth = width(gardenMap);
gardenHeight = height(gardenMap);
iNode = 0;
iEdge = 0;
for iWidth = 1:gardenWidth
    for iHeight = 1:gardenHeight
        % only need to search down and right
        letter = gardenMap(iHeight,iWidth);
        iNode = iNode + 1;

        if iHeight < gardenHeight && gardenMap(iHeight+1,iWidth) == letter
            iNodeDown = iNode + 1;
            iEdge = iEdge + 1;
            edgeTable{iEdge,:} = [iNode, iNodeDown];
        end

        if iWidth < gardenWidth && gardenMap(iHeight,iWidth+1) == letter
            iNodeRight = sub2ind([gardenHeight,gardenWidth],iHeight,iWidth+1);
            iEdge = iEdge + 1;
            edgeTable{iEdge,:} = [iNode, iNodeRight];
        end
    end
end
edgeTable = edgeTable(~any(isnan(edgeTable.EndNodes),2),:);
gardenGraph = graph(edgeTable,nodeTable);

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

%%
% 
%% Functions
function gardenMap = parseInput(input)
gardenMap = split(input,"");
gardenMap = gardenMap(:,2:end-1);
end