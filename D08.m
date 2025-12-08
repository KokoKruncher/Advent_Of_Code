clear; clc; close all;

coords = readlines("D08_Data.txt");
coords = coords(coords ~= "");
coords = split(coords, ",");
coords = str2double(coords);

%% Part 1
N_CONNECTIONS = 1000;

nJunctionBoxes = height(coords);
junctionIds = (1:nJunctionBoxes).';
coordsDict = dictionary(junctionIds, num2cell(coords, 2));

pairs = nchoosek(junctionIds, 2);

coords1 = coordsDict(pairs(:,1));
coords1 = vertcat(coords1{:});

coords2 = coordsDict(pairs(:,2));
coords2 = vertcat(coords2{:});

distances = sqrt(sum((coords2 - coords1).^2, 2));
distances = array2table([pairs, distances], "VariableNames", ["StartID", "EndID", "Distance"]);
distances = sortrows(distances, "Distance", "ascend");

connections = graph();
connections = connections.addnode(nJunctionBoxes);
connections = connections.addedge(distances.StartID(1:N_CONNECTIONS), distances.EndID(1:N_CONNECTIONS));

[iCircuits, circuitSizes] = connections.conncomp();
sortedCircuitSizes = sort(circuitSizes, "descend");
result1 = prod(sortedCircuitSizes(1:3));

fprintf("Result, part 1 = %i\n", result1);

%% Part 2
isOneCircuit = all(iCircuits == iCircuits(1));
iEdge = N_CONNECTIONS;
while ~isOneCircuit
    iEdge = iEdge + 1;
    sourceId = distances.StartID(iEdge);
    targetId = distances.EndID(iEdge);
    connections = connections.addedge(sourceId, targetId);

    iCircuits = connections.conncomp();
    isOneCircuit = all(iCircuits == iCircuits(1));
end

coordsLastSource = coordsDict{sourceId};
coordsLastTarget = coordsDict{targetId};
result2 = coordsLastSource(1) * coordsLastTarget(1);

fprintf("Result, part 2 = %i\n", result2)

