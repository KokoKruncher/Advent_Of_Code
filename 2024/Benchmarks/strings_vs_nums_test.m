clear; clc;

strs = ["||" "*" "+"];
nums = [1 2 3];
n = 1e6;
iArray = repelem(1:3,1,n);

disp("Strings")
tic
for i = iArray
    a = strs(i);
end
toc

disp("Numbers")
tic
for i = iArray
    a = nums(i);
end
toc