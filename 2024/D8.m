clear; clc;
import D8.*

%% Part 1
filename = "D8 Data";
data = readlines(filename);

antennaMap = formatData(data);

uniqueFrequencies = unique(antennaMap);
uniqueFrequencies = uniqueFrequencies(uniqueFrequencies ~= ".");
nUniqueFrequencies = numel(uniqueFrequencies);

for iFrequency = nUniqueFrequencies:-1:1
    frequency = uniqueFrequencies(iFrequency);
    antennaArray(iFrequency) = AntennaSet(frequency,antennaMap);
    antennaArray(iFrequency).locateAntinodes();
end

nAntennas = numel(antennaArray);
allAntinodeLocations = antennaArray(1).antinodeLocations;
for iAntenna = 2:nAntennas
    allAntinodeLocations = allAntinodeLocations|antennaArray(iAntenna).antinodeLocations;
end

nUniqueAntinodeLocations = sum(allAntinodeLocations,"all");
fprintf("Number of unique antinode locations: %i\n",nUniqueAntinodeLocations)

%% Part 2
for thisAntenna = antennaArray
    thisAntenna.clearAntinodeLocations();
    thisAntenna.locateAntinodesModified();
end

allAntinodeLocations = antennaArray(1).antinodeLocations;
for iAntenna = 2:nAntennas
    allAntinodeLocations = allAntinodeLocations|antennaArray(iAntenna).antinodeLocations;
end

nUniqueAntinodeLocations = sum(allAntinodeLocations,"all");
fprintf("Number of unique antinode locations: %i\n",nUniqueAntinodeLocations)

exportAntinodeLocations(allAntinodeLocations,antennaMap)



function data = formatData(data)
arguments
    data {mustBeA(data,"string")}
end
data = split(data,"");
data = data(:,2:end-1);
end



function exportAntinodeLocations(allAntinodeLocations,antennaMap)
if ~isfolder("Outputs")
    mkdir("Outputs")
end
indxAntinodesNotAntenna = antennaMap == "." & allAntinodeLocations;
antennaMap(indxAntinodesNotAntenna) = "#";
writematrix(antennaMap,"Outputs/D8_Part2.txt")
end