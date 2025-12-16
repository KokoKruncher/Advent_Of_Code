function nStonesOutTotal = blinkAllStones(initialStones,nBlinks)
nStonesOutTotal = 0;
for thisInitialStone = initialStones
    nStonesOut = blinkNTimes(thisInitialStone,nBlinks);
    nStonesOutTotal = nStonesOutTotal + nStonesOut;
end
end



function nStonesOut = blinkNTimes(stone,nBlinks)
arguments
    stone (1,1) double
    nBlinks (1,1) double
end

persistent cache
if isempty(cache)
    cache = configureDictionary('cell','double');
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
    nStonesOut = blinkNTimes(1,nBlinks-1);
else
    nDigits = numDigits(stone);
    if isEven(nDigits)
        % digits drop leading zeros
        replacementStone1 = floor(stone/(10^(nDigits/2))); % 1st half of digits
        replacementStone2 = rem(stone,10^(nDigits/2)); % 2nd half of digits

        nStonesOut = blinkNTimes(replacementStone1,nBlinks-1);
        
        tmp = blinkNTimes(replacementStone2,nBlinks-1);
        nStonesOut = nStonesOut + tmp;
    else
        nStonesOut = blinkNTimes(stone*2024,nBlinks-1);
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