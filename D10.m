clear; clc;

filename = "D10 Data.txt";
data = readlines(filename);

%% Part 1
tic
topographicMap = splitAndConvertMap(data);
trailHeadLinearIndx = find(topographicMap == 0);
nTrailHeads = numel(trailHeadLinearIndx);
mapSize = size(topographicMap);

trailHeadScores = nan(nTrailHeads,1);
for iTrailHead = 1:nTrailHeads
    peaksReachable = false(mapSize); % reset for each trailhead
    [rowTrailHead,colTrailHead] = ind2sub(mapSize,trailHeadLinearIndx(iTrailHead));
    startingLocation = [rowTrailHead,colTrailHead];

    [peaksReachable,pathNum,nPathsToPeaks,locationsTravelled,nLocationsTravelled] = ...
        traverseMap(startingLocation,peaksReachable,topographicMap,mapSize);
    
    nPeaksReachable = sum(peaksReachable,"all");
    trailHeadScores(iTrailHead) = nPeaksReachable;
end

sumTrailHeadScores = sum(trailHeadScores,"all");
fprintf("Score = %i\n",sumTrailHeadScores)
toc



function [peaksReachable,pathNum,nPathsToPeaks,locationsTravelled,nLocationsTravelled] ...
    = traverseMap(location,peaksReachable,topographicMap,mapSize, ...
    pathNum,nPathsToPeaks,locationsTravelled,nLocationsTravelled,direction)
arguments
    location (1,2) double
    peaksReachable (:,:) logical
    topographicMap (:,:) double
    mapSize (1,2) double
    pathNum (1,1) double = 0
    nPathsToPeaks (1,1) double = 0
    locationsTravelled (:,2) double  = nan(numel(topographicMap),2)
    nLocationsTravelled (1,1) double = 0;
    direction (1,2) double = nan(1,2);
end
% add location to locations travelled
nLocationsTravelled = nLocationsTravelled + 1;
locationsTravelled(nLocationsTravelled,:) = location;

% check if is peak
isPeak = checkIfLocationIsPeak(location,topographicMap);
if isPeak
    [peaksReachable,nPathsToPeaks] = addPeak(location,peaksReachable,nPathsToPeaks);
    return
end

if isnan(direction)
    % set initial direction to south and check all directions
    direction = [1,0];
    nDirectionsToCheck = 4;
else
    nDirectionsToCheck = 3;
end
 
directionToPrevLocation = -direction;
nBranches = -1; % so that if path just continues in 1 direction, pathNum doesn't increment
for iDirection = 1:nDirectionsToCheck
    thisDirection = rotateDirection(directionToPrevLocation,iDirection);
    isDirectionValid = checkDirection(location,topographicMap,mapSize, ...
        locationsTravelled,thisDirection);

    if ~isDirectionValid
        continue
    end
    
    % increment pathNum only if a new brannch is formed
    nBranches = nBranches + 1;
    pathNum = pathNum + nBranches;
    
    % recurse
    newLocation = location + thisDirection;
    [peaksReachable,pathNum,nPathsToPeaks,locationsTravelled,nLocationsTravelled] ...
    = traverseMap(newLocation,peaksReachable,topographicMap,mapSize, ...
    pathNum,nPathsToPeaks,locationsTravelled,nLocationsTravelled,thisDirection);
end
end



function isDirectionValid = checkDirection(location,topographicMap,mapSize, ...
        locationsTravelled,thisDirection)
newLocation = location + thisDirection;
isDirectionValid = false;

isNewLocationInBounds = checkIfLocationIsInBounds(newLocation,mapSize);
if ~isNewLocationInBounds
    return
end

isLocationUntravelled = checkIfLocationIsUntravelled(newLocation,locationsTravelled);
if ~isLocationUntravelled
    return
end


isSlopeGradualUphill = checkIfSlopeIsGradualUphill(location,newLocation,topographicMap);
if ~isSlopeGradualUphill
    return
end

isDirectionValid = true;
end



function isLocationUntravelled = checkIfLocationIsUntravelled(location,locationsTravelled)
isLocationTravelled = ismember(location,locationsTravelled,'rows');
isLocationUntravelled = ~isLocationTravelled;
end



function isSlopeGradualUphill = checkIfSlopeIsGradualUphill(location,newLocation,topographicMap)
currentRow = location(1);
currentCol = location(2);
currentHeight = topographicMap(currentRow,currentCol);

newRow = newLocation(1);
newCol = newLocation(2);
newHeight = topographicMap(newRow,newCol);

slope = newHeight - currentHeight;
if slope == 1
    isSlopeGradualUphill = true;
else
    isSlopeGradualUphill = false;
end
end



function isLocationInBounds = checkIfLocationIsInBounds(location,mapSize)
if location(1) < 1 || location(1) > mapSize(1) || ...
        location(2) < 1 || location(2) > mapSize(2)
    isLocationInBounds = false;
else
    isLocationInBounds = true;
end
end



function newDirection = rotateDirection(direction,nTimes)
rotationMatrix = [0, 1; -1, 0];
newDirection = ((rotationMatrix^nTimes)*direction')';
end



function [peaksReachable,nPathsToPeaks] = addPeak(location,peaksReachable,nPathsToPeaks)
row = location(1);
col = location(2);
peaksReachable(row,col) = true;
nPathsToPeaks = nPathsToPeaks + 1;
end



function isPeak = checkIfLocationIsPeak(location,topographicMap)
row = location(1);
col = location(2);
height = topographicMap(row,col);
if height == 9
    isPeak = true;
else
    isPeak = false;
end
end



function map = splitAndConvertMap(map)
arguments
    map (:,1) {mustBeA(map,'string')}
end
map = split(map,"");
map = map(:,2:end-1);
map = str2double(map);
end