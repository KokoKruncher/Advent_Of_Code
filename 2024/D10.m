clear; clc;
% 0.02s runtime excluding loading the data (functional)
% 0.05s runtime exclusing loading the data (OOP)

filename = "D10 Data.txt";
data = readlines(filename);

%% Part 1 & Part 2
tic
topographicMap = splitAndConvertMap(data);
trailHeadLinearIndx = find(topographicMap == 0);
nTrailHeads = numel(trailHeadLinearIndx);
mapSize = size(topographicMap);

trailHeadScores = nan(nTrailHeads,1);
trailHeadRatings = nan(nTrailHeads,1);
for iTrailHead = 1:nTrailHeads
    [rowTrailHead,colTrailHead] = ind2sub(mapSize,trailHeadLinearIndx(iTrailHead));
    startingLocation = [rowTrailHead,colTrailHead];

    trailHead = D10.TrailHead(topographicMap);
    trailHead.traverse(startingLocation);
    
    trailHeadScores(iTrailHead) = trailHead.calculateScore;
    trailHeadRatings(iTrailHead) = trailHead.nPathsToPeaks;
end

sumTrailHeadScores = sum(trailHeadScores,"all");
sumTrailHeadRatings = sum(trailHeadRatings,"all");
fprintf("Sum of scores = %i\n",sumTrailHeadScores)
fprintf("Sum of ratings = %i\n",sumTrailHeadRatings)
toc



function map = splitAndConvertMap(map)
arguments
    map (:,1) {mustBeA(map,'string')}
end
map = split(map,"");
map = map(:,2:end-1);
map = str2double(map);
end