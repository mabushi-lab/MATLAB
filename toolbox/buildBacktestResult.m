function result = buildBacktestResult(prices, position)
%BUILDBACKTESTRESULT Turn a position vector into a full backtest result.
%   RESULT = BUILDBACKTESTRESULT(PRICES, POSITION) takes a price series
%   and a POSITION vector already decided by a strategy (0 = flat,
%   1 = long, NaN = no signal yet / still warming up — NOT the same as
%   "flat": NaN just means "undecided", so it's treated as 0 exposure
%   for return purposes but kept as NaN in the output so callers can
%   tell warm-up apart from a deliberate flat position) and computes
%   everything every strategy in this toolbox reports: returns, equity
%   curves, and the three headline metrics vs. a buy & hold benchmark.
%
%   This is shared by backtestSMACrossover.m, backtestRSI.m, and
%   backtestBollinger.m — each one only has to figure out ITS OWN
%   position vector (that's the actual strategy logic); this function is
%   the identical bookkeeping all three used to duplicate. Pulling it out
%   once here means a bug fix or a new metric only has to happen in one
%   place. See lesson 11 for more on when duplication is worth removing.
%
%   RESULT fields: .position, .strategyReturns, .equityCurve,
%   .buyHoldCurve, .totalReturn, .buyHoldTotalReturn, .sharpe,
%   .buyHoldSharpe, .maxDrawdown, .buyHoldMaxDrawdown — see any of the
%   three backtest*.m files for what each means.

    if ~iscolumn(prices)
        prices = prices(:);
    end
    if ~iscolumn(position)
        position = position(:);
    end
    if numel(position) ~= numel(prices)
        error('buildBacktestResult:sizeMismatch', ...
            'position must have the same number of rows as prices (got %d vs %d).', ...
            numel(position), numel(prices));
    end

    assetReturns = computeReturns(prices);      % length N-1
    posForReturns = position(2:end);            % position(t) earns assetReturns(t)
    posForReturns(isnan(posForReturns)) = 0;     % undecided -> no exposure
    strategyReturns = posForReturns .* assetReturns;

    equityCurve = [1; cumprod(1 + strategyReturns)];
    buyHoldCurve = [1; cumprod(1 + assetReturns)];

    result.position = position;                 % NaN warm-up preserved
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
