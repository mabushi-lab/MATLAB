%% main_demo.m — run the whole toolbox end to end
% Prerequisite: run `addpath(genpath(pwd))` from the project root first
% (or just open this file in MATLAB and hit Run — it adds its own path
% below so it works either way).

close all; clc;

thisDir = fileparts(mfilename('fullpath'));
addpath(fullfile(thisDir, 'toolbox'));

%% Load data
T = loadPriceData(fullfile(thisDir, 'data', 'sample_prices.csv'));
fprintf('Loaded %d rows, %d tickers.\n', height(T), width(T) - 1);
disp(head(T, 3));

%% Build the analyzer
tickers = {'AAPL', 'MSFT', 'TSLA', 'SPY'};
pa = PortfolioAnalyzer(T, tickers);
pa.RiskFreeRate = 0.02;   % 2% annual risk-free rate for Sharpe

%% Summary stats per ticker
summary = pa.summaryTable();
disp(summary);

%% Plot 1: normalized price curves for all tickers
pa.plotEquityCurves();

%% Plot 2: rolling 20-day annualized volatility, all tickers
vol = pa.volatility(20);
figure;
plot(pa.Dates(2:end), vol, 'LineWidth', 1.2);   % vol is one shorter (from returns)
legend(pa.Tickers, 'Location', 'best');
title('Rolling 20-day annualized volatility');
xlabel('Date'); ylabel('Volatility');
grid on;

%% Plot 3: SMA-crossover backtest on TSLA (the noisiest series)
result = pa.backtest('TSLA', 10, 30);
fprintf('\nTSLA 10/30 SMA crossover:\n');
fprintf('  Strategy total return: %6.2f%%   Buy&hold: %6.2f%%\n', ...
    100*result.totalReturn, 100*result.buyHoldTotalReturn);
fprintf('  Strategy Sharpe:       %6.2f     Buy&hold: %6.2f\n', ...
    result.sharpe, result.buyHoldSharpe);
fprintf('  Strategy max drawdown: %6.2f%%   Buy&hold: %6.2f%%\n', ...
    100*result.maxDrawdown, 100*result.buyHoldMaxDrawdown);

figure;
plot(pa.Dates, result.equityCurve, 'LineWidth', 1.5); hold on
plot(pa.Dates, result.buyHoldCurve, 'LineWidth', 1.5);
legend('SMA 10/30 strategy', 'Buy & hold', 'Location', 'best');
title('TSLA: strategy vs buy & hold (growth of $1)');
xlabel('Date'); ylabel('Equity');
grid on;

fprintf('\nDone. Try: app = MarketLensApp;  (needs real MATLAB, not Octave)\n');
