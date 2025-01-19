function vertexGraph = createVertexGraph(gridRows,gridCols)
arguments
    gridRows (:,1) double
    gridCols (:,1) double
end

% convert coordinates from the entire map to the region, starting at (row,col) = (0,0)
[vertexRows,vertexCols,elementRows,elementCols] = gridIndxToRegionIndx(gridRows,gridCols);

regionSize = [max(vertexRows), max(vertexCols)];
isVertex = false(regionSize);
iVertex = sub2ind(regionSize,vertexRows,vertexCols);
isVertex(iVertex) = true;

% create node table to ensure that nodes without edges (area = 1) are accounted for
nVertices = numel(isVertex);
nodeTable = table();
[nodeRows,nodeCols] = ind2sub(size(isVertex),1:nVertices);
nodeTable.iRow = nodeRows(:);
nodeTable.iCol = nodeCols(:);

nNodes = height(nodeTable);
nodeIds = (1:nNodes)';
nodeCoords = mat2cell([nodeRows(:),nodeCols(:)], ones(nNodes,1), 2);
coordsToNodeId = dictionary(nodeCoords,nodeIds);
nodeIdToCoords = dictionary(nodeIds,nodeCoords);

% an element is a plant in the region. Each element has 4 vertices
nElements = numel(elementRows);
directionTopLeft = [-0.5, -0.5];
directionTopRight = [-0.5, 0.5];
directionBottomLeft = [0.5, -0.5];
directionBottomRight = [0.5, 0.5];

[endNodes,weights] = createEdgesAndWeights(nElements,elementRows,elementCols, ...
    directionTopLeft,directionTopRight,directionBottomLeft,directionBottomRight, ...
    coordsToNodeId,nodeIdToCoords);

edgeTable = table();
edgeTable.EndNodes = vertcat(endNodes{:});
edgeTable.Weights = vertcat(weights{:});
vertexGraph = graph(edgeTable,nodeTable);

% remove edges counted more than once
vertexGraph = simplify(vertexGraph);

% remove nodes that are not a vertex
isVertex = vertexGraph.degree > 1;
nNodes = vertexGraph.numnodes;
allNodeIds = 1:nNodes;
vertexGraph = vertexGraph.rmnode(allNodeIds(~isVertex));
end



function [vertexRows,vertexCols,elementRows,elementCols] = gridIndxToRegionIndx( ...
    gridRows,gridCols)
arguments
    gridRows (:,1) double
    gridCols (:,1) double
end
nRows = numel(gridRows); nCols = numel(gridCols);
assert(nRows == nCols,"Number of row and column indices don't match.")

% push region to top left, + 0.5 to make room for the vertices
elementRows = gridRows - min(gridRows) + 1 + 0.5;
elementCols = gridCols - min(gridCols) + 1 + 0.5;

% top left vertex, top right, bottom left, bottom right
vertexCoords = [elementRows-0.5, elementCols-0.5; ...
    elementRows-0.5, elementCols+0.5; ...
    elementRows+0.5, elementCols-0.5; ...
    elementRows+0.5, elementCols+0.5];

vertexCoords = unique(vertexCoords, 'rows');
vertexRows = vertexCoords(:,1);
vertexCols = vertexCoords(:,2);
end



function distance = manhattanDistance(directions)
arguments
    directions (:,2)
end
distance = abs(directions(:,1)) + abs(directions(:,2));
end



function [endNodes,weights] = createEdgesAndWeights(nElements,elementRows,elementCols, ...
    directionTopLeft, directionTopRight,directionBottomLeft,directionBottomRight, ...
    coordsToNodeId, nodeIdToCoords)

endNodes = cell(nElements,1);
weights = cell(nElements,1);

for iElement = 1:nElements
    elementCoord = [elementRows(iElement), elementCols(iElement)];
    vertexCoordTopLeft = elementCoord + directionTopLeft;
    vertexCoordTopRight = elementCoord + directionTopRight;
    vertexCoordBottomLeft = elementCoord + directionBottomLeft;
    vertexCoordBottomRight = elementCoord + directionBottomRight;

    nodeIdTopLeft = coordsToNodeId({vertexCoordTopLeft});
    nodeIdTopRight = coordsToNodeId({vertexCoordTopRight});
    nodeIdBottomLeft = coordsToNodeId({vertexCoordBottomLeft});
    nodeIdBottomRight = coordsToNodeId({vertexCoordBottomRight});

    allVertexNodeIds = [nodeIdTopLeft,nodeIdTopRight,nodeIdBottomLeft,nodeIdBottomRight];

    % each vertex should of an element should have an edge to the all other vertices of
    % that element
    vertexNodeIdCombinations = nchoosek(allVertexNodeIds,2);
    endNodes{iElement} = vertexNodeIdCombinations;

    nEdges = height(vertexNodeIdCombinations);
    vertexCoords = nodeIdToCoords(vertexNodeIdCombinations);
    edgeDirections = vertcat(vertexCoords{:,2}) - vertcat(vertexCoords{:,1});
    edgeManhattanDistances = manhattanDistance(edgeDirections);

    if ~all(edgeManhattanDistances == 1 | edgeManhattanDistances == 2)
        error("Some edge manhattan distances invalid.")
    end

    % manhattan distance = 1 means cardinal directions, 2 means diagonals
    % assign different weights to differentiate them
    weightsThisElement = nan(nEdges,1);
    weightsThisElement(edgeManhattanDistances == 1) = 1;
    weightsThisElement(edgeManhattanDistances == 2) = 0.5;

    weights{iElement} = weightsThisElement;
end
end