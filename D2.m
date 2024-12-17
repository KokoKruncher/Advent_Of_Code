clear; clc;

%% Part 1
% for some reason MATLAB tries to be smart and skips first 30 lines, so
% manually set first line with data to be line 1.
filename = "D2 Data.txt";
opts = detectImportOptions(filename);
opts.DataLines = [1 Inf];

data = readmatrix("D2 Data.txt",opts);
nRows = height(data);
isSafe = false(nRows,1);
for iRow = 1:nRows
    isSafe(iRow) = checkReport(data(iRow,:));
end
nSafeReports = sum(isSafe,'all');
disp("Number of safe reports:")
disp(nSafeReports)

%% Part 2
isSafeTolerant = false(nRows,1);
for iRow = 1:nRows
    isSafeTolerant(iRow) = checkReportTolerant(data(iRow,:));
end
nSafeReportsTolerant = sum(isSafeTolerant,'all');
disp("Number of safe reports with tolerance:")
disp(nSafeReportsTolerant)



function isSafe = checkReport(levels)
arguments
    levels (1,:) double
end
levels = levels(~isnan(levels));
if isempty(levels)
    isSafe = false;
    return
end

if numel(levels) == 1
    isSafe = true;
    return
end
differences = diff(levels);

% if not monotonically increasing or decreasing
if ~( all(differences > 0) || all(differences < 0) )
    isSafe = false;
    return
end

% check bounds of differences
differences = abs(differences);
if ~all(differences >= 1 & differences <= 3)
    isSafe = false;
    return
end

isSafe = true;
end



function isSafe = checkReportTolerant(levels)
arguments
    levels (1,:) double
end
isSafe = checkReport(levels);

if isSafe
    return
end

levels = levels(~isnan(levels));
if isempty(levels) || numel(levels) == 1
    return
end
nLevels = numel(levels);

% keep removing a single level until the report is safe
for iLevel = 1:nLevels
    levelsModified = levels;
    levelsModified(iLevel) = [];
    isSafe = checkReport(levelsModified);
    if isSafe
        return
    end
end
end