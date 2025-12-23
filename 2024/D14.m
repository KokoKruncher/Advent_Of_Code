clear; clc; close all;

% file = "D14 Test.txt";
file = "D14 Data.txt";
inputText = readlines(file);
inputText(inputText == "") = [];

initialPositions = str2double(split(extractBetween(inputText, "p=", " v="), ",")).';
velocities = str2double(split(extractAfter(inputText, "v="), ",")).';

%% Part 1
if file == "D14 Data.txt"
    WIDTH = 101;
    HEIGHT = 103;
    SECONDS = 100;
elseif file == "D14 Test.txt"
    WIDTH = 11;
    HEIGHT = 7;
    SECONDS = 100;
else
    error("Unknown file: %s", file)
end

positions = mod(initialPositions + velocities * SECONDS, [WIDTH; HEIGHT]);

middleX = floor(WIDTH / 2);
middleY = floor(HEIGHT / 2);

inQuadrant1 = nnz(positions(1,:) < middleX & positions(2,:) < middleY);
inQuadrant2 = nnz(positions(1,:) > middleX & positions(2,:) < middleY);
inQuadrant3 = nnz(positions(1,:) < middleX & positions(2,:) > middleY);
inQuadrant4 = nnz(positions(1,:) > middleX & positions(2,:) > middleY);

safetyFactor = inQuadrant1 * inQuadrant2 * inQuadrant3 * inQuadrant4;

fprintf("Safety factor = %i\n", safetyFactor);

%% Part 2
% Heuristic: To form a christmas tree, each row will either have 0 or 1 contiguous blocks that have a robot.
positions = initialPositions;
nSeconds = 0;
foundTree = false;
while nSeconds <= 1e6
    nSeconds = nSeconds + 1;
    positions = mod(positions + velocities, [WIDTH; HEIGHT]);
    robotMap = createRobotMap(positions, WIDTH, HEIGHT);

    isTree = all(sum(diff(robotMap, 1, 2) ~= 0, 2) <= 2);
    if isTree
        foundTree = true;
        break
    end
end

% filePath = "Outputs/D14_Part2.txt";
% [fid, errorMessage] = fopen(filePath, 'w+');
% cleanupObj = onCleanup(@() fclose(fid));
% 
% if fid == -1
%     error("Couldn't open file!\nError Message: %s", errorMessage)
% end
% 
% positions = initialPositions;
% for nSeconds = 1:SECONDS_PART_2
%     positions = mod(positions + velocities, [WIDTH; HEIGHT]);
% 
%     robotMap = createVisualMap(positions, WIDTH, HEIGHT);
%     fprintf(fid, "t = %i:\n\n", nSeconds);
%     fprintf(fid, "%s\n\n", robotMap);
% end
% fclose(fid);

%% Functions
function robotMap = createRobotMap(positions, WIDTH, HEIGHT)
rows = positions(2,:) + 1;
cols = positions(1,:) + 1;

robotMap = zeros(HEIGHT, WIDTH);
iRobot = sub2ind([HEIGHT, WIDTH], rows, cols);
robotMap(iRobot) = 1;
end


function robotMap = createVisualMap(positions, WIDTH, HEIGHT)
rows = positions(2,:) + 1;
cols = positions(1,:) + 1;
nRobots = numel(rows);

robotMap = zeros(HEIGHT, WIDTH);
for ii = 1:nRobots
    thisRow = rows(ii);
    thisCol = cols(ii);
    robotMap(thisRow, thisCol) = robotMap(thisRow, thisCol) + 1;
end
robotMap = char(join(string(robotMap), ""));
robotMap(robotMap == '0') = '.';

robotMap = string(robotMap);
robotMap = join(robotMap, newline);
end