clear; clc;

aString = "hello";
bString = "bye";

aChar = 'hello';
bChar = 'bye';

aNum = 1;
bNum = 2;

n = 1e8;

disp("String comparison:")
tic
for i = 1:n
    TF = aString == bString;
end
toc

disp("Char comparison:")
tic
for i = 1:n
    TF = strcmp(aChar,bChar);
end
toc

disp("Number comparison:")
tic
for i = 1:n
    TF = aNum == bNum;
end
toc