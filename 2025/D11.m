clear; clc; close all;

deviceList = readlines("D11_Data.txt");
deviceList = deviceList(deviceList ~= "");

%% Part 1
nSources = numel(deviceList);
edges = cell(nSources, 1);
for ii = 1:nSources
    thisRow = deviceList(ii);
    thisSource = extractBefore(thisRow, ":");
    theseTargets = split(strip(extractAfter(thisRow, ":")));
    theseEdges = [repmat(thisSource, numel(theseTargets), 1), theseTargets];
    edges{ii} = theseEdges;
end
edges = vertcat(edges{:});
edgeTable = table();
edgeTable.EndNodes = vertcat(edges);

deviceNetwork = digraph(edgeTable);
paths_you_out = deviceNetwork.allpaths("you", "out");
nPaths_you_out = numel(paths_you_out);

fprintf("Number of paths from 'you' to 'out' = %i\n", nPaths_you_out);

%% Part 2
assert(~deviceNetwork.hascycles(), "Method of searching as-is relies on the assumption that the graph is acyclic.");

nodes = unique(edges);
nNodes = numel(nodes);
nodeIds = dictionary(nodes.', 1:nNodes);
targetIdLookup = dictionary();
for ii = 1:nSources
    thisRow = deviceList(ii);
    thisSource = extractBefore(thisRow, ":");
    theseTargets = split(strip(extractAfter(thisRow, ":")));

    thisSourceId = nodeIds(thisSource);
    targetIdLookup{thisSourceId} = nodeIds(theseTargets);
end

sourceId = nodeIds("svr");
searchId = nodeIds("out");
nPathsTotal = countPaths(sourceId, searchId, targetIdLookup);

requiredVisits = [nodeIds("dac"), nodeIds("fft")];
nPathsValid = countPaths(sourceId, requiredVisits(1), targetIdLookup) .* ...
              countPaths(requiredVisits(1), requiredVisits(2), targetIdLookup) .* ...
              countPaths(requiredVisits(2), searchId, targetIdLookup) + ...
              countPaths(sourceId, requiredVisits(2), targetIdLookup) .* ...
              countPaths(requiredVisits(2), requiredVisits(1), targetIdLookup) .* ...
              countPaths(requiredVisits(1), searchId, targetIdLookup);

fprintf("Number of valid paths from 'svr' to 'out' = %i\n", nPathsValid);

%% Function
function nPaths = countPaths(sourceId, searchId, targetIdLookup)
[nPaths, ~] = dfs(sourceId, searchId, targetIdLookup, 0, configureDictionary("double", "double"));
end


function [nPaths, nPathsSeen] = dfs(sourceId, searchId, targetIdLookup, nPaths, nPathsSeen)
if nPathsSeen.isKey(sourceId)
    % Seen this node before, no need to search its target nodes again
    nPaths = nPaths + nPathsSeen(sourceId);
    return
end

if ~targetIdLookup.isKey(sourceId)
    % This node doesn't go anywhere
    nPathsSeen(sourceId) = 0;
    return
end

nPathsBefore = nPaths;
targetIds = targetIdLookup{sourceId};
for thisTargetId = targetIds(:).'
    if thisTargetId == searchId
        % New  path found
        nPathsSeen(sourceId) = 1;
        nPaths = nPaths + 1;
        continue
    end

    [nPaths, nPathsSeen] = dfs(thisTargetId, searchId, targetIdLookup, nPaths, nPathsSeen);
end

% Remember number of paths from this node
nPathsSeen(sourceId) = nPaths - nPathsBefore;
end

