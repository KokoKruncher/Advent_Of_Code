clear; clc; close all;

machineInfo = readlines("D13 Data.txt");
Machines = parseInput(machineInfo);

%% Part 1

Machines = calculateCost(Machines);
cost = sum([Machines.cost], "omitnan");
fprintf("Minimum number of tokens, part 1 = %i\n", cost);

%% Part 2
PRIZE_COORD_CORRECTION = 10000000000000;
for ii = 1:numel(Machines)
    Machines(ii).prizeCoord = Machines(ii).prizeCoord + PRIZE_COORD_CORRECTION;
end
Machines = calculateCost(Machines);
cost = sum([Machines.cost], "omitnan");
fprintf("Minimum number of tokens, part 2 = %i\n", cost);

%% Functions
function Machines = parseInput(machineInfo)
if machineInfo(end) == ""
    machineInfo(end) = [];
end

isSeparator = machineInfo == "";
iSeparator = find(isSeparator);
iFirstRow = [1; iSeparator + 1];
iLastRow = [iSeparator - 1; height(machineInfo)];

nMachines = numel(iFirstRow);
Machines = repmat(struct(), nMachines, 1);
for ii = 1:nMachines
    thisMachineInfo = machineInfo(iFirstRow(ii):iLastRow(ii));
    
    Machines(ii).deltaA     = str2double([extractBetween(thisMachineInfo(1), "Button A: X", ", Y"); ...
        extractAfter(thisMachineInfo(1), ", Y")]);
    Machines(ii).deltaB     = str2double([extractBetween(thisMachineInfo(2), "Button B: X", ", Y"); ...
        extractAfter(thisMachineInfo(2), ", Y")]);
    Machines(ii).prizeCoord = str2double([extractBetween(thisMachineInfo(3), "Prize: X=", ", Y"); ...
        extractAfter(thisMachineInfo(3), ", Y=")]);
end
end


function Machines = calculateCost(Machines)
EPS = 1e-2;

COST_A = 3;
COST_B = 1;

nMachines = numel(Machines);
[Machines.isPossible] = deal(false);
[Machines.nPressesA] = deal(nan);
[Machines.nPressesB] = deal(nan);
[Machines.cost] = deal(nan);

for ii = 1:nMachines
    buttonDeltas = [Machines(ii).deltaA, Machines(ii).deltaB];

    if det(buttonDeltas) == inf
        error("Infinite number of solutions!")
    end
    
    % Use round() due to small floating point error of mldivide().
    % EPS needs to be relatively large (~1e-2) for part 2, where errors are higher due to the large numbers.
    % If EPS is too small, a lot of possible solutions are falsely flagged as not possible.
    nButtonPresses = buttonDeltas \ Machines(ii).prizeCoord;
    isInteger = abs(round(nButtonPresses) - nButtonPresses) < EPS;
    if any(nButtonPresses < 0 | ~(isInteger))
        continue
    end
    nButtonPresses = round(nButtonPresses);
    
    Machines(ii).isPossible = true;
    Machines(ii).nPressesA = nButtonPresses(1);
    Machines(ii).nPressesB = nButtonPresses(2);
    Machines(ii).cost = COST_A * nButtonPresses(1) + COST_B * nButtonPresses(2);
end
end