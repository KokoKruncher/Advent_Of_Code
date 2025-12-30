clear; clc; close all;

inputText = readlines("D19 Data.txt");
if inputText(end) == ""
    inputText(end) = [];
end

towels = convertStringsToChars(split(inputText(1), ", "));
designs = convertStringsToChars(inputText(3:end));

%% Part 1
nDesigns = numel(designs);
isPossible = false(nDesigns, 1);
for ii = 1:nDesigns
    % fprintf("%i/%i\n", ii, nDesigns);
    isPossible(ii) = bfs(designs{ii}, towels);
end

nDesignsPossible = nnz(isPossible);
fprintf("Number of possible designs = %i\n", nDesignsPossible);

%% Functions
function isPossible = bfs(design, towels)
arguments
    design (1,:) char
    towels cell {mustBeText}
end
isPossible = true;

nLettersDesign = numel(design);
nTowels = numel(towels);

queue = Queue();
seen = Set();

% {current towel, design letter index}
startState = {'', 0};
queue.append(startState);
while queue.hasElements()
    state = queue.pop();

    if seen.contains(state)
        continue
    end
    seen.add(state);

    % towel = state{1};
    designLetterIndex = state{2};

    if designLetterIndex == nLettersDesign
        return
    end

    for iTowel = 1:nTowels
        nextTowel = towels{iTowel};
        nLettersNextTowel = numel(nextTowel);

        if designLetterIndex + nLettersNextTowel > nLettersDesign
            continue
        end

        if ~isValid(nextTowel, designLetterIndex)
            continue
        end
        
        queue.append({nextTowel, designLetterIndex + nLettersNextTowel});
    end
end

isPossible = false;

% Nested functions
    function tf = isValid(towel, designIndex)
        tf = ~any(design(designIndex + 1 : designIndex + numel(towel)) ~= towel);
    end
end