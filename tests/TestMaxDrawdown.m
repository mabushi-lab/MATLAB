classdef TestMaxDrawdown < matlab.unittest.TestCase
    %TESTMAXDRAWDOWN Tests for toolbox/maxDrawdown.m

    methods (TestClassSetup)
        function addToolboxToPath(testCase)
            here = fileparts(mfilename('fullpath'));
            projectRoot = fileparts(here);
            addpath(fullfile(projectRoot, 'toolbox'));
        end
    end

    methods (Test)
        function knownDrawdownMatchesHandCalculation(testCase)
            equity = [1; 1.2; 0.9; 1.1];
            % running peak: 1, 1.2, 1.2, 1.2
            % trough at index 3: (0.9 - 1.2)/1.2 = -0.25 -> drawdown 0.25
            mdd = maxDrawdown(equity);
            testCase.verifyEqual(mdd, 0.25, 'AbsTol', 1e-12);
        end

        function monotonicIncreaseHasZeroDrawdown(testCase)
            equity = [1; 1.1; 1.2; 1.3];
            mdd = maxDrawdown(equity);
            testCase.verifyEqual(mdd, 0, 'AbsTol', 1e-12);
        end

        function monotonicDecreaseDrawdownEqualsTotalLoss(testCase)
            equity = [1; 0.8; 0.5];
            mdd = maxDrawdown(equity);
            testCase.verifyEqual(mdd, 0.5, 'AbsTol', 1e-12);
        end

        function multiColumnInputHandledPerColumn(testCase)
            equity = [1 1; 1.2 0.9; 0.9 0.9; 1.1 1.0];
            mdd = maxDrawdown(equity);
            testCase.verifyEqual(size(mdd), [1 2]);
            testCase.verifyEqual(mdd(1), 0.25, 'AbsTol', 1e-12);
        end

        function drawdownSeriesIsAlwaysNonPositive(testCase)
            equity = [1; 1.3; 0.7; 1.5; 0.6; 1.8];
            [~, ddSeries] = maxDrawdown(equity);
            testCase.verifyTrue(all(ddSeries <= 0));
        end
    end
end
