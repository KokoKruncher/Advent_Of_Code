% clear; clc;

%% Part 1
filename = "D3 Data.txt";
data = fileread(filename);

% remove newline characters
data(data == newline) = [];

multiplicationSum = computeMultiplicationSum(data);

disp("Sum of all the results of multiplication:")
disp(multiplicationSum)

%% Part 2
% split the string in to substrings at do()
dataSplit = split(data,"do()");

% in all substrings, delete everything after don't()
dataWithoutDont = extractBefore(dataSplit,"don't()");

% where it doesn't exist, replaces with <missing> so replace w/ original
indxMissing = ismissing(dataWithoutDont);
dataWithoutDont(indxMissing) = dataSplit(indxMissing);

% recombine the substrings
dataWithoutDont = join(dataWithoutDont,"");

% do multiplication sum
multiplicationSumDoDont = computeMultiplicationSum(dataWithoutDont);

disp("Sum of all the results of multiplication with do/don't:")
disp(multiplicationSumDoDont)



function multiplicationSum = computeMultiplicationSum(data)
% extract all multiplication commands
data = string(data);
commandPattern = "mul(" + digitsPattern(1,3) + "," + digitsPattern(1,3) + ")";
commands = extract(data,commandPattern);

% extract all multiplication arguments
charactersToErase = ["mul(", ")"];
argsString = erase(commands,charactersToErase);
args = split(argsString,",");
args = str2double(args);

% evaluate the multiplications by multiplying each row
multiplicationSum = sum(prod(args,2),'all');
end