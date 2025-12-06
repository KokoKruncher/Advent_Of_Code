clear; clc; close all;

data = readlines("D05_Data.txt");
% data = ["3-5"; ...
%         "10-14"; ...
%         "16-20"; ...
%         "12-18"; ...
%         ""; ...
%         "1"; ...
%         "5"; ...
%         "8"; ...
%         "11"; ...
%         "17"; ...
%         "32"];

iSplit = find(data == "");
freshIdRanges = data(1:iSplit-1);
freshIdRanges = str2double(split(freshIdRanges, "-"));
ids = str2double(data(iSplit+1:end));

%% Part 1
nIds = numel(ids);
isFresh = false(size(ids));

for ii = 1:nIds
    if isWithin(ids(ii), freshIdRanges)
        isFresh(ii) = true;
    end
end
nFreshIngredients = nnz(isFresh);

fprintf("Number of fresh ingredients = %i\n", nFreshIngredients);

%% Part 2
nRanges = height(freshIdRanges);
rangeMin = freshIdRanges(:,1);
rangeMax = freshIdRanges(:,2);

for ii = 2:nRanges
    [isMinSeen, iMinSeen] = isWithin(rangeMin(ii), freshIdRanges(1:ii-1,:));
    if isMinSeen
        assert(numel(iMinSeen) == 1, "One or more of the previous ranges weren't merged properly.")
        freshIdRanges = removeRedundantRange(freshIdRanges, iMinSeen, ii);
    end

    [isMaxSeen, iMaxSeen] = isWithin(rangeMax(ii), freshIdRanges(1:ii-1,:));
    if isMaxSeen
        assert(numel(iMaxSeen) == 1, "One or more of the previous ranges weren't merged properly.")
        freshIdRanges = removeRedundantRange(freshIdRanges, iMaxSeen, ii);
    end
end
nFreshIds = sum(freshIdRanges(:,2) - freshIdRanges(:,1) + 1, "omitnan");

fprintf("Number of fresh ingredient IDs = %i\n", nFreshIds);

%% Functions
function [TF, iWithin] = isWithin(num, ranges)
bWithin = (num >= ranges(:,1)) & (num <= ranges(:,2));
TF = any(bWithin);
iWithin = find(bWithin);
end


function ranges = removeRedundantRange(ranges, oldRow, newRow)
if ranges(newRow,1) > ranges(oldRow,1)
    ranges(newRow,1) = ranges(oldRow,1);
end

if ranges(newRow,2) < ranges(oldRow,2)
    ranges(newRow,2) = ranges(oldRow,2);
end

ranges(oldRow,:) = nan;
end