% to nBlinks = 40
% original: long af
% after vectorisation: 20s
% after preallocation: 5s
% after removing loop: 8.5s
% after caching: 0.15s
% after making cache persistent: 0.15s
% Note that clear all in a script does not remove persistent variables in local functions
% hence why the functions have been moved to a separate file in the D11 package for fair
% comparison

clear all; clc; close all
import D11.*

filename = "D11 Data.txt";
data = readlines(filename);

%% Part 1 & Part 2
initialStones = str2double(split(data," "))';
% initialStones = [125 17];

nBlinksPart1 = 25;

tic
nStonesOutTotalPart1 = blinkAllStones(initialStones,nBlinksPart1);
toc

nBlinksPart2 = 75;

tic
nStonesOutTotalPart2 = blinkAllStones(initialStones,nBlinksPart2);
toc

fprintf("Part 1: %i\n",nStonesOutTotalPart1)
fprintf("Part 2: %i\n",nStonesOutTotalPart2)