clear; clc; close all;

manual = readlines("D10_Data.txt");
manual = manual(manual ~= "");

Machines = parseManual(manual);

% p = createLightPermutations(4)
%% Part 1
% Toggling the same button an even number of times does absolutely nothing to the final lights state!
% Hence, each button should be toggled either 0 times or 1 time only.

nMachines = numel(Machines);
for iMachine = 1:nMachines
    thisMachine = Machines(iMachine);
    theseButtons = thisMachine.buttons;
    nButtons = height(theseButtons);
    buttonPermutations = createLightPermutations(nButtons);
    nPermutations = width(buttonPermutations);
    for iPermutation = 1:nPermutations
        thisPermutation = buttonPermutations(:,iPermutation);
        finalState = mod(sum(theseButtons(thisPermutation,:), 1), 2);
        if all(finalState == thisMachine.finalState)
            Machines(iMachine).minimumLightToggles = nnz(thisPermutation);
            break
        end
    end
end

minimumLightToggles = sum([Machines.minimumLightToggles]);
fprintf("Minumum total number of light toggles = %i\n", minimumLightToggles)

%% Part 2
hPool = parpool("Threads", 4);
parfor iMachine = 1:nMachines
    Machines(iMachine).minimumJoltageToggles = solveMinJoltageToggles(Machines(iMachine));
    
end
hPool.delete();

minimumJoltageToggles = sum([Machines.minimumJoltageToggles]);
fprintf("Minumum total number of joltage toggles = %i\n", minimumJoltageToggles)


%% Functions
function minToggles = solveMinJoltageToggles(Machine)
N_START_POINTS = 40;

A = Machine.buttons;
B = Machine.joltages;
nButtons = height(A);
minimisationFcn = @(x) sum(x);
constraintFcnEqualZero = @(x) nonLinearConstraint(x, A, B);
lowerBounds = zeros(1, nButtons);
upperBounds = repmat(max(B), 1, nButtons);
opts = optimoptions("lsqnonlin", "Algorithm", "interior-point");

problemObj = createOptimProblem("lsqnonlin", ...
    'objective', minimisationFcn, ...
    'nonlcon', constraintFcnEqualZero, ...
    'lb', lowerBounds, ...
    'ub', upperBounds, ...
    'x0', zeros(1, nButtons), ...
    'options', opts);
% x = lsqnonlin(minimisationFcn, zeros(1, nButtons), lowerBounds, upperBounds, [], [], [], [], constraintFcnEqualZero)
multiStartObj = MultiStart();

warning("off", 'MATLAB:nearlySingularMatrix')
minToggles = multiStartObj.run(problemObj, N_START_POINTS);
warning("on", 'MATLAB:nearlySingularMatrix')

minToggles = sum(round(minToggles));
end


function [c, ceq] = nonLinearConstraint(x, A, B)
c = [];
ceq = [x * A - B, round(x) - x];
end


function Machines = parseManual(manual)
Machines = struct();
nRows = numel(manual);
for iRow = nRows:-1:1
    thisRow = manual(iRow);
    finalState = extractBetween(thisRow, "[", "]");
    finalState = char(finalState) == '#';
    nLights = numel(finalState);
    
    buttonWirings = extractBetween(thisRow, "]", "{");
    buttonWirings = split(buttonWirings, ["(", ")", " "]);
    buttonWirings = buttonWirings(buttonWirings ~= "");
    nButtons = numel(buttonWirings);
    buttons = false(nButtons, nLights);
    for iButton = 1:nButtons
        % Be aware that wiring index starts with 0
        buttons(iButton, str2double(split(buttonWirings(iButton), ",")) + 1) = true;
    end
    
    joltages = str2double(split(extractBetween(thisRow, "{", "}"), ",")).';
    
    Machines(iRow).finalState = finalState;
    Machines(iRow).buttons = buttons;
    Machines(iRow).joltages = joltages;
end
end


function arr = createLightPermutations(nButtons)
arr = (dec2bin(0:(2^nButtons-1)) == '1').';
[~, iSort] = sort(sum(arr, 1), "ascend");
arr = arr(:, iSort);
end