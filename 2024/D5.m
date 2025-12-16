clear; clc;

%% Part 1
filename = "D5 Data.txt";
data = readlines(filename);
[rules,updates] = formatData(data);

% identify updates that are in the correct order
isCorrectOrder = false(size(updates));
nUpdates = numel(updates);
for iUpdate = 1:nUpdates
    update = updates{iUpdate};
    indxRelevantRules = all(ismember(rules,update),2);
    relevantRules = rules(indxRelevantRules,:);
    isCorrectOrder(iUpdate) = checkRulesSatisfied(relevantRules,update);
end

% extract middle pages of correct updates
nPages = cellfun(@numel,updates);
if any(mod(nPages,2) == 0)
    error("Some updates have even number of pages, can't find middle page.")
end
correctUpdates = updates(isCorrectOrder);
middleElements = cellfun(@extractMiddleElement,correctUpdates);
sumMiddleElements = sum(middleElements,'all');
fprintf("Sum of middle elements of correct updates: %.i\n\n",sumMiddleElements)

%% Part 2
wrongUpdates = updates(~isCorrectOrder);
correctedUpdates = cell(size(wrongUpdates));
nWrongUpdates = numel(wrongUpdates);
for iUpdate = 1:nWrongUpdates
    update = wrongUpdates{iUpdate};
    indxRelevantRules = all(ismember(rules,update),2);
    relevantRules = rules(indxRelevantRules,:);
    correctedUpdates{iUpdate} = correctUpdate(relevantRules,update);
end
middleElementsOfCorrected = cellfun(@extractMiddleElement,correctedUpdates);
sumMiddleElementsOfCorrected = sum(middleElementsOfCorrected,'all');
fprintf("Sum of middle elements of corrected updates: %.i\n",sumMiddleElementsOfCorrected)



function [rules,updates] = formatData(data)
% get rid of empty lines
data(data == "") = [];

indxRules = contains(data,"|");
indxPages = ~indxRules;

rules = data(indxRules);
rules = split(rules,"|");
rules = str2double(rules);

updates = data(indxPages);
updates = arrayfun(@(x) split(x,",")',updates,'UniformOutput',false);
updates = cellfun(@str2double,updates,'UniformOutput',false);
end



function isCorrectOrder = checkRulesSatisfied(relevantRules,update)
arguments
    relevantRules (:,2) double
    update (1,:) double
end
isCorrectOrder = false;
nRules = height(relevantRules);
for iRule = 1:nRules
    rule = relevantRules(iRule,:);
    pageBefore = rule(1);
    pageAfter = rule(2);
    locPageBefore = find(update == pageBefore,1,'last');
    locPageAfter = find(update == pageAfter,1,'first');
    isThisRuleSatisfied = locPageBefore < locPageAfter;
    if ~isThisRuleSatisfied
        return
    end
end
isCorrectOrder = true;
end



function middleElement = extractMiddleElement(vec)
arguments
    vec {mustBeNumeric}
end

if ~(isrow(vec) || iscolumn(vec))
    error("Input array must be row or column vector");
end
nElements = numel(vec);
locMiddleElemenet = (nElements + 1)/2;
middleElement = vec(locMiddleElemenet);
end



function update = correctUpdate(relevantRules,update)
arguments
    relevantRules (:,2) double
    update (1,:) double
end
% check if all pages are unique
if numel(unique(update)) ~= numel(update)
    error("Some pages are repeated, this method won't work as is.")
end

nRules = height(relevantRules);
isThisRuleSatisfied = false(nRules,1);
isAllRulesSatisfied = false;
iter = 0;
while ~isAllRulesSatisfied
    iter = iter + 1;
    for iRule = 1:nRules
        rule = relevantRules(iRule,:);
        pageBefore = rule(1);
        pageAfter = rule(2);
        indxPageBefore = update == pageBefore;
        indxPageAfter = update == pageAfter;
        locPageBefore = find(indxPageBefore,1,'last');
        locPageAfter = find(indxPageAfter,1,'first');
        isThisRuleSatisfied(iRule) = locPageBefore < locPageAfter;
        
        if isThisRuleSatisfied(iRule)
            continue
        end

        % swap position of pagr before and page after
        pageBefore = update(indxPageBefore);
        pageAfter = update(indxPageAfter);
        update(indxPageBefore) = pageAfter;
        update(indxPageAfter) = pageBefore;
    end
    isAllRulesSatisfied = all(isThisRuleSatisfied);
end
end
