function [middle, upper, lower] = computeBollingerBands(prices, windowSize, numStd)
%COMPUTEBOLLINGERBANDS Rolling mean +/- k standard deviations.
%   [MIDDLE, UPPER, LOWER] = COMPUTEBOLLINGERBANDS(PRICES, WINDOWSIZE, NUMSTD)
%   Defaults: windowSize=20, numStd=2 (the traditional "20-day, 2-sigma"
%   bands). All three outputs are the same size as PRICES, NaN during
%   warm-up.

    if nargin < 2, windowSize = 20; end
    if nargin < 3, numStd = 2; end
    if ~iscolumn(prices)
        prices = prices(:);
    end

    middle = movingAverage(prices, windowSize);

    rawStd = movstd(prices, [windowSize-1, 0], 0, 1, 'Endpoints', 'discard');
    padRows = size(prices, 1) - size(rawStd, 1);
    sd = [nan(padRows, 1); rawStd];

    upper = middle + numStd * sd;
    lower = middle - numStd * sd;
end
