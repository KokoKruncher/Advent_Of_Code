clear; clc; close all;

instructions = readlines("D01_Data.txt");
instructions = instructions(instructions ~= "");

%% Part 1 & 2
direction = extract(instructions, 1);
nClicks = str2double(erase(instructions, direction));
operation = ones(size(nClicks));
operation(direction == "L") = -1;

currentNumber = 50;
passwordPart1 = 0;
passwordPart2 = 0;
for ii = 1:numel(nClicks)
    [currentNumber, nZeroPasses] = turnDial(currentNumber, nClicks(ii) .* operation(ii));

    if currentNumber == 0
        passwordPart1 = passwordPart1 + 1;
    end
    
    passwordPart2 = passwordPart2 + nZeroPasses;
end
passwordPart2 = passwordPart2 + passwordPart1;

fprintf("Password, part 1: %i\n", passwordPart1)
fprintf("Password, part 2: %i\n", passwordPart2)

%% Local functions
function [newNumber, nZeroPasses] = turnDial(currentNumber, nClicks)
if nClicks == 0
    newNumber = currentNumber;
    nZeroPasses = 0;
    return
end

newNumber = mod(currentNumber + nClicks, 100);

% From the current number, put the dial back to zero.
% Then, compenstate the number of clicks needed, so that the new number is still correct after the rotation.
% If abs(compensated number of clicks) > 100, this means that the dial has passed zero.
if nClicks > 0
    nClicksCompensated = nClicks + currentNumber;
else
    nClicksCompensated = -nClicks + mod(-currentNumber, 100);
end 
nZeroPasses = floor(nClicksCompensated / 100);

% To avoid double counting
if newNumber == 0 && nZeroPasses > 0
    nZeroPasses = nZeroPasses - 1;
end
end