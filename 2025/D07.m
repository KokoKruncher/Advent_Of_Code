clear; clc; close all;

manifold = readlines("D07_Data.txt");
manifold = manifold(manifold ~= "");

%% Part 1
manifold = char(manifold);
isSplitterArray = manifold == '^';

isBeam = manifold == 'S';
isBeam = isBeam(1,:);

nRows = height(manifold);
nColumns = width(manifold);
nHitsTotal = 0;
for ii = 2:nRows
    isSplitter = isSplitterArray(ii,:);
    isHit = isSplitter & isBeam;

    if ~any(isHit)
        continue
    end

    nHits = nnz(isHit);
    nHitsTotal = nHitsTotal + nHits;

    iHit = find(isHit);
    iNewBeam =  [iHit - 1, iHit + 1];
    iNewBeam = iNewBeam(iNewBeam >= 1 & iNewBeam <= nColumns);

    isBeam(isHit) = false;
    isBeam(iNewBeam) = true;
end

fprintf("Number of times the beam will be split = %i\n", nHitsTotal);

%% Part 2
% Start with 1 possible path.
% Each time a splitter is hit by a beam, it adds 1 possibility.

% Beams are not merged. For example, in this scenario, the splitter in the 3rd row is hit twice, not once.
% .....|.|.......
% ....|^|^|......
% ......^........

isBeam = manifold == 'S';
isBeam = isBeam(1,:);
nBeams = double(isBeam);

nPossibilities = 1;
for ii = 2:nRows
    isSplitter = isSplitterArray(ii,:);
    nHits = isSplitter .* nBeams;

    if ~any(nHits)
        continue
    end

    nPossibilities = nPossibilities + sum(nHits);

    % Delete beams that hit splitter
    nBeams = nBeams - nHits;

    % Split beams left and right
    nSplitLeft = [nHits(2:end), 0];
    nSplitRight = [0, nHits(1:end-1)];
    nBeams = nBeams + nSplitLeft + nSplitRight;
end

fprintf("Number of possibilities = %i\n", nPossibilities);