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

%% Functions
function TF = isWithin(num, ranges)
TF = any((num >= ranges(:,1)) & (num <= ranges(:,2)), 1);
end