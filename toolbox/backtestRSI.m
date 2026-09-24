function result = backtestRSI(prices, rsiWindow, oversold, overbought)
%BACKTESTRSI Long/flat mean-reversion backtest using RSI thresholds.
%   RESULT = BACKTESTRSI(PRICES, RSIWINDOW, OVERSOLD, OVERBOUGHT)
%   goes LONG the first day RSI drops below OVERSOLD (buying the dip),
%   and goes FLAT the first day RSI rises above OVERBOUGHT afterwards.
%   Defaults: rsiWindow=14, oversold=30, overbought=70.
%
%   Unlike backtestSMACrossover (a pure function of yesterday's SMAs),
%   this strategy has MEMORY — "am I currently in a position" — so it's
%   written as an explicit state-machine loop over time rather than a
%   single vectorized expression. That's a deliberate contrast: not
%   everything vectorizes cleanly, and a loop over ~hundreds of days is
%   completely fine performance-wise. Loop over the big dimension
%   (here, none — there's no way around visiting each day in order)
%   only when there's a genuine sequential dependency like this one.
%
%   RESULT has the same fields as backtestSMACrossover's output, so it
%   can be passed straight into compareStrategies.

    if nargin < 2, rsiWindow = 14; end
    if nargin < 3, oversold = 30; end
    if nargin < 4, overbought = 70; end
    if ~iscolumn(prices)
        prices = prices(:);
    end

    rsi = computeRSI(prices, rsiWindow);
    n = numel(prices);

    position = zeros(n, 1);
    position(1:rsiWindow) = NaN;         % warm-up, no signal yet
    inPosition = false;

    for t = (rsiWindow+1):n
        signal = rsi(t-1);               % yesterday's RSI decides today's position
        if ~inPosition && signal < oversold
            inPosition = true;
        elseif inPosition && signal > overbought
            inPosition = false;
        end
        position(t) = inPosition;
    end

    assetReturns = computeReturns(prices);
    posForReturns = position(2:end);
    posForReturns(isnan(posForReturns)) = 0;
    strategyReturns = posForReturns .* assetReturns;

    equityCurve = [1; cumprod(1 + strategyReturns)];
    buyHoldCurve = [1; cumprod(1 + assetReturns)];

    result.position = position;
    result.strategyReturns = strategyReturns;
    result.equityCurve = equityCurve;
    result.buyHoldCurve = buyHoldCurve;

    result.totalReturn = equityCurve(end) - 1;
    result.buyHoldTotalReturn = buyHoldCurve(end) - 1;
    result.sharpe = sharpeRatio(strategyReturns);
    result.buyHoldSharpe = sharpeRatio(assetReturns);
    result.maxDrawdown = maxDrawdown(equityCurve);
    result.buyHoldMaxDrawdown = maxDrawdown(buyHoldCurve);
end
