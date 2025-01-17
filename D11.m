% to nBlinks = 40
% original: long af
% after vectorisation: 20s
% after preallocation: 5s
% after removing loop: 8.5s

clear; clc; close all

filename = "D11 Data.txt";
data = readlines(filename);

%% Part 1
stones = str2double(split(data," "))';
% stones = [125 17];
% stones = [0 1 10 99 999];
tic
nBlinks = 40;
for iBlink = 1:nBlinks
    stones = blink(stones);
    disp(iBlink)
end
toc
fprintf("Number of stones: %i\n",numel(stones))
% fprintf("%i ",stones)

%%

% a = [1 10 100 1000 10000];
% numDigits(a)
% isEven(numDigits(a))

%% Functions
function newStones = blink(stones)
nStones = numel(stones);

% find out how many stones to add to preallocate
nDigitsAllStones = numDigits(stones);
isEvenNumDigits = isEven(nDigitsAllStones);
nStonesToAdd = nnz(isEvenNumDigits);
nNewStones = nStones + nStonesToAdd;
newStones = nan(1,nNewStones);

% for stones that dont get split into 2
numIndicesToShift = cumsum(isEvenNumDigits);
iStonesInNewArray = (1:nStones) + numIndicesToShift;

% for stones that get split in two, their indices in new array are:
iStonesToSplit = find(isEvenNumDigits);
iReplacementStones1 = iStonesToSplit + (0:(nStonesToAdd-1));
iReplacementStones2 = iReplacementStones1 + 1;

% handle stones equal to 0
isEqualZero = stones == 0;
newStones(iStonesInNewArray(isEqualZero)) = 1;

% handle stones that get split
nDigitsEvenNumDigits = nDigitsAllStones(isEvenNumDigits);
replacementStones1 = floor(stones(isEvenNumDigits)./(10.^(nDigitsEvenNumDigits./2)));
replacementStones2 = rem(stones(isEvenNumDigits),10.^(nDigitsEvenNumDigits./2));
newStones(iReplacementStones1) = replacementStones1;
newStones(iReplacementStones2) = replacementStones2;

% handle all other stones which get multiplied by 2024
isMultiplied = ~(isEqualZero | isEvenNumDigits);
stonesMultiplied = stones(isMultiplied).*2024;
newStones(iStonesInNewArray(isMultiplied)) = stonesMultiplied;

if any(isnan(newStones))
    error("nansssss")
end
end



function nDigits = numDigits(number)
nDigits = floor(log10(number) + 1);
end



function areNumbersEven = isEven(numbers)
areNumbersEven = rem(numbers,2) == 0;
end