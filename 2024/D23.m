clear; clc; close all;

filename = "D23 Data.txt";
data = readlines(filename);

%% Part 1
tic
connections = parseInput(data);
localNetwork = graph(connections.source,connections.target);

figure
hPlotFullNetwork = localNetwork.plot('NodeLabel',localNetwork.Nodes.Name);

cyclesWith3Edges = localNetwork.allcycles("MinCycleLength",3,"MaxCycleLength",3);
indxCyclesWith3EdgesStartWithT = cellfun(@(x) any(startsWith(x,'t')),cyclesWith3Edges);
nCyclesWith3EdgesStartWithT = sum(indxCyclesWith3EdgesStartWithT,"all");
cyclesWith3EdgesStartWithT = cyclesWith3Edges(indxCyclesWith3EdgesStartWithT);

fprintf("Number of sets with 3 interconnected computers that start with 't': %i\n", ...
    nCyclesWith3EdgesStartWithT)
toc

%% Part 2
tic
nNodes = numel(localNetwork.Nodes.Name);
dInterconnectingNodes = configureDictionary('double','cell');
maxNumInterconnectingNodes = 0;
lanPartyComputersCurrentGuess = [];
for iNode = 1:nNodes
    if any(lanPartyComputersCurrentGuess == iNode)
        continue
    end

    dInterconnectingNodes{iNode} = iNode;
    [dInterconnectingNodes,~] = searchForInterconnectingNodes(localNetwork, ...
        dInterconnectingNodes,iNode,iNode);
    
    nInterconnectingNodes = numel(dInterconnectingNodes{iNode});
    if nInterconnectingNodes > maxNumInterconnectingNodes
        maxNumInterconnectingNodes = nInterconnectingNodes;
        iLargestInterconnectingNetwork = iNode;
        lanPartyComputersCurrentGuess = dInterconnectingNodes{iNode};
    end
end
lanPartyComputers = dInterconnectingNodes{iLargestInterconnectingNetwork};
lanPartyComputerNames = localNetwork.Nodes.Name(lanPartyComputers);
lanPartyComputerNames = string(sort(lanPartyComputerNames));
password = join(lanPartyComputerNames,",");

fprintf("Password: %s\n",password)
toc

lanPartyComputerPairs = nchoosek(lanPartyComputers,2);

highlight(hPlotFullNetwork,lanPartyComputerPairs(:,1),lanPartyComputerPairs(:,2), ...
    'EdgeColor','red', ...
    'LineWidth',2, ...
    'NodeColor','red');

%% Functions
function connections = parseInput(data)
data = split(data,"-");
connections = table;
connections.source = data(:,1);
connections.target = data(:,2);
end



function [dInterconnectingNodes,nRecursion] = searchForInterconnectingNodes( ...
    localNetwork,dInterconnectingNodes,rootNode,node,nRecursion)
arguments
    localNetwork (1,1) graph
    dInterconnectingNodes dictionary
    rootNode (1,1) double
    node (1,1) double
    nRecursion (1,1) double = 0
end
nRecursion = nRecursion + 1;

if nRecursion == 100
    error("Hit recursion limit of 100.")
end

currentInterconnectingNodes = dInterconnectingNodes{rootNode};
adjacentNodes = localNetwork.nearest(node,1);
for thisAdjacentNode = adjacentNodes(:)'
    neighbors = localNetwork.nearest(thisAdjacentNode,1);
    bAreInterconnectingNodesNeighbors = ...
        ismember(dInterconnectingNodes{rootNode},neighbors);

    if ~all(bAreInterconnectingNodesNeighbors)
        continue
    end

    dInterconnectingNodes{rootNode} = [currentInterconnectingNodes; thisAdjacentNode];
    [dInterconnectingNodes,nRecursion] = searchForInterconnectingNodes(localNetwork, ...
        dInterconnectingNodes,rootNode,thisAdjacentNode,nRecursion);
end
end