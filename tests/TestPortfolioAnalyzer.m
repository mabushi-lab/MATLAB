classdef TestPortfolioAnalyzer < matlab.unittest.TestCase
    %TESTPORTFOLIOANALYZER Tests for toolbox/PortfolioAnalyzer.m
    %   Needs real MATLAB — table() isn't implemented in GNU Octave, so
    %   unlike every other test file in this project, this one could
    %   only be verified by careful manual review while building it, not
    %   by actually running it. Run it for real with
    %   runtests('tests/TestPortfolioAnalyzer.m') the first time you're
    %   in MATLAB, to close that gap yourself.
    %
    %   Strategy: rather than hand-computing expected numbers (easy to
    %   get wrong by hand and prove nothing about the WIRING), most
    %   tests check that going through the OBJECT produces exactly the
    %   same result as calling the corresponding toolbox FUNCTION
    %   directly on the same columns — i.e. testing that
    %   PortfolioAnalyzer correctly delegates to the functions it wraps,
    %   which is the kind of thing a class like this can actually get
    %   wrong (wrong column selected, arguments passed out of order,
    %   a stale default, ...), rather than re-deriving math already
    %   covered by TestComputeReturns, TestBacktestSMACrossover, etc.

    properties
        PriceTable
        TickerAPrices
        TickerBPrices
    end

    methods (TestClassSetup)
        function addToolboxToPath(testCase)
            here = fileparts(mfilename('fullpath'));
            projectRoot = fileparts(here);
            addpath(fullfile(projectRoot, 'toolbox'));
        end
    end

    methods (TestMethodSetup)
        function makeFixture(testCase)
            rngState = rng(7, 'twister');
            testCase.addTeardown(@() rng(rngState));

            dates = (datetime(2024, 1, 1) + days(0:99))';
            testCase.TickerAPrices = 100 + cumsum(randn(100, 1));
            testCase.TickerBPrices = 50 + cumsum(randn(100, 1) * 0.5);
            testCase.PriceTable = table(dates, testCase.TickerAPrices, testCase.TickerBPrices, ...
                'VariableNames', {'Date', 'TickerA', 'TickerB'});
        end
    end

    methods (Test)
        function constructorInfersTickersFromColumnsInOrder(testCase)
            pa = PortfolioAnalyzer(testCase.PriceTable);
            testCase.verifyEqual(pa.Tickers, {'TickerA', 'TickerB'});
        end

        function constructorAcceptsExplicitTickerSubset(testCase)
            pa = PortfolioAnalyzer(testCase.PriceTable, {'TickerB'});
            testCase.verifyEqual(pa.Tickers, {'TickerB'});
            testCase.verifyEqual(pa.Prices, testCase.TickerBPrices);
        end

        function pricesMatrixMatchesSourceColumns(testCase)
            pa = PortfolioAnalyzer(testCase.PriceTable);
            testCase.verifyEqual(pa.Prices, [testCase.TickerAPrices, testCase.TickerBPrices]);
        end

        function returnsMatchDirectComputeReturnsCall(testCase)
            pa = PortfolioAnalyzer(testCase.PriceTable);
            expected = computeReturns([testCase.TickerAPrices, testCase.TickerBPrices]);
            testCase.verifyEqual(pa.Returns, expected, 'AbsTol', 1e-12);
        end

        function volatilityMatchesDirectRollingVolatilityCall(testCase)
            pa = PortfolioAnalyzer(testCase.PriceTable);
            expected = rollingVolatility(pa.Returns, 20, 252);
            testCase.verifyEqual(pa.volatility(20), expected, 'AbsTol', 1e-12);
        end

        function volatilityDefaultWindowIs20(testCase)
            pa = PortfolioAnalyzer(testCase.PriceTable);
            testCase.verifyEqual(pa.volatility(), pa.volatility(20), 'AbsTol', 1e-12);
        end

        function sharpeMatchesDirectSharpeRatioCall(testCase)
            pa = PortfolioAnalyzer(testCase.PriceTable);
            pa.RiskFreeRate = 0.03;
            expected = sharpeRatio(pa.Returns, 0.03, 252);
            testCase.verifyEqual(pa.sharpe(), expected, 'AbsTol', 1e-12);
        end

        function drawdownMatchesDirectMaxDrawdownCall(testCase)
            pa = PortfolioAnalyzer(testCase.PriceTable);
            expected = maxDrawdown(pa.Prices);
            testCase.verifyEqual(pa.drawdown(), expected, 'AbsTol', 1e-12);
        end

        function summaryTableHasOneRowPerTickerInOrder(testCase)
            pa = PortfolioAnalyzer(testCase.PriceTable);
            T = pa.summaryTable();
            testCase.verifyEqual(height(T), 2);
            testCase.verifyEqual(T.Ticker, {'TickerA'; 'TickerB'});
        end

        function summaryTableSharpeColumnMatchesSharpeMethod(testCase)
            pa = PortfolioAnalyzer(testCase.PriceTable);
            T = pa.summaryTable();
            sr = pa.sharpe();
            testCase.verifyEqual(T.Sharpe(:), sr(:), 'AbsTol', 1e-12);
        end

        function backtestSMAMatchesDirectFunctionCall(testCase)
            pa = PortfolioAnalyzer(testCase.PriceTable);
            actual = pa.backtestSMA('TickerA', 5, 20);
            expected = backtestSMACrossover(testCase.TickerAPrices, 5, 20);
            testCase.verifyEqual(actual, expected);
        end

        function backtestAliasMatchesBacktestSMA(testCase)
            pa = PortfolioAnalyzer(testCase.PriceTable);
            testCase.verifyEqual(pa.backtest('TickerA', 5, 20), pa.backtestSMA('TickerA', 5, 20));
        end

        function backtestRSIStrategyMatchesDirectFunctionCall(testCase)
            pa = PortfolioAnalyzer(testCase.PriceTable);
            actual = pa.backtestRSIStrategy('TickerB', 14, 30, 70);
            expected = backtestRSI(testCase.TickerBPrices, 14, 30, 70);
            testCase.verifyEqual(actual, expected);
        end

        function backtestRSIStrategyUsesDocumentedDefaults(testCase)
            pa = PortfolioAnalyzer(testCase.PriceTable);
            testCase.verifyEqual(pa.backtestRSIStrategy('TickerA'), ...
                pa.backtestRSIStrategy('TickerA', 14, 30, 70));
        end

        function backtestBollingerStrategyMatchesDirectFunctionCall(testCase)
            pa = PortfolioAnalyzer(testCase.PriceTable);
            actual = pa.backtestBollingerStrategy('TickerB', 20, 2);
            expected = backtestBollinger(testCase.TickerBPrices, 20, 2);
            testCase.verifyEqual(actual, expected);
        end

        function unknownTickerThrows(testCase)
            pa = PortfolioAnalyzer(testCase.PriceTable);
            testCase.verifyError(@() pa.backtestSMA('NOPE', 5, 20), ...
                'PortfolioAnalyzer:unknownTicker');
        end

        function compareAllStrategiesReturnsThreeRowsMatchingIndividualBacktests(testCase)
            testCase.addTeardown(@() close('all'));   % compareAllStrategies opens a figure
            pa = PortfolioAnalyzer(testCase.PriceTable);
            r1 = pa.backtestSMA('TickerA', 10, 30);
            r2 = pa.backtestRSIStrategy('TickerA', 14, 30, 70);
            r3 = pa.backtestBollingerStrategy('TickerA', 20, 2);

            T = pa.compareAllStrategies('TickerA');

            testCase.verifyEqual(height(T), 3);
            testCase.verifyEqual(T.Strategy, {'SMA 10/30'; 'RSI 14'; 'Bollinger 20/2'});
            testCase.verifyEqual(T.TotalReturn, ...
                [r1.totalReturn; r2.totalReturn; r3.totalReturn], 'AbsTol', 1e-12);
            testCase.verifyEqual(T.Sharpe, ...
                [r1.sharpe; r2.sharpe; r3.sharpe], 'AbsTol', 1e-12);
        end
    end
end
