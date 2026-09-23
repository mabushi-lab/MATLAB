function sr = sharpeRatio(returns, riskFreeRate, periodsPerYear)
%SHARPERATIO Annualized Sharpe ratio of a return series.
%   SR = SHARPERATIO(RETURNS) assumes a 0 risk-free rate and 252
%   trading periods/year. RETURNS may be a matrix (one column per
%   series); SR is a row vector, one value per column.
%
%   SR = SHARPERATIO(RETURNS, RISKFREERATE) subtracts an ANNUAL
%   risk-free rate (e.g. 0.03 for 3%) before annualizing.
%
%   SR = SHARPERATIO(RETURNS, RISKFREERATE, PERIODSPERYEAR) overrides
%   the annualization factor.

    if nargin < 2, riskFreeRate = 0; end
    if nargin < 3, periodsPerYear = 252; end

    periodRf = riskFreeRate / periodsPerYear;
    excess = returns - periodRf;

    meanExcess = mean(excess, 1);
    sdExcess = std(excess, 0, 1);

    sr = (meanExcess ./ sdExcess) * sqrt(periodsPerYear);
end
