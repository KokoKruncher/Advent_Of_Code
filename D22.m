clear; clc;

filename = "D22 Data.txt";
secretNumbersInitial = readmatrix(filename);

%% Part 1
nTimeToEvolve = 2000;
secretNumbersEvolved = evolve(secretNumbersInitial,nTimeToEvolve);

sumNewSecretNumbers = sum(secretNumbersEvolved,"all");
fprintf("Sum of new secret numbers = %i\n",sumNewSecretNumbers)

%% Functions
function out = mix(secretNumber,value)
out = bitxor(secretNumber,value);
end



function out = prune(secretNumber)
out = mod(secretNumber,16777216);
end



function secretNumber = evolve(secretNumber,n)
arguments
    secretNumber (:,1) double
    n (1,1) double
end

for i = 1:n
    val = secretNumber.*64;
    secretNumber = mix(secretNumber,val);
    secretNumber = prune(secretNumber);

    val = floor(secretNumber./32);
    secretNumber = mix(secretNumber,val);

    val = secretNumber.*2048;
    secretNumber = mix(secretNumber,val);
    secretNumber = prune(secretNumber);
end
end