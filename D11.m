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
edgeTable.EndNodes = edges;

deviceNetwork = digraph(edgeTable);
paths_you_out = deviceNetwork.allpaths("you", "out");
nPaths_you_out = numel(paths_you_out);

fprintf("Number of paths from 'you' to 'out' = %i\n", nPaths_you_out);

%% Part 2

%%% Out of memory! %%%
% paths_svr_out = deviceNetwork.allpaths("svr", "out");
% doesVisit = cellfun(@(p) all(ismember(["dac", "fft"], p)), paths_svr_out);
    