clear; clc;

%% Part 1
filename = "D9 Data.txt";
diskMap = readlines(filename);

blocks = decodeDiskMap(diskMap);
compactedBlocksIndividual = compactDiskIndividualFileBlocks(blocks);
checksumIndividualMethod = calculateChecksum(compactedBlocksIndividual);
fprintf("Checksum (individual method): %i \n\n",checksumIndividualMethod)

%% Part 2
tic
[fileIds,fileStartingPositions,fileBlockSizes,nFiles] = parseDiskMap(diskMap);
fileStartingPositions = compactDiskWholeFileBlocks(nFiles,fileStartingPositions,fileBlockSizes);
checksumWholeMethod = calculateChecksumFromPositions(fileStartingPositions, ...
    fileBlockSizes, nFiles, fileIds);
toc
fprintf("Checksum (whole method): %i\n",checksumWholeMethod);


function fileStartingPositions = compactDiskWholeFileBlocks(nFiles, ...
    fileStartingPositions,fileBlockSizes)
% use their positions (fast) instead of manipulating the actual blocks (slow)

% reverse order from largest file ID to to smallest
for iFile = nFiles:-1:1
    thisFileStartingPosition = fileStartingPositions(iFile);
    thisFileBlockSize = fileBlockSizes(iFile);
    
    [gapSizes,gapStartingPositions] = calculateGaps(fileStartingPositions,fileBlockSizes);
    
    % only look at gaps before this file
    indxGapsBeforeThisFile = gapStartingPositions < thisFileStartingPosition;
    gapSizes = gapSizes(indxGapsBeforeThisFile);
    gapStartingPositions = gapStartingPositions(indxGapsBeforeThisFile);
    indxGapsBigEnough = gapSizes >= thisFileBlockSize;
    if ~any(indxGapsBigEnough)
        continue
    end
    validGapStartingPositions = gapStartingPositions(indxGapsBigEnough);
    
    % choose left-most position
    fileStartingPositions(iFile) = validGapStartingPositions(1);
end
end



function [gapSizes,gapStartingPositions] = calculateGaps(fileStartingPositions,fileBlockSizes)
[fileStartingPositions,sortOrder] = sort(fileStartingPositions);
fileBlockSizes = fileBlockSizes(sortOrder);

fileStoppingPositions = fileStartingPositions + fileBlockSizes - 1;
gapStartingPositions = fileStoppingPositions(1:end-1) + 1;
gapSizes = fileStartingPositions(2:end) - fileStoppingPositions(1:end-1) - 1;

indxZeroGaps = gapSizes == 0;
gapSizes(indxZeroGaps) = [];
gapStartingPositions(indxZeroGaps) = [];
end


function [fileIds,fileStartingPositions,fileBlockSizes,nFiles] = parseDiskMap(diskMap)
diskMapNums = str2double(splitStringIntoArray(diskMap));
startingPositions = cumsum(diskMapNums);
startingPositions(end) = [];
startingPositions = [0 startingPositions];
nGroups = numel(startingPositions);

fileStartingPositions = startingPositions(1:2:nGroups);
nFiles = numel(fileStartingPositions);
fileIds = 0:(nFiles - 1);
fileBlockSizes = diskMapNums(1:2:nGroups);
end



function blocks = decodeDiskMap(diskMap)
% don't join the blocks into single string as fileIDs could have multiple digits!

fprintf("[%s] - Decoding disk map.\n",datetime)
diskMap = splitStringIntoArray(diskMap);
diskMap = str2double(diskMap);

nDiskMapElements = numel(diskMap);
blocks = cell(size(diskMap));

% handle files
fileId = 0;
for i = 1:2:nDiskMapElements
    nBlocksThisFile = diskMap(i);
    blocks{i} = repelem(string(fileId),1,nBlocksThisFile);
    fileId = fileId + 1;
end

% handle free spaces
for i = 2:2:nDiskMapElements
    nBlocksThisFreeSpace = diskMap(i);
    blocks{i} = repelem(".",1,nBlocksThisFreeSpace);
end

indxEmptyStrings = cellfun(@isempty,blocks);
blocks(indxEmptyStrings) = [];

blocks = [blocks{:}];
end



function splitString = splitStringIntoArray(str)
assert(numel(str) == 1);
splitString = split(str,"")';
splitString = splitString(2:end-1);
end



function blocks = compactDiskIndividualFileBlocks(blocks)
locLastFileBlock = find(blocks ~= ".",1,"last");
locFirstFreeSpaceBlock = find(blocks == ".",1,"first");

fprintf("[%s] - Compacting disk (individual file blocks).\n",datetime)
nIterations = 0;
while locLastFileBlock > locFirstFreeSpaceBlock
    nIterations = nIterations + 1;
    lastFileBlock = blocks(locLastFileBlock);
    firstFreeSpaceBlock = blocks(locFirstFreeSpaceBlock);

    blocks(locFirstFreeSpaceBlock) = lastFileBlock;
    blocks(locLastFileBlock) = firstFreeSpaceBlock;

    locLastFileBlock = find(blocks ~= ".",1,"last");
    locFirstFreeSpaceBlock = find(blocks == ".",1,"first");
end
fprintf("[%s] - Compacting disk done. Iterations: %i\n",datetime,nIterations)
end



function checksum = calculateChecksum(blocks)
assert(numel(blocks) > 1 && isvector(blocks));

blocks(blocks == ".") = "0"; % skip free space blocks
blocks = str2double(blocks);
nBlocks = numel(blocks);
blockPositions = 0:(nBlocks - 1);
multiplicationResult = blockPositions.*blocks;
checksum = sum(multiplicationResult,"all");
end

function checksum = calculateChecksumFromPositions(fileStartingPositions, ...
    fileBlockSizes,nFiles, fileIds)

[maxFileStartingPosition,locMaxFileStartingPosition] = max(fileStartingPositions);

% -1 for fence posting but + 1 because positions start at 0
nBlocks = maxFileStartingPosition + fileBlockSizes(locMaxFileStartingPosition) - 1 + 1;
fileStoppingPositions = fileStartingPositions + fileBlockSizes - 1;
blocks = zeros(1,nBlocks);
positions = 0:nBlocks-1;
for iFile = 1:nFiles
    % add 1 for MATLAB indicing because positions start at 0
    thisFileStartingPosition = fileStartingPositions(iFile) + 1;
    thisFileStoppingPosition = fileStoppingPositions(iFile) + 1;
    blocks(thisFileStartingPosition:thisFileStoppingPosition) = fileIds(iFile);
end
checksum = sum(positions.*blocks,"all");
end