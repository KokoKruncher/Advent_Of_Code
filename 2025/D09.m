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

nRedCoords = height(coords);
boundaryCoords = cell(nRedCoords, 1);
for ii = 1:nRedCoords
    currPoint = coords(ii,:);
    if ii == nRedCoords
        nextPoint = coords(1,:);
    else
        nextPoint = coords(ii+1,:);
    end

    boundaryCoords{ii} = pointsBetween(currPoint, nextPoint);
end

boundaryCoords = vertcat(boundaryCoords{:});
boundaryCoords = unique(boundaryCoords, 'rows', 'stable');
boundaryCoords = dictionary(num2cell(boundaryCoords, 2), true);

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

for iMaxArea = 1:nSquares
    corners = [allCornersX(iMaxArea,:).', allCornersY(iMaxArea,:).'];
    
    if ~squareExitsBoundary(corners, boundaryCoords)
        break
    end

    if iMaxArea == nSquares
        error("Didn't find any valid squares!")
    end
end
maxArea = areas(iMaxArea);
fprintf("Max area, part 2 = %i\n", maxArea);

toc

%
% % Ignore warnings about empty polyshapes.
% % Can't be arsed to use vertex coordinates instead of center coordinates to make lines have > 0 area.
% % Heuristic based on plotting the boundary is that these lines won't be the solution for maximum area anyway.
% warning("off");
% for iMaxArea = 1:nSquares
%     square = polyshape(allCornersX(iMaxArea,:), allCornersY(iMaxArea,:));
%     nonIntersectingArea = square.xor(boundaryShape);
%     areaOutsideBoundary = nonIntersectingArea.subtract(boundaryShape);
%     isWithin = areaOutsideBoundary.NumRegions == 0;
%
%     if isWithin
%         break
%     end
% end
% warning("on");
%
% maxArea = areas(iMaxArea);
%
% toc
%
% fprintf("Max area, part 2 = %i\n", maxArea);

% fprintf("%i\n", isWithinBoundary([6, 2], boundaryCoords))
% fprintf("%i\n", isWithinBoundary([7, 2], boundaryCoords))
% fprintf("%i\n", isWithinBoundary([8, 2], boundaryCoords))

%% Functions
function areas = squareAreas(startCorners, endCorners)
dx = abs(startCorners(:,1) - endCorners(:,1));
dy = abs(startCorners(:,2) - endCorners(:,2));
areas = (dx + 1) .* (dy + 1);
end


function points = pointsBetween(currPoint, nextPoint)
delta = nextPoint - currPoint;
nPoints = vecnorm(delta) + 1;
points = [linspace(currPoint(1), nextPoint(1), nPoints).', linspace(currPoint(2), nextPoint(2), nPoints).'];
end


function TF = isOnBoundary(points, boundaryCoords)

% TF = ismember(points, boundaryCoords, 'rows');
nPoints = height(points);
TF = false(nPoints, 1);
for ii = 1:nPoints
    TF(ii) = boundaryCoords.isKey({points(ii,:)});
end
end



function TF = isWithinBoundary(point, boundaryCoords)
persistent maxX cache

if isempty(maxX)
   allBoundaryPoints = vertcat(boundaryCoords.keys{:});
   maxX = max(allBoundaryPoints(:,1));
end

if isempty(cache)
    cache = dictionary();
end

if cache.isConfigured() && cache.isKey({point})
    TF = cache({point});
    return
end

if boundaryCoords.isKey({point})
    TF = true;
    return
end

% Cast ray to the right
if point(1) > maxX
    TF = false;
    return
end

xToCheck = (point(1):(maxX + 1)).';
yToCheck = point(2);

pointsToCheck = xToCheck;
pointsToCheck(:,2) = yToCheck;

% isIntersectingBoundary = ismember(pointsToCheck, boundaryCoords, "rows");
isIntersectingBoundary = isOnBoundary(pointsToCheck, boundaryCoords);
nBoundaryCrossings = nnz(diff(isIntersectingBoundary) > 0);
if mod(nBoundaryCrossings, 2) == 0
    TF = false;
else
    TF = true;
end

cache({point}) = TF;
end


function TF = squareExitsBoundary(corners, boundaryCoords)
TF = true;

for iCorner = 1:4
    currPoint = corners(iCorner,:);
    if iCorner == 4
        nextPoint = corners(1,:);
    else
        nextPoint = corners(iCorner+1,:);
    end

    pointsToCheck = pointsBetween(currPoint, nextPoint);
    pointsToCheck = pointsToCheck(2:end-1,:);

    if isempty(pointsToCheck)
        continue
    end

    % Cast a ray to the next corner
    nPointsToCheck = height(pointsToCheck);
    hasHitBoundary = false;
    for iPoint = 1:nPointsToCheck
        % fprintf("%i\n", iPoint)
        thisPoint = pointsToCheck(iPoint,:);

        % Make sure our ray isn't starting outside the boundary already
        if iPoint == 1 && ~isWithinBoundary(thisPoint, boundaryCoords)
            return
        end
        
        if boundaryCoords.isKey({thisPoint})
            hasHitBoundary = true;
            continue
        end

        if hasHitBoundary && ~isWithinBoundary(thisPoint, boundaryCoords)
            % Exited the boundary
            return
        end

        % Just glanced the boundary but is still inside it afterwards
        hasHitBoundary = false;
    end
end

TF = false;
end