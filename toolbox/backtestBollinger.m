function result = backtestBollinger(prices, windowSize, numStd)
%BACKTESTBOLLINGER Long/flat mean-reversion backtest using Bollinger Bands.
%   RESULT = BACKTESTBOLLINGER(PRICES, WINDOWSIZE, NUMSTD) goes LONG the
%   first day the price closes below the LOWER band (assumed oversold),
%   and goes FLAT once price recovers back up to the MIDDLE band (the
%   rolling mean). Defaults: windowSize=20, numStd=2.
%
%   Same state-machine-loop shape as backtestRSI.m — see the comment
%   there for why this one isn't vectorized. Result fields are built by
%   the shared buildBacktestResult.m.

    if nargin < 2, windowSize = 20; end
    if nargin < 3, numStd = 2; end
    if ~iscolumn(prices)
        prices = prices(:);
    end

    [middle, ~, lower] = computeBollingerBands(prices, windowSize, numStd);
    n = numel(prices);

    position = zeros(n, 1);
    position(1:windowSize) = NaN;
    inPosition = false;

    for t = (windowSize+1):n
        px = prices(t-1);
        if ~inPosition && px < lower(t-1)
            inPosition = true;
        elseif inPosition && px >= middle(t-1)
            inPosition = false;
        end
        position(t) = inPosition;
    end

    result = buildBacktestResult(prices, position);
end
