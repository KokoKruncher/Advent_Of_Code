clear; clc; close all

filename = "D24 Data.txt";
data = readlines(filename);

%% Part 1
tic
% determine order in which gates get evaluated
[Inputs,Gates] = parseData(data);
[nodeOrder,wireNetwork] = findWireEvalutionOrder(Gates,Inputs);
Gates = sortGatesByNodeOrder(wireNetwork,Gates,nodeOrder);

% to store wire states
allWires = string(wireNetwork.Nodes.Name);
nWires = numel(allWires);
dState = dictionary(allWires,false(nWires,1));
Wires = struct;
allWires = num2cell(allWires);
[Wires(1:nWires).name] = allWires{:};
[Wires.state] = deal(false);

% create dict with function handle for each operator and state of each wire
dFcnFromOperator = dictionary("AND",@and,"OR",@or,"XOR",@xor);

% initialise states of given inputs
dState([Inputs(:).wires]) = [Inputs(:).bools];

% simulate
Wires = simulateSystem(Gates, dState, dFcnFromOperator, Wires);
outputBinaryNumber = getInputOrOutputBinaryNumber(Wires,"z");
outputDecimalNumber = bin2dec(outputBinaryNumber);
toc

fprintf("Output decimal number: %i\n",outputDecimalNumber)

%% Function
function [Inputs,Gates] = parseData(data)
locSplit = find(data == "");
inputsRaw = data(1:locSplit-1);
inputsRaw = split(inputsRaw,": ");
inputsRaw = array2table(inputsRaw,"VariableNames",["wires" "bools"]);
Inputs = table2struct(inputsRaw);
bools = logical(str2double([Inputs(:).bools]));
bools = num2cell(bools);
[Inputs(:).bools] = bools{:};

gatesRaw = data(locSplit+1:end);
gatesRaw = split(gatesRaw,[" ", " -> "]);
gatesRaw = array2table(gatesRaw(:,[1,2,3,5]), ...
    "VariableNames",["wire1" "operator" "wire2" "wireOut"]);
Gates = table2struct(gatesRaw);
end



function [nodeOrder,wireNetwork] = findWireEvalutionOrder(Gates,Inputs)
allWires = [Inputs(:).wires, Gates(:).wire1, Gates(:).wire2, Gates(:).wireOut];
uniqueWires = unique(allWires);

nGates = numel(Gates);
nEdges = nGates*2; % each gate has 2 inputs that map to one output
source = strings(nEdges,1);
target = strings(nEdges,1);
iEdge = 0;
for iGate = 1:nGates
    wire1 = Gates(iGate).wire1;
    wire2 = Gates(iGate).wire2;
    wireOut = Gates(iGate).wireOut;
    iEdge = iEdge + 1;
    source(iEdge) = wire1;
    target(iEdge) = wireOut;

    iEdge = iEdge + 1;
    source(iEdge) = wire2;
    target(iEdge) = wireOut;
end

wireNetwork = digraph(source,target,[],uniqueWires);
% figure
% wireNetwork.plot('Layout','layered');

nodeOrder = toposort(wireNetwork);
end



function Gates = sortGatesByNodeOrder(wireNetwork, Gates, nodeOrder)
allWires = string(wireNetwork.Nodes.Name);
nWires = numel(allWires);
dNodeFromWire = dictionary(allWires,(1:nWires)');

nodeNumber = num2cell(dNodeFromWire([Gates(:).wireOut]));
[Gates.node] = nodeNumber{:};

[~,wireOutOrder] = ismember([Gates.node],nodeOrder);
[~,gateOrder] = sort(wireOutOrder);
wireOutOrder = num2cell(wireOutOrder);
[Gates.wireOutOrder] = wireOutOrder{:};
Gates = Gates(gateOrder);
end



function Wires = simulateSystem(Gates, dState, dFcnFromOperator, Wires)
nGates = numel(Gates);
for iGate = 1:nGates
    wire1 = Gates(iGate).wire1;
    wire2 = Gates(iGate).wire2;
    wireOut = Gates(iGate).wireOut;
    operator = Gates(iGate).operator;
    
    stateWire1 = dState(wire1);
    stateWire2 = dState(wire2);
    fcn = dFcnFromOperator(operator);
    stateWireOut = fcn(stateWire1,stateWire2);
    dState(wireOut) = stateWireOut;
end
wireStates = dState.values;
wireStates = num2cell(wireStates);
[Wires.state] = wireStates{:};
end



function outputBinaryNumber = getInputOrOutputBinaryNumber(Wires,letter)
indxWiresStartingWithLetter = startsWith([Wires.name],letter);
WiresStartingWithLetter = Wires(indxWiresStartingWithLetter);
wiresStartingWithLetter = struct2table(WiresStartingWithLetter);

% lowest number is least significant bit
wiresStartingWithLetter = sortrows(wiresStartingWithLetter,"name","descend");
outputBinaryNumber = double(wiresStartingWithLetter.state)';
outputBinaryNumber = join(string(outputBinaryNumber),"");
end