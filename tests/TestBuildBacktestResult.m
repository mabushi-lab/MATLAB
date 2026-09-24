classdef TestBuildBacktestResult < matlab.unittest.TestCase
    %TESTBUILDBACKTESTRESULT Tests for toolbox/buildBacktestResult.m
    %   This is the shared helper factored out of backtestSMACrossover,
    %   backtestRSI and backtestBollinger — testing it directly here
    %   means each strategy's own test file only needs to check that
    %   strategy's POSITION logic, not re-verify the equity-curve math.

    methods (TestClassSetup)
        function addToolboxToPath(testCase)
            here = fileparts(mfilename('fullpath'));
            projectRoot = fileparts(here);
            addpath(fullfile(projectRoot, 'toolbox'));
        end
    end

    methods (Test)
        function mismatchedLengthsThrow(testCase)
            prices = (1:10)';
            position = zeros(5, 1);
            testCase.verifyError(@() buildBacktestResult(prices, position), ...
                'buildBacktestResult:sizeMismatch');
        end

        function alwaysLongMatchesBuyHold(testCase)
            prices = 100 + cumsum(randn(50, 1));
            position = ones(50, 1);
            result = buildBacktestResult(prices, position);
            testCase.verifyEqual(result.equityCurve, result.buyHoldCurve, 'AbsTol', 1e-12);
        end

        function alwaysFlatEarnsNothing(testCase)
            prices = 100 + cumsum(randn(50, 1));
            position = zeros(50, 1);
            result = buildBacktestResult(prices, position);
            testCase.verifyEqual(result.totalReturn, 0, 'AbsTol', 1e-12);
            testCase.verifyEqual(result.equityCurve, ones(50, 1), 'AbsTol', 1e-12);
        end

        function nanPositionIsTreatedAsFlatForReturnsButKeptInOutput(testCase)
            % Alignment reminder: strategyReturns(i) is earned by
            % position(i+1) over the price move from day i to day i+1
            % (position(1) is never used — there's no "day 0" return to
            % pair it with, same as every backtest*.m in this toolbox).
            % So to test "NaN position -> zero return", the NaN needs to
            % be at position(2), not position(1).
            prices = [100; 110; 90; 120];
            position = [1; NaN; 1; 0];   % position(2) undecided
            result = buildBacktestResult(prices, position);
            % result.position should still show the NaN (not silently 0)
            testCase.verifyTrue(isnan(result.position(2)));
            % but the undecided day contributes no return: strategyReturns(1),
            % driven by position(2)=NaN, is treated as 0 exposure, so
            % strategyReturns(1) is 0 rather than 110/100-1 = 0.10.
            testCase.verifyEqual(result.strategyReturns(1), 0, 'AbsTol', 1e-12);
        end

        function buyHoldCurveIgnoresPositionEntirely(testCase)
            prices = 100 + cumsum(randn(30, 1));
            r1 = buildBacktestResult(prices, ones(30, 1));
            r2 = buildBacktestResult(prices, zeros(30, 1));
            testCase.verifyEqual(r1.buyHoldCurve, r2.buyHoldCurve, 'AbsTol', 1e-12);
        end
    end
end
