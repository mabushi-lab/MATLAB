function r = computeReturns(prices, method)
%COMPUTERETURNS Period-over-period returns of a price series/matrix.
%   R = COMPUTERETURNS(PRICES) returns simple returns:
%       r(t) = prices(t)/prices(t-1) - 1
%   R = COMPUTERETURNS(PRICES, 'log') returns log returns instead:
%       r(t) = log(prices(t)/prices(t-1))
%
%   PRICES can be a column vector (one series) or a matrix with each
%   COLUMN a separate series (e.g. one column per ticker) — the output
%   has one fewer row than the input, since the first period has no
%   prior price to compare against.
%
%   Fully vectorized: no loop over time or over columns.

    if nargin < 2
        method = 'simple';
    end
    if isrow(prices)
        prices = prices(:);   % normalize to column orientation
    end

    p0 = prices(1:end-1, :);
    p1 = prices(2:end, :);

    switch lower(method)
        case 'simple'
            r = p1 ./ p0 - 1;
        case 'log'
            r = log(p1 ./ p0);
        otherwise
            error('computeReturns:badMethod', ...
                "method must be 'simple' or 'log', got '%s'", method);
    end
end
