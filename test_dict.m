clear; clc; close all;

d1 = dictionary(1:10, true);
d2 = dictionary(num2cell(1:10), true);

coords = [(1:10).', (1:10).' + 1];
keys = gnKeys(coords);
d3 = dictionary(keys, true);

N = 1e6;

timeArray(d1, N)
timeCell(d2, N)
timeHash(d3, N)

%% Local functions
function timeArray(d, N)
tic
for ii = 1:N
    out = d.isKey(ii);
end
toc
end


function timeCell(d, N)
tic
for ii = 1:N
    out = d.isKey({ii});
end
toc
end


function timeHash(d, N)
tic
keys = gnKeys([(1:N).', (1:N).'+1]);
for ii = 1:N
    key = keys(ii);
    out = d.isKey(key);
end
toc
end


function keys = gnKeys(coords)
nCoords = height(coords);
for ii = nCoords:-1:1
    keys(ii) = keyHash(coords(ii,:));
end
keys = double(keys);
end