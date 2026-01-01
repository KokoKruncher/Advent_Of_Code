clear; clc; close all;

file = "D25 Data.txt";
[locks, keys] = parseInput(file);

%% Part 1
nLocks = numel(locks);
nKeys = numel(keys);

combinationIndices = table2array(combinations(1:nLocks, 1:nKeys));
lockCombinationIndices = combinationIndices(:,1);
keyCombinationIndices = combinationIndices(:,2);

nCombinations = height(combinationIndices);
lockKeyPairs = cat(3, locks{lockCombinationIndices}) + cat(3, keys{keyCombinationIndices});
nValidPairs = nnz(~any(lockKeyPairs > 1, [1, 2]));

fprintf("Number of valid lock and key pairs = %i\n", nValidPairs)

%% Functions
function [locks, keys] = parseInput(file)
arguments
    file (1,1) string {mustBeFile}
end
lockDiagrams = readlines(file);
if lockDiagrams(end) == ""
    lockDiagrams(end) = [];
end

iSplit = find(lockDiagrams == "");
rowStart = [1; iSplit + 1];
rowEnd = [iSplit - 1; numel(lockDiagrams)];
nLocksAndKeys = numel(iSplit) + 1;

lockDiagrams = char(lockDiagrams);
isLock = all(lockDiagrams(rowStart,:) == '#', 2);
nLocks = nnz(isLock);
nKeys = nLocksAndKeys - nLocks;
locks = cell(nLocks, 1);
keys = cell(nKeys, 1);

iLock = 0;
iKey = 0;
for ii = 1:nLocksAndKeys
    thisLockOrKey = lockDiagrams(rowStart(ii):rowEnd(ii), :);

    % Top and bottom row are just to indicate whether lock or key, so can be discarded
    thisLockOrKey = thisLockOrKey(2:end-1, :);
    thisLockOrKey = thisLockOrKey == '#';

    if isLock(ii)
        iLock = iLock + 1;
        locks{iLock} = thisLockOrKey;
    else
        iKey = iKey + 1;
        keys{iKey} = thisLockOrKey;
    end
end
end