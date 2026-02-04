clear; clc; close all;

inputText = readlines("D19 Data.txt");
if inputText(end) == ""
    inputText(end) = [];
end

towels = convertStringsToChars(split(inputText(1), ", "));
designs = convertStringsToChars(inputText(3:end));

%% Part 1 & Part 2
nDesigns = numel(designs);
nPossibleArrangements = nan(nDesigns, 1);
for ii = 1:nDesigns
    fprintf("%i/%i\n", ii, nDesigns);
    nPossibleArrangements(ii) = countArrangements(designs{ii}, towels);
end
nDesignsPossible = nnz(nPossibleArrangements);
nTotalPossibleArrangements = sum(nPossibleArrangements);

fprintf("Number of possible designs = %i\n", nDesignsPossible);
fprintf("Number of total possible arrangements = %i\n", nTotalPossibleArrangements);

%% Functions
function nArrangementsPossible = countArrangements(design, towels)
cache = configureDictionary('char', 'double');
[nArrangementsPossible, ~] = countArrangements_(design, towels, cache);
end


function [nArrangementsPossible, cache] = countArrangements_(design, towels, cache)
nArrangementsPossible = 0;

if cache.isKey(design)
    nArrangementsPossible = cache(design);
    return
end

if isempty(design)
    nArrangementsPossible = 1;
    return
end

nTowels = numel(towels);
for ii = 1:nTowels
    thisTowel = towels{ii};

    if ~startsWith(design, thisTowel)
        continue
    end
    
    [next, cache] = countArrangements_(design(numel(thisTowel) + 1 : end), towels, cache);
    nArrangementsPossible = nArrangementsPossible + next;
end
cache(design) = nArrangementsPossible;
end