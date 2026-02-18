function L = logb(x, base)
% log(X) to the base "base"
% If base is not supplied, then the natural log is presumed.

if (nargin < 2) || isempty(base)
    % default case is the natural log
    L = log(x);
else
    % test for an invalid base
    if any(base<=0) || any(base == 1)
        error('Base must be > 0, and ~= 1')
    end

    L = log(x)./log(base);
end
end