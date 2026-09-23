classdef PortfolioAnalyzer < handle
    %PORTFOLIOANALYZER Object-oriented wrapper around the toolbox functions.
    %   Construct once from a price table (as returned by loadPriceData),
    %   then call methods instead of re-passing data into each function.
    %   This is the "lesson 7 payoff" — same pattern as BankAccount.m,
    %   applied to something real.
    %
    %   Example:
    %       T = loadPriceData('data/sample_prices.csv');
    %       pa = PortfolioAnalyzer(T, {'AAPL','MSFT','TSLA','SPY'});
    %       pa.summaryTable()
    %       pa.plotEquityCurves()

    properties (SetAccess = private)
        Dates
        Tickers
        Prices          % NxK matrix, one column per ticker
        Returns          % (N-1)xK simple returns, cached lazily
    end

    properties
        PeriodsPerYear = 252
        RiskFreeRate = 0
    end

    methods
        function obj = PortfolioAnalyzer(priceTable, tickers)
            if nargin < 2
                tickers = setdiff(priceTable.Properties.VariableNames, {'Date'}, 'stable');
            end
            obj.Dates = priceTable.Date;
            obj.Tickers = tickers;
            obj.Prices = priceTable{:, tickers};
            obj.Returns = computeReturns(obj.Prices);
        end

        function vol = volatility(obj, windowSize)
            % Rolling annualized volatility, one column per ticker.
            if nargin < 2, windowSize = 20; end
            vol = rollingVolatility(obj.Returns, windowSize, obj.PeriodsPerYear);
        end

        function sr = sharpe(obj)
            % Annualized Sharpe ratio per ticker (1xK row vector).
            sr = sharpeRatio(obj.Returns, obj.RiskFreeRate, obj.PeriodsPerYear);
        end

        function mdd = drawdown(obj)
            % Max drawdown per ticker (1xK row vector), on raw prices.
            mdd = maxDrawdown(obj.Prices);
        end

        function T = summaryTable(obj)
            % One row per ticker: annualized return, volatility, Sharpe, maxDD.
            nPeriods = size(obj.Returns, 1);
            annReturn = mean(obj.Returns, 1) * obj.PeriodsPerYear;
            annVol = std(obj.Returns, 0, 1) * sqrt(obj.PeriodsPerYear);
            sr = obj.sharpe();
            mdd = obj.drawdown();

            T = table(obj.Tickers(:), annReturn(:), annVol(:), sr(:), mdd(:), ...
                'VariableNames', {'Ticker', 'AnnReturn', 'AnnVol', 'Sharpe', 'MaxDrawdown'});
        end

        function result = backtest(obj, ticker, fastWindow, slowWindow)
            % Run the SMA-crossover backtest on a single ticker by name.
            col = obj.tickerIndex(ticker);
            result = backtestSMACrossover(obj.Prices(:, col), fastWindow, slowWindow);
        end

        function plotEquityCurves(obj)
            % Normalize every ticker to start at 1.0 and plot together.
            normalized = obj.Prices ./ obj.Prices(1, :);
            figure;
            plot(obj.Dates, normalized, 'LineWidth', 1.3);
            legend(obj.Tickers, 'Location', 'best');
            title('Normalized price (start = 1.0)');
            xlabel('Date'); ylabel('Growth of $1');
            grid on;
        end
    end

    methods (Access = private)
        function col = tickerIndex(obj, ticker)
            col = find(strcmp(obj.Tickers, ticker), 1);
            if isempty(col)
                error('PortfolioAnalyzer:unknownTicker', ...
                    'Ticker "%s" not in this analyzer (have: %s).', ...
                    ticker, strjoin(obj.Tickers, ', '));
            end
        end
    end
end
