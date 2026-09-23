function [mdd, ddSeries] = maxDrawdown(equityCurve)
%MAXDRAWDOWN Maximum peak-to-trough decline of an equity/price curve.
%   MDD = MAXDRAWDOWN(EQUITYCURVE) returns the largest fractional drop
%   from a running peak, as a positive number (e.g. 0.23 = a 23% drawdown).
%   EQUITYCURVE can be a matrix (one column per series); MDD is a row
%   vector.
%
%   [MDD, DDSERIES] = MAXDRAWDOWN(...) also returns the full drawdown
%   series (same size as EQUITYCURVE) so you can plot it.
%
%   Vectorized via CUMMAX — no loop over time.

    runningPeak = cummax(equityCurve, 1);
    ddSeries = (equityCurve - runningPeak) ./ runningPeak;   % <= 0 always
    mdd = -min(ddSeries, [], 1);                              % report as positive
end
