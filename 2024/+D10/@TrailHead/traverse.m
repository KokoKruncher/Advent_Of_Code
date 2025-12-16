function traverse(self,location,direction)
arguments
    self D10.TrailHead
    location (1,2) double
    direction (1,2) double = nan(1,2)
end
% add location to locations travelled
self.nLocationsTravelled = self.nLocationsTravelled + 1;
self.locationsTravelled(self.nLocationsTravelled,:) = location;

% check if is peak
isPeak = self.checkIfLocationIsPeak(location);
if isPeak
    self.addPeak(location);
    return
end

if isnan(direction)
    % set initial direction to south and check all directions
    direction = [1,0];
    nDirectionsToCheck = 4;
else
    nDirectionsToCheck = 3; % check directions except the direction it came from
end

directionToPrevLocation = -direction;
nBranches = -1; % so that if path just continues in 1 direction, pathNum doesn't increment
for iDirection = 1:nDirectionsToCheck
    thisDirection = self.rotateDirection(directionToPrevLocation,iDirection);
    isDirectionValid = self.checkDirection(location,thisDirection);

    if ~isDirectionValid
        continue
    end

    % increment pathNum only if a new branch is formed
    nBranches = nBranches + 1;
    if nBranches >= 1
        self.pathNum = self.pathNum + 1;
    end

    % recurse
    newLocation = location + thisDirection;
    self.traverse(newLocation,thisDirection);
end
end
