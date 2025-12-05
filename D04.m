clear; clc; close all;

positions = readlines("D04_Data.txt");
positions = positions(positions ~= "");

% positions = ["..@@.@@@@."; ...
%              "@@@.@.@.@@"; ...
%              "@@@@@.@.@@"; ...
%              "@.@@@@..@."; ...
%              "@@.@@@@.@@"; ...
%              ".@@@@@@@.@"; ...
%              ".@.@.@.@@@"; ...
%              "@.@@@.@@@@"; ...
%              ".@@@@@@@@."; ...
%              "@.@.@@@.@.";];

positions = string(num2cell(char(positions)));
isPaperRoll = positions == "@";

%% Part 1
convMatrix = ones(3, 3);
convMatrix(2,2) = 0;

nSurroundingRolls = conv2(double(isPaperRoll), convMatrix);
nSurroundingRolls = nSurroundingRolls(2:end-1, 2:end-1);

isReachable = nSurroundingRolls < 4 & isPaperRoll;
nReachableRolls = nnz(isReachable);

fprintf("Number of reachable paper rolls = %i\n", nReachableRolls);