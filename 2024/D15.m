clear; clc;

filename = "D15 Data.txt";
data = readlines(filename);
[originalGrid,instructions] = parseData(data);

%% Part 1
tic
grid = originalGrid;
gridSize = size(grid);

dirKeys = ["^" ">" "v" "<"];
dirValues = {[-1 0], [0 1], [1 0], [0 -1]};
direction = dictionary(dirKeys,dirValues);

% replace initial location with free space to simplify operations
initialLocationLinearIndx = find(grid == "@");
[location(1),location(2)] = ind2sub(gridSize,initialLocationLinearIndx);
grid(initialLocationLinearIndx) = ".";

[endLocation, grid] = moveRobot(instructions, direction, location, grid);
sumBoxGpsCoordinates = calculateSumGpsCoordinates(grid,"O");

fprintf("Sum of box GPS coordinates: %i\n\n",sumBoxGpsCoordinates)
toc

%% Part 2
tic
newGrid = createNewGrid(originalGrid,initialLocationLinearIndx);
newGridSize = size(newGrid);

initialLocationLinearIndx = find(newGrid == "@");
[location(1),location(2)] = ind2sub(newGridSize,initialLocationLinearIndx);
newGrid(initialLocationLinearIndx) = ".";

[newEndLocation,newGrid] = moveRobot(instructions,direction,location,newGrid);
newSumBoxGpsCoordinates = calculateSumGpsCoordinates(newGrid,"[");

fprintf("\nSum of box GPS coordinates in new warehouse: %i\n",newSumBoxGpsCoordinates)
toc

%% Functions
function [location, grid] = moveRobot(instructions, direction, location, grid, args)
arguments
    instructions (:,1) string
    direction (1,1) dictionary
    location (1,2) double
    grid (:,:) string
    args.bPrint (1,1) logical = false
end
bPrint = args.bPrint;
gridWidth = width(grid);

if bPrint
    if ~isfolder("Outputs")
        mkdir("Outputs");
    end
    filename = "Outputs/D15.txt";
    iterationSeparator = repmat("-",[1 gridWidth]);

    if isfile(filename)
        delete(filename);
    end
end

for instruction = instructions(:)'
    thisDirection = direction{instruction};
    [canMove,locationsToShift] = checkIfCanMove(location,thisDirection,grid,{});
    
    if ~canMove
        continue
    end
    
    location = location + thisDirection;
    if ~isempty(locationsToShift)
        grid = shiftBoxes(locationsToShift,thisDirection,grid);
    end

    if bPrint
        gridToPrint = [grid; iterationSeparator];
        gridToPrint(location(1),location(2)) = "@";
        writematrix(gridToPrint,filename,"WriteMode","append");
    end
end
end



function [canMove,locationsToShift] = checkIfCanMove(location,thisDirection,grid, ...
    locationsToShift)
nextLocation = location + thisDirection;
nextGridSpot = grid(nextLocation(1),nextLocation(2));

if nextGridSpot == "."
    canMove = true;
elseif nextGridSpot == "O"
    % recurse over all boxes in front of robot
    locationsToShift = [locationsToShift, {nextLocation}];
    [canMove,locationsToShift] = checkIfCanMove(nextLocation,thisDirection, ...
        grid,locationsToShift);
elseif ismember(nextGridSpot,["[" "]"])
    % recursively check connected boxes
    [locationsToShift,canMove] = checkConnectedBoxes(nextLocation,thisDirection,grid, ...
        nextGridSpot,{});
elseif nextGridSpot == "#"
    canMove = false;
else
    error("Unknown grid spot: %s",nextGridSpot)
end
end



function [boxLocations,canMove] = checkConnectedBoxes(location,robotDirection,grid, ...
    gridSpot,boxLocations)
thisBoxLocations = {location};

isRobotGoingEastWest = all(robotDirection == [0 1]) || all(robotDirection == [0 -1]);
if isRobotGoingEastWest
    % robot travelling east or west, other part of the box is one step ahead
    newBoxLocation = location + robotDirection;
elseif gridSpot == "["
    % robot travelling north or south. "]" is located east of here.
    newBoxLocation = location + [0 1];
elseif gridSpot == "]"
    % robot travelling north or south. "[" is located west of here.
    newBoxLocation = location + [0 -1];
else
    error("Unknown condition.")
end
thisBoxLocations = [thisBoxLocations, {newBoxLocation}];
boxLocations = [boxLocations, thisBoxLocations];

% which locations ahead of box to check
if isRobotGoingEastWest
    locationsToCheck = {location + 2*robotDirection};
else
    locationsToCheck = cellfun(@(x) x + robotDirection,thisBoxLocations, ...
        'UniformOutput',false);
end

% check locations ahead
canMove = true;
nLocationsToCheck = numel(locationsToCheck);
for i = 1:nLocationsToCheck
    if canMove == false
        break
    end

    locationToCheck = locationsToCheck{i};
    gridSpotToCheck = grid(locationToCheck(1),locationToCheck(2));
    if ismember(gridSpotToCheck,["[" "]"])
        % recursively check all boxes ahead
        [boxLocations,canMove] = checkConnectedBoxes(locationToCheck,robotDirection, ...
            grid,gridSpotToCheck,boxLocations);
        continue
    end
    
    % if not a box, check if wall or free space, input previous location to check this
    % location
    [canMove,~] = checkIfCanMove(locationToCheck - robotDirection, ...
        robotDirection,grid,boxLocations);
end
end



function newGrid = shiftBoxes(locationsToShift,thisDirection,grid)
nLocationsToShift = numel(locationsToShift);
shiftedLocations = cellfun(@(x) x + thisDirection,locationsToShift,'UniformOutput',false);

% clear out all box locations on new grid first
newGrid = grid;
for i = 1:nLocationsToShift
    thisLocation = locationsToShift{i};
    newGrid(thisLocation(1),thisLocation(2)) = ".";
end

% copy shifted box locations onto new grid
for i = 1:nLocationsToShift
    thisLocation = locationsToShift{i};
    nextLocation = shiftedLocations{i};

    thisBox = grid(thisLocation(1),thisLocation(2));
    newGrid(nextLocation(1),nextLocation(2)) = thisBox;
end
end



function sumGpsCoordinates = calculateSumGpsCoordinates(grid,gridType)
locationsLinearIndx = find(grid == gridType);
[rows,cols] = ind2sub(size(grid),locationsLinearIndx);

distancesFromTopEdge = rows - 1;
distancesFromLeftEdge = cols - 1;
gpsCoordinates = (100*distancesFromTopEdge) + distancesFromLeftEdge;
sumGpsCoordinates = sum(gpsCoordinates,"all");
end



function newGrid = createNewGrid(grid,initialLocationLinearIndx)
grid(initialLocationLinearIndx) = "@";
newGrid = join(grid,"");

newGrid = replace(newGrid,"#","##");
newGrid = replace(newGrid,"O","[]");
newGrid = replace(newGrid,".","..");
newGrid = replace(newGrid,"@","@.");

newGrid = split(newGrid,"");
newGrid = newGrid(:,2:end-1);
end



function [grid,instructions] = parseData(data)
indxEmptyLine = find(data == "");

gridString = data(1:indxEmptyLine-1);
gridString = split(gridString,"");
gridString = gridString(:,2:end-1);

% combine all instructions into one line
instructionsString = data(indxEmptyLine+1:end);
instructionsString = join(instructionsString,"");
instructionsString = split(instructionsString,"");
instructionsString = instructionsString(instructionsString ~= "");

grid = gridString;
instructions = instructionsString;
end