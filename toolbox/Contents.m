% MARKETLENS TOOLBOX
% Version 1.0 24-Sep-2026
%
% This file follows MATLAB's Contents.m convention: with this folder on
% the path, running `help toolbox` (or `help MarketLens` once this
% folder is added as a proper toolbox) prints exactly this list. Every
% function below has its own, more detailed help — `help <name>` or
% `doc <name>` for the full description, e.g. `help computeReturns`.
%
% Data loading
%   loadPriceData           - Read a wide-format price CSV into a sorted table
%
% Returns & rolling statistics
%   computeReturns          - Simple or log returns from a price series
%   movingAverage           - Trailing simple moving average
%   rollingVolatility       - Rolling annualized volatility of returns
%
% Risk/return metrics
%   sharpeRatio              - Annualized Sharpe ratio
%   maxDrawdown              - Maximum peak-to-trough decline
%
% Technical indicators
%   computeRSI               - Relative Strength Index
%   computeBollingerBands    - Rolling mean +/- k standard deviations
%
% Backtesting strategies (each returns the same result-struct shape)
%   backtestSMACrossover     - Long/flat fast/slow SMA crossover
%   backtestRSI              - Long/flat RSI mean-reversion
%   backtestBollinger        - Long/flat Bollinger Bands mean-reversion
%   buildBacktestResult      - Shared equity-curve/metrics builder used
%                              by all three strategies above
%
% Comparing strategies & the object-oriented interface
%   compareStrategies        - Plot + summarize several backtest results
%   PortfolioAnalyzer        - Class wrapping the functions above into
%                              one object you construct once
%
% See also the lessons/ and tests/ folders one level up, and README.md
% for how this toolbox fits together.
