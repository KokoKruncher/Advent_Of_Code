clear; clc;

%% Part 1
data = readtable("D1 Data.txt");
leftId= data{:,1};
rightId = data{:,2};

leftId = sort(leftId);
rightId = sort(rightId);

distances = abs(leftId - rightId);
totalDistance = sum(distances,'all');

disp("Total distance:")
disp(totalDistance)

%% Part 2
similarityScore = nan(size(leftId));
nId = numel(leftId);
for indxId = 1:nId
    similarityScore(indxId) = calculateSimilarity(leftId(indxId),rightId);
end
totalSimilarityScore = sum(similarityScore,"all");
disp("Total similarity score:")
disp(totalSimilarityScore)



function similarityScore = calculateSimilarity(id,refIdArray)
% calculate the number of times id appears in th ref array multiplied by
% the ID.
indx = id == refIdArray;
similarityScore = sum(indx,'all').*id;
end