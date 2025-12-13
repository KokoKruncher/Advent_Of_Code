clear; clc; close all;

manual = readlines("D10_Data.txt");
manual = manual(manual ~= "");

Machines = parseManual(manual);

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
tic
for iMachine = 1:nMachines
    Machines(iMachine).minimumJoltageToggles = solveMinJoltageToggles(Machines(iMachine));
end
toc

minimumJoltageToggles = sum([Machines.minimumJoltageToggles]);
fprintf("Minumum total number of joltage toggles = %i\n", minimumJoltageToggles)


%% Functions
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


function minToggles = solveMinJoltageToggles(Machine)
% Solve Ax = b, where:
% A = The button to joltage increment matrix transposed
% b = Required joltage vector transposed
% x = Vector specifying the number of times each button should be pressed.
% subject to the constraints x >= 0, and all elements of x are integers, while minimising the sum of elements in x

A = double(Machine.buttons.');
b = Machine.joltages.';

nButtons = width(A);
coefficients = ones(nButtons, 1);
integerConstraints = (1:nButtons).';
lowerBounds = zeros(nButtons, 1);
upperBounds = repmat(max(b), nButtons, 1);
opts = optimoptions("intlinprog", "Display", "off");

minToggles = intlinprog(coefficients, integerConstraints, [], [], A, b, lowerBounds, upperBounds, [], opts);
minToggles = sum(round(minToggles));
end


function arr = createLightPermutations(nButtons)
arr = (dec2bin(0:(2^nButtons-1)) == '1').';
[~, iSort] = sort(sum(arr, 1), "ascend");
arr = arr(:, iSort);
end