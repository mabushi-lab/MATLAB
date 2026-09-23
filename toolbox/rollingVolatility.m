function vol = rollingVolatility(returns, windowSize, periodsPerYear)
%ROLLINGVOLATILITY Annualized rolling standard deviation of returns.
%   VOL = ROLLINGVOLATILITY(RETURNS, WINDOWSIZE) computes the rolling
%   std of RETURNS over WINDOWSIZE periods, annualized assuming 252
%   trading days/year (each column of RETURNS treated independently).
%
%   VOL = ROLLINGVOLATILITY(RETURNS, WINDOWSIZE, PERIODSPERYEAR) lets
%   you override the annualization factor (e.g. 12 for monthly data).

    if nargin < 3
        periodsPerYear = 252;
    end
    if windowSize < 2
        error('rollingVolatility:badWindow', 'windowSize must be >= 2.');
    end

    rawStd = movstd(returns, [windowSize-1, 0], 0, 1, 'Endpoints', 'discard');
    padRows = size(returns, 1) - size(rawStd, 1);
    rawStd = [nan(padRows, size(returns, 2)); rawStd];

    vol = rawStd * sqrt(periodsPerYear);
end
