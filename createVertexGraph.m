function vertexGraph = createVertexGraph(vertexRows,vertexCols)
arguments
    vertexRows (:,1) double
    vertexCols (:,1) double
end

nRowIndx = numel(vertexRows);
nColIndx = numel(vertexCols);
assert(nRowIndx == nColIndx,"Number of row and column indices don't match.")

gridSize = [max(vertexRows), max(vertexCols)];
map = false(gridSize);
iVertex = sub2ind(gridSize,vertexRows,vertexCols);
map(iVertex) = true;

% create node table to ensure that nodes without edges (area = 1) are accounted for
nPoints = numel(map);
nodeTable = table();
[nodeRows,nodeCols] = ind2sub(size(map),1:nPoints);
nodeTable.iRow = nodeRows(:);
nodeTable.iCol = nodeCols(:);

edgeTable = table();
edgeTable.EndNodes = nan(8*nPoints,2);
edgeTable.Weights = nan(8*nPoints,1);
mapWidth = width(map);
mapHeight = height(map);
iNode = 0;
iEdge = 0;
for iWidth = 1:mapWidth
    for iHeight = 1:mapHeight
        % need to search all 4 directions plus diagonals to give info on whether it is on
        % the edges of the region or not
        point = map(iHeight,iWidth);
        iNode = iNode + 1;
        if ~point
            continue
        end
        
        % check up, down, left, right, edge weight 1
        if iHeight > 1 && map(iHeight-1,iWidth)
            iNodeUp = iNode - 1;
            iEdge = iEdge + 1;
            edgeTable.EndNodes(iEdge,:) = [iNode, iNodeUp];
            edgeTable.Weights(iEdge) = 1;
        end

        if iHeight < mapHeight && map(iHeight+1,iWidth)
            iNodeDown = iNode + 1;
            iEdge = iEdge + 1;
            edgeTable.EndNodes(iEdge,:) = [iNode, iNodeDown];
            edgeTable.Weights(iEdge) = 1;
        end

        if iWidth < mapWidth && map(iHeight,iWidth+1)
            iNodeRight = sub2ind([mapHeight,mapWidth],iHeight,iWidth+1);
            iEdge = iEdge + 1;
            edgeTable.EndNodes(iEdge,:) = [iNode, iNodeRight];
            edgeTable.Weights(iEdge) = 1;
        end

        if iWidth > 1 && map(iHeight,iWidth-1)
            iNodeLeft = sub2ind([mapHeight,mapWidth],iHeight,iWidth-1);
            iEdge = iEdge + 1;
            edgeTable.EndNodes(iEdge,:) = [iNode, iNodeLeft];
            edgeTable.Weights(iEdge) = 1;
        end

        % check diagonals, edge weight 0.5
        if iHeight > 1 && iWidth > 1 && map(iHeight-1,iWidth-1)
            iNodeTopLeft = sub2ind([mapHeight,mapWidth],iHeight-1,iWidth-1);
            iEdge = iEdge + 1;
            edgeTable.EndNodes(iEdge,:) = [iNode, iNodeTopLeft];
            edgeTable.Weights(iEdge) = 0.5;
        end

        if iHeight > 1 && iWidth < mapWidth && map(iHeight-1,iWidth+1)
            iNodeTopRight = sub2ind([mapHeight,mapWidth],iHeight-1,iWidth+1);
            iEdge = iEdge + 1;
            edgeTable.EndNodes(iEdge,:) = [iNode, iNodeTopRight];
            edgeTable.Weights(iEdge) = 0.5;
        end

        if iHeight < mapHeight && iWidth > 1 && map(iHeight+1,iWidth-1)
            iNodeBottomLeft = sub2ind([mapHeight,mapWidth],iHeight+1,iWidth-1);
            iEdge = iEdge + 1;
            edgeTable.EndNodes(iEdge,:) = [iNode, iNodeBottomLeft];
            edgeTable.Weights(iEdge) = 0.5;
        end

        if iHeight < mapHeight && iWidth < mapWidth && map(iHeight+1,iWidth+1)
            iNodeBottomRight = sub2ind([mapHeight,mapWidth],iHeight+1,iWidth+1);
            iEdge = iEdge + 1;
            edgeTable.EndNodes(iEdge,:) = [iNode, iNodeBottomRight];
            edgeTable.Weights(iEdge) = 0.5;
        end
    end
end
edgeTable = edgeTable(~any(isnan(edgeTable.EndNodes),2),:);
vertexGraph = graph(edgeTable,nodeTable);

% remove edges counted more than once
vertexGraph = simplify(vertexGraph);

% remove nodes that are not a vertex
isVertex = vertexGraph.degree > 1;
nNodes = vertexGraph.numnodes;
allNodeIds = 1:nNodes;
vertexGraph = vertexGraph.rmnode(allNodeIds(~isVertex));
end