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
%   (built by buildBacktestResult.m, shared with backtestRSI.m and
%   backtestBollinger.m — this function only decides the position.)

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
    % NaN (no signal yet) is left as NaN here on purpose — see
    % buildBacktestResult.m for why that's not the same as "flat".
    position = [NaN; rawSignal(1:end-1)];

    result = buildBacktestResult(prices, position);
end
