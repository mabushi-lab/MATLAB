classdef TestStrategies < matlab.unittest.TestCase
    %TESTSTRATEGIES Shared property tests for backtestRSI.m and
    %backtestBollinger.m — the two mean-reversion strategies added
    %alongside backtestSMACrossover.m. These check the CONTRACT every
    %backtest function in this toolbox should satisfy, rather than
    %tracing exact numbers (see TestBacktestSMACrossover for a fully
    %hand-traced example of that style).

    properties
        Prices
    end

    methods (TestClassSetup)
        function addToolboxToPath(testCase)
            here = fileparts(mfilename('fullpath'));
            projectRoot = fileparts(here);
            addpath(fullfile(projectRoot, 'toolbox'));
        end
    end

    methods (TestMethodSetup)
        function makeDeterministicPrices(testCase)
            rngState = rng(123, 'twister');
            testCase.addTeardown(@() rng(rngState));
            testCase.Prices = 100 + cumsum(randn(300, 1) * 0.5);
        end
    end

    methods (Test)
        function rsiPositionIsSameLengthAsPrices(testCase)
            result = backtestRSI(testCase.Prices, 14, 30, 70);
            testCase.verifyEqual(numel(result.position), numel(testCase.Prices));
        end

        function rsiPositionOnlyTakes0Or1(testCase)
            result = backtestRSI(testCase.Prices, 14, 30, 70);
            active = result.position(~isnan(result.position));
            testCase.verifyTrue(all(active == 0 | active == 1));
        end

        function rsiEquityCurveStartsAtOne(testCase)
            result = backtestRSI(testCase.Prices, 14, 30, 70);
            testCase.verifyEqual(result.equityCurve(1), 1);
        end

        function bollingerPositionIsSameLengthAsPrices(testCase)
            result = backtestBollinger(testCase.Prices, 20, 2);
            testCase.verifyEqual(numel(result.position), numel(testCase.Prices));
        end

        function bollingerPositionOnlyTakes0Or1(testCase)
            result = backtestBollinger(testCase.Prices, 20, 2);
            active = result.position(~isnan(result.position));
            testCase.verifyTrue(all(active == 0 | active == 1));
        end

        function bollingerEquityCurveStartsAtOne(testCase)
            result = backtestBollinger(testCase.Prices, 20, 2);
            testCase.verifyEqual(result.equityCurve(1), 1);
        end

        function bothStrategiesAgreeWithBuyHoldBaseline(testCase)
            % Both functions compute buyHoldCurve the same way — from
            % the SAME price series they should produce an IDENTICAL
            % buy & hold curve regardless of which strategy generated it.
            r1 = backtestRSI(testCase.Prices, 14, 30, 70);
            r2 = backtestBollinger(testCase.Prices, 20, 2);
            testCase.verifyEqual(r1.buyHoldCurve, r2.buyHoldCurve, 'AbsTol', 1e-12);
        end
    end
end
