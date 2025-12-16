clear; clc; close all;

positions = readlines("D04_Data.txt");
positions = positions(positions ~= "");
positions = string(num2cell(char(positions)));
isPaperRoll = positions == "@";

%% Part 1
convMatrix = ones(3, 3);
convMatrix(2,2) = 0;

nSurroundingRolls = conv2(isPaperRoll, convMatrix);
nSurroundingRolls = nSurroundingRolls(2:end-1, 2:end-1);

isReachable = nSurroundingRolls < 4 & isPaperRoll;
nReachableRolls = nnz(isReachable);

fprintf("Number of reachable paper rolls = %i\n", nReachableRolls);

%% Part 2
nOriginalRolls = nnz(isPaperRoll);
while nReachableRolls > 0
    isPaperRoll = isPaperRoll .* ~isReachable;
    nSurroundingRolls = conv2(isPaperRoll, convMatrix);
    nSurroundingRolls = nSurroundingRolls(2:end-1, 2:end-1);

    isReachable = nSurroundingRolls < 4 & isPaperRoll;
    nReachableRolls = nnz(isReachable);
end
nCurrentRolls = nnz(isPaperRoll);
nRemovableRolls = nOriginalRolls - nCurrentRolls;

fprintf("Number of removable paper rolls = %i\n", nRemovableRolls);