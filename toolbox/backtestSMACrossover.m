function result = backtestSMACrossover(prices, fastWindow, slowWindow)
%BACKTESTSMACROSSOVER Long/flat backtest of a fast/slow SMA crossover.
%   RESULT = BACKTESTSMACROSSOVER(PRICES, FASTWINDOW, SLOWWINDOW) runs a
%   simple rule on a single price series PRICES (column vector):
%       position(t) =  1  if SMA(fast) crossed above SMA(slow) as of t-1
%                       0  otherwise (flat, no shorting)
%   using YESTERDAY's signal to decide TODAY's position, so the backtest
%   doesn't cheat by trading on information not yet available at the
%   open of day t (a classic beginner bug — using day t's own close to
%   decide day t's position).
%
%   RESULT is a struct with fields:
%       .position      Nx1  (0 or 1), NaN while SMAs are still warming up
%       .strategyReturns Nx1 daily returns actually earned
%       .equityCurve   Nx1, starts at 1.0
%       .buyHoldCurve  Nx1, starts at 1.0 (benchmark: just hold the asset)
%       .totalReturn, .sharpe, .maxDrawdown  scalars, strategy vs buy&hold

    if ~iscolumn(prices)
        prices = prices(:);
    end
    if fastWindow >= slowWindow
        error('backtestSMACrossover:badWindows', ...
            'fastWindow must be smaller than slowWindow.');
    end

    fastSMA = movingAverage(prices, fastWindow);
    slowSMA = movingAverage(prices, slowWindow);

    rawSignal = double(fastSMA > slowSMA);  % double, not logical: we need
                                             % to punch NaN into it next,
                                             % and logical arrays can't
                                             % hold NaN (only true/false).
    rawSignal(isnan(fastSMA) | isnan(slowSMA)) = NaN;  % preserve warm-up as NaN

    % Lag the signal by one day: today's POSITION is yesterday's SIGNAL.
    position = [NaN; rawSignal(1:end-1)];
    position(isnan(position)) = 0;          % no position during warm-up

    assetReturns = computeReturns(prices);              % length N-1
    posForReturns = position(2:end);                    % align: position(t) earns assetReturns(t)
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
