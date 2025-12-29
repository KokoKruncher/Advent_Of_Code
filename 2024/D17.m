clear; clc

state = readlines("D17 Data.txt");

% state = ["Register A: 729"; ...
% "Register B: 0"; ...
% "Register C: 0"; ...
% ""; ...
% "Program: 0,1,5,4,3,0"];

% state = ["Register A: 2024"; ...
% "Register B: 0"; ...
% "Register C: 0"; ...
% ""; ...
% "Program: 0,3,5,4,3,0"];

%% Part 1
computer = D17.Computer(state);
output = computer.run();

fprintf("Output = %s\n", join(string(output), ","));

%% Part 2 
% By printing the output where registerA = [1, 10e3], we can see that the number of output values starts at 1 when
% registerA = 8^0 = 1, then the number of output values becomes ++1 at 8^1, 8^2, 8^3, 8^4, and so on.
%
% Thus, 
% Number of output values = 1 + floor(log8(registerA)), where registerA >= 1
%
% Given n = the number of output values,
% The lower and upper bounds of registerA are:
% [8^(n - 1), 8^n - 1]
% 
% Looking at the binary representation of registerA,
% When register A >= 2^4, the 2 most significant bits controlled the last 1 outputs
% When register A >= 2^5, the 3 most significant bits controlled the last 1 outputs
% When register A >= 2^6, the 4 most significant bits controlled the last 2 outputs
%
% Looking at the octal representation of registerA,
% When register A >= 8^1, the 1 most significant digits controlled the last 1 outputs
% When register A >= 8^2, the 2 most significant digits controlled the last 2 outputs
% When register A >= 8^3, the 3 most significant digits controlled the last 3 outputs
% And so on...
% Though note that a permutation of the last n outputs do not uniquely map to a single permutation of the n most
% significant digits.
% i.e., for registarA >= 8^3, 100x and 101x both map to the last 4 digits of 4, 0, 4.

% Also, the last digit always follows the sequence: 4 -> 6 -> 7 -> 0 -> 1 -> 2 -> 3


filePath = "Outputs\D17_1.txt";
fid = fopen(filePath, "w+");
cleanupObj = onCleanup(@() fclose(fid));
tic
lastPower8 = 0;
for ii = 1:1e4
    thisPower8 = floor(logb(ii, 8));
    if thisPower8 ~= lastPower8
        lastPower8 = thisPower8;
        fprintf(fid, "%s", newline);    
    end

    fprintf(1, "%i\n", ii);
    computer.reset();
    computer.registerA = ii;
    thisOutput = computer.run;

    thisOutput = join(string(thisOutput), ",");
    fprintf(fid, ">= 8^%s: %s: %s: %s\n", pad(string(thisPower8), 2), pad(string(ii), 5), dec2base(ii, 8, 5), thisOutput);
end
toc
clear("cleanupObj");

% Looking at permutations of the most to second least significant digit (skipping every 8), we can see that:
% 
% When registerA >= 8^2, the 3rd least significant digit maps to the last value [1 -> 4, 2 -> 6, 3 -> 7, ...]
%
% When registerA >= 8^3, the 3rd least significant digit maps to the 2nd last value [0 -> 0, 1 -> 4, 2 -> 7, ...]
% AND the mapping of 8^2 applies to the 4th least significant (most significant) digit instead of 3rd.
%
% When registerA >= 8^4, the 3rd least significant digit maps to the 3rd last value [0 -> 4, 1 -> 4, 2 -> 6, 3 -> 7]  
% AND the mapping of 8^3 applies to the 4th least significant (2nd most significant) digit instead of 3rd.
% AND the mapping of 8^2 applies to the 5th least significnat (most significant) digit instead of 3rd.

% Expectation:
% When registerA >= 8^5, the 3rd least significant digit maps to the 3rd last value []  
% AND the mapping to 3rd last value of 8^4 applies to the 4th least significant (3rd most significant) digit instead of 3rd.
% AND the mapping to 2nd last value of 8^3 applies to the 5th least significnat (2nd most significant) digit instead of 3rd.
% AND the mapping to last value of 8^2 applies to the 6th least significant (most significant) digit instead of 3rd.

filePath = "Outputs\D17_2.txt";
fid = fopen(filePath, "w+");
cleanupObj = onCleanup(@() fclose(fid));
tic
numsBase8 = char(string(dec2base((1:base2dec('111111', 8)).', 8)) + "0");
lastPower8 = 1;
for ii = 1:height(numsBase8)
    thisNumBase8 = numsBase8(ii,:);
    thisNumDecimal = base2dec(thisNumBase8, 8);
    
    thisPower8 = floor(logb(thisNumDecimal, 8));
    if thisPower8 ~= lastPower8
        lastPower8 = thisPower8;
        fprintf(fid, "%s", newline);    
    end

    fprintf(1, "%i\n", ii);
    computer.reset();
    computer.registerA = thisNumDecimal;
    thisOutput = computer.run;

    leastValues = thisOutput(end - (thisPower8 - 1) : end);
    leastValues = join(string(leastValues), ",");
    fprintf(fid, ">= 8^%s: %s: %s: %s\n", ...
        pad(string(thisPower8), 2), pad(thisNumBase8, 6), pad(string(thisNumDecimal), 5), leastValues);
end
toc
clear("cleanupObj");




% tic
% minValueRegisterA = computer.findRegisterAValue();
% toc
% fprintf("Minimum value of register A = %i\n", minValueRegisterA);

%% Functions
