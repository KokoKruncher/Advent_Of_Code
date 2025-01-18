% to nBlinks = 40
% original: long af
% after vectorisation: 20s
% after preallocation: 5s
% after removing loop: 8.5s
% after caching: 0.15s

clear; clc; close all

filename = "D11 Data.txt";
data = readlines(filename);

%% Part 1
initialStones = str2double(split(data," "))';
% initialStones = [125 17];

%% Part 2

nBlinksPart1 = 25;

tic
[nStonesOutTotalPart1,cachePart1] = blinkAllStones(initialStones,nBlinksPart1);
toc

nBlinksPart2 = 75;

tic
[nStonesOutTotalPart2,cachePart2] = blinkAllStones(initialStones,nBlinksPart2);
toc

fprintf("Part 1: %i\n",nStonesOutTotalPart1)
fprintf("Part 2: %i\n",nStonesOutTotalPart2)

%% Functions
function [nStonesOutTotal,cache] = blinkAllStones(initialStones,nBlinks)
cache = configureDictionary('cell','double');
nStonesOutTotal = 0;
for thisInitialStone = initialStones
    [nStonesOut,cache] = blinkNTimes(thisInitialStone,nBlinks,cache);
    nStonesOutTotal = nStonesOutTotal + nStonesOut;
end
end



function [nStonesOut,cache] = blinkNTimes(stone,nBlinks,cache)
arguments
    stone (1,1) double
    nBlinks (1,1) double
    cache dictionary
end

if cache.isKey({[stone,nBlinks]})
    nStonesOut = cache({[stone,nBlinks]});
    return
end

if nBlinks == 0
    nStonesOut = 1;
    return
end

% not in cache, so do blink
if stone == 0
    [nStonesOut,cache] = blinkNTimes(1,nBlinks-1,cache);
else
    nDigits = numDigits(stone);
    if isEven(nDigits)
        % digits drop leading zeros
        replacementStone1 = floor(stone/(10^(nDigits/2))); % 1st half of digits
        replacementStone2 = rem(stone,10^(nDigits/2)); % 2nd half of digits
        
        nStonesOut = 0;
        [tmp,cache] = blinkNTimes(replacementStone1,nBlinks-1,cache);
        nStonesOut = nStonesOut + tmp;
        
        [tmp,cache] = blinkNTimes(replacementStone2,nBlinks-1,cache);
        nStonesOut = nStonesOut + tmp;
    else
        [nStonesOut,cache] = blinkNTimes(stone*2024,nBlinks-1,cache);
    end
end
cache({[stone,nBlinks]}) = nStonesOut;
end



function nDigits = numDigits(number)
nDigits = floor(log10(number) + 1);
end



function isNumberEven = isEven(number)
isNumberEven = rem(number,2) == 0;
end