function [vertexRows,vertexCols] = gridIndxToVertex(rows,cols)
arguments
    rows (:,1) double
    cols (:,1) double
end
nRows = numel(rows); nCols = numel(cols);
assert(nRows == nCols,"Number of row and column indices don't match.")

% push region to top left, + 0.5 to make room for the vertices
rows = rows - min(rows) + 1 + 0.5;
cols = cols - min(cols) + 1 + 0.5;

% top left vertex, top right, bottom left, bottom right
vertexCoords = [rows-0.5, cols-0.5; ...
                rows-0.5, cols+0.5; ...
                rows+0.5, cols-0.5; ...
                rows+0.5, cols+0.5];

vertexCoords = unique(vertexCoords, 'rows');
vertexRows = vertexCoords(:,1);
vertexCols = vertexCoords(:,2);
end