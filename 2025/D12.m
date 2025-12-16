clear; clc; close all;

inputText = readlines("D12_Data.txt");
[Presents, Regions] = parseInput(inputText);

%% Part 1
% Reference:
% https://youtu.be/DHtNCDnwOLA?si=JVmJ07XRVZuQVtmk

nRegions = numel(Regions);
for ii = 1:nRegions
    Regions(ii).isFailed = false;
    Regions(ii).isTrivial = false;

    Regions(ii).areaRequest = sum(Regions(ii).presentRequests .* [Presents.area]);
    % Count the number of filled 3x3 grids that can fit in the region. If this number is less than the number of
    % presents requested, then the problem is trivial, i.e. you can just put each present next to another without any
    % interlocking of the presents; shapes.
    Regions(ii).n3x3GridsPossible = prod(floor(Regions(ii).size ./ 3));

    if Regions(ii).areaRequest > Regions(ii).area
        Regions(ii).isFailed = true;
        continue
    end

    
    if Regions(ii).n3x3GridsPossible >= sum(Regions(ii).presentRequests)
        Regions(ii).isTrivial = true;
    end
end

nRegionsToBeSolved = nnz(~[Regions.isTrivial] & ~[Regions.isFailed]);
if nRegionsToBeSolved == 0
    % All solvable regions are trivial
    fprintf("Number of regions that can fit all the presents = %i\n", nnz([Regions.isTrivial]));
else
    fprintf("Need to solve %i regions\n", nRegionsToBeSolved);
end

%% (NO PART 2)

%% Functions
function [Presents, Regions] = parseInput(inputText)
if inputText(end) == ""
    inputText(end) = [];
end

presentsText = inputText(1:find(contains(inputText, ("#"|".")), 1, "last"));
regionsText = inputText(contains(inputText, digitsPattern + "x" + digitsPattern + ":"));

isPresentIndex = contains(presentsText, ":");
Presents = struct();
nRows = numel(presentsText);
for ii = 1:nRows
    if ~isPresentIndex(ii)
        continue
    end
    
    thisLine = presentsText(ii);
    iPresent = str2double(extractBefore(thisLine, ":")) + 1;
    iLineTop = ii + 1;
    iLineBottom = find((1:nRows).' > ii & presentsText == "", 1, "first") - 1;
    if isempty(iLineBottom)
        iLineBottom = nRows;
    end
    
    shape = char(presentsText(iLineTop:iLineBottom)) == '#';
    Presents(iPresent).shape = shape;
    Presents(iPresent).area = nnz(shape);
end

nRegions = numel(regionsText);
Regions = repmat(struct(), nRegions, 1);
regionSizes = num2cell(str2double(split(extractBefore(regionsText, ":"), "x")), 2);
regionPresentRequests = num2cell(str2double(split(extractAfter(regionsText, ": "))), 2);
[Regions(:).size] = regionSizes{:};
[Regions(:).presentRequests] = regionPresentRequests{:};
for ii = 1:nRegions
    Regions(ii).area = prod(Regions(ii).size);
end
end