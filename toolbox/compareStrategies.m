function T = compareStrategies(results, labels, dates)
%COMPARESTRATEGIES Plot several backtest results together + summary table.
%   T = COMPARESTRATEGIES(RESULTS, LABELS) takes a cell array of result
%   structs (as returned by backtestSMACrossover / backtestRSI /
%   backtestBollinger — anything with .equityCurve, .totalReturn,
%   .sharpe, .maxDrawdown fields) and a matching cellstr of names, plots
%   every equity curve on one figure alongside the shared buy & hold
%   curve, and returns a comparison table.
%
%   T = COMPARESTRATEGIES(RESULTS, LABELS, DATES) uses DATES for the
%   x-axis instead of a plain sample index.
%
%   Example:
%       r1 = backtestSMACrossover(prices, 10, 30);
%       r2 = backtestRSI(prices, 14, 30, 70);
%       r3 = backtestBollinger(prices, 20, 2);
%       compareStrategies({r1, r2, r3}, {'SMA 10/30', 'RSI 14', 'Bollinger 20/2'});

    if numel(results) ~= numel(labels)
        error('compareStrategies:sizeMismatch', ...
            'results and labels must have the same number of elements.');
    end

    n = numel(results{1}.equityCurve);
    if nargin < 3 || isempty(dates)
        x = (1:n)';
        xlabelText = 'Sample';
    else
        x = dates;
        xlabelText = 'Date';
    end

    figure;
    plot(x, results{1}.buyHoldCurve, '--', 'Color', [0.5 0.5 0.5], ...
        'LineWidth', 1.3, 'DisplayName', 'Buy & hold');
    hold on
    for i = 1:numel(results)
        plot(x, results{i}.equityCurve, 'LineWidth', 1.4, 'DisplayName', labels{i});
    end
    hold off
    legend('show', 'Location', 'best');
    title('Strategy comparison (growth of $1)');
    xlabel(xlabelText); ylabel('Equity');
    grid on;

    strategyNames = labels(:);
    totalReturn = cellfun(@(r) r.totalReturn, results(:));
    sharpe = cellfun(@(r) r.sharpe, results(:));
    maxDD = cellfun(@(r) r.maxDrawdown, results(:));

    T = table(strategyNames, totalReturn, sharpe, maxDD, ...
        'VariableNames', {'Strategy', 'TotalReturn', 'Sharpe', 'MaxDrawdown'});
end
