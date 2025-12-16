clear; clc; close all;

coords = readlines("D09_Data.txt");
coords = coords(coords ~= "");
coords = split(coords, ",");
coords = str2double(coords);

%% Part 1
iHull = convhull(coords(:,1), coords(:,2));
iHull = iHull(1:end-1);

candidates = coords(iHull,:);
nCandidates = height(candidates);

pairs = nchoosek(1:nCandidates, 2);
areas = squareAreas(candidates(pairs(:,1),:), candidates(pairs(:,2),:));
maxArea = max(areas);

fprintf("Max area, part 1 = %i\n", maxArea);

%% Part 2
tic

boundaryShape = polyshape(coords(:,1), coords(:,2));

nCoords = height(coords);
pairs = nchoosek(1:nCoords, 2);
startCorners = coords(pairs(:,1),:);
endCorners = coords(pairs(:,2),:);
areas = squareAreas(startCorners, endCorners);

[areas, iSort] = sort(areas, "descend");
startCorners = startCorners(iSort,:);
endCorners = endCorners(iSort,:);

% Start, Start-Vertical, End, End-Vertical
allCornersX = [startCorners(:,1), startCorners(:,1), endCorners(:,1), endCorners(:,1)];
allCornersY = [startCorners(:,2), endCorners(:,2), endCorners(:,2), startCorners(:,2)];
nSquares = height(pairs);

% Ignore warnings about empty polyshapes.
% Can't be arsed to use vertex coordinates instead of center coordinates to make lines have > 0 area.
% Heuristic based on plotting the boundary is that these lines won't be the solution for maximum area anyway.
warning("off");
for iMaxArea = 1:nSquares
    square = polyshape(allCornersX(iMaxArea,:), allCornersY(iMaxArea,:));
    nonIntersectingArea = square.xor(boundaryShape);
    areaOutsideBoundary = nonIntersectingArea.subtract(boundaryShape);
    isWithinBoundary = areaOutsideBoundary.NumRegions == 0;

    if isWithinBoundary
        break
    end
end
warning("on");

maxArea = areas(iMaxArea);

toc

fprintf("Max area, part 2 = %i\n", maxArea);

%% Functions
function areas = squareAreas(startCorners, endCorners)
dx = abs(startCorners(:,1) - endCorners(:,1));
dy = abs(startCorners(:,2) - endCorners(:,2));
areas = (dx + 1) .* (dy + 1);
end

