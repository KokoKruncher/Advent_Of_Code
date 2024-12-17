clear; clc;
import D5.*
%% Part 1
filename = "D6 Data.txt";
data = readlines(filename);

map = Map(data);

tic
while map.guard.isInBounds
    map.step();
end
toc
map.exportGrid();

nDistinctPositions = sum(map.pathWalked,"all");
fprintf("Number of distinct positions: %i\n", nDistinctPositions)