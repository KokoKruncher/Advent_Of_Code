clear; clc;

filename = "D22 Data.txt";
secretNumbersInitial = readmatrix(filename);
% secretNumbersInitial = [1; 2; 3; 2024];

%% Part 1
tic
nTimeToEvolve = 2000;
secretNumbersEvolved = evolve(secretNumbersInitial,nTimeToEvolve);

sumNewSecretNumbers = sum(secretNumbersEvolved(:,end),"all");
toc

fprintf("Sum of new secret numbers = %i\n\n",sumNewSecretNumbers)

%% Part 2

tic
% each buyer has a row of prices
prices = mod([secretNumbersInitial, secretNumbersEvolved],10);
priceChanges = diff(prices,1,2);

windowLength = 4;
windowScore = countWindowScore(priceChanges,prices,windowLength);
maxBananas = max(windowScore.values);
toc

fprintf("Max bananas: %i\n",maxBananas)

%% Functions
function out = mix(secretNumber,value)
out = bitxor(secretNumber,value);
end



function out = prune(secretNumber)
out = mod(secretNumber,16777216);
end



function secretNumbersEvolved = evolve(secretNumbers,nTimesToEvolve)
arguments
    secretNumbers (:,1) double
    nTimesToEvolve (1,1) double
end
nBuyers = length(secretNumbers);
secretNumbersEvolved = nan(nBuyers,nTimesToEvolve);

for i = 1:nTimesToEvolve
    val = secretNumbers.*64;
    secretNumbers = mix(secretNumbers,val);
    secretNumbers = prune(secretNumbers);

    val = floor(secretNumbers./32);
    secretNumbers = mix(secretNumbers,val);

    val = secretNumbers.*2048;
    secretNumbers = mix(secretNumbers,val);
    secretNumbers = prune(secretNumbers);

    secretNumbersEvolved(:,i) = secretNumbers;
end
end



function windowScore = countWindowScore(priceChanges,prices,windowLength)
firstWindow = priceChanges(1,1:windowLength);
windowScore = dictionary({firstWindow},0);

nRows = height(priceChanges);
nCols = width(priceChanges);
nMaxPossibleWindowsPerRow = (nCols - windowLength + 1);

for iRow = 1:nRows
    row = priceChanges(iRow,:);

    [windows,iCol] = createWindows(row,windowLength,nMaxPossibleWindowsPerRow);
    nWindows = height(windows);
    for iWindow = 1:nWindows
        window = windows(iWindow,:);
        
        % iCol + window length - 1 is col of last window element.
        % + 1 because first column of price matrix doesnt have a corresponding price
        % change.
        thisPrice = prices(iRow,iCol(iWindow) + windowLength - 1 + 1);

        if windowScore.isKey({window})
            windowScore({window}) = windowScore({window}) + thisPrice;
        else
            windowScore({window}) = thisPrice;
        end
    end
end
end



function [windows,iCol] = createWindows(vec,windowLength,nMaxPossibleWindowsPerRow)
windows = nan(nMaxPossibleWindowsPerRow,windowLength);

for i = 1:nMaxPossibleWindowsPerRow
    windows(i,:) = vec(i:(i + windowLength - 1));
end
[windows,iCol] = unique(windows,'stable','rows');
end