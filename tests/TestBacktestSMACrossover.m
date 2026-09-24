classdef TestBacktestSMACrossover < matlab.unittest.TestCase
    %TESTBACKTESTSMACROSSOVER Tests for toolbox/backtestSMACrossover.m

    methods (TestClassSetup)
        function addToolboxToPath(testCase)
            here = fileparts(mfilename('fullpath'));
            projectRoot = fileparts(here);
            addpath(fullfile(projectRoot, 'toolbox'));
        end
    end

    methods (Test)
        function fastWindowMustBeSmallerThanSlow(testCase)
            prices = (1:20)';
            testCase.verifyError(@() backtestSMACrossover(prices, 10, 10), ...
                'backtestSMACrossover:badWindows');
            testCase.verifyError(@() backtestSMACrossover(prices, 20, 10), ...
                'backtestSMACrossover:badWindows');
        end

        function positionIsSameLengthAsPrices(testCase)
            prices = (100:2:160)';   % 31 rows
            result = backtestSMACrossover(prices, 3, 8);
            testCase.verifyEqual(numel(result.position), numel(prices));
        end

        function positionOnlyTakesValues0Or1DuringActivePeriod(testCase)
            prices = 100 + cumsum(randn(200, 1));
            result = backtestSMACrossover(prices, 5, 20);
            active = result.position(~isnan(result.position));
            testCase.verifyTrue(all(active == 0 | active == 1));
        end

        function signalIsLaggedByExactlyOneDay(testCase)
            % Hand-traced deterministic series: fast(2)/slow(4) SMA
            % first crosses UP between index 5 and index 6 (fastSMA(5)=11
            % > slowSMA(5)=10.5 is the first true crossing), so the
            % POSITION (which must not peek at today's own close) should
            % only turn on at index 6, not index 5. This is the
            % regression test for the NaN/logical bug caught earlier.
            prices = [10;10;10;10;12;14;16;18;10;8;6;4];
            result = backtestSMACrossover(prices, 2, 4);
            expectedPosition = [0;0;0;0;0;1;1;1;1;0;0;0];
            testCase.verifyEqual(result.position, expectedPosition);
        end

        function equityCurveStartsAtOne(testCase)
            prices = 100 + cumsum(randn(100, 1));
            result = backtestSMACrossover(prices, 5, 20);
            testCase.verifyEqual(result.equityCurve(1), 1);
            testCase.verifyEqual(result.buyHoldCurve(1), 1);
        end

        function flatPositionThroughoutGivesZeroStrategyReturn(testCase)
            % A strictly declining price never triggers a golden cross,
            % so the strategy should stay flat and earn exactly 0%.
            prices = (100:-1:50)';
            result = backtestSMACrossover(prices, 3, 8);
            testCase.verifyEqual(result.totalReturn, 0, 'AbsTol', 1e-12);
        end
    end
end
