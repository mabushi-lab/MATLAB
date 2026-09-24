classdef TestComputeBollingerBands < matlab.unittest.TestCase
    %TESTCOMPUTEBOLLINGERBANDS Tests for toolbox/computeBollingerBands.m

    methods (TestClassSetup)
        function addToolboxToPath(testCase)
            here = fileparts(mfilename('fullpath'));
            projectRoot = fileparts(here);
            addpath(fullfile(projectRoot, 'toolbox'));
        end
    end

    methods (Test)
        function middleBandEqualsMovingAverage(testCase)
            prices = 100 + cumsum(randn(80, 1));
            [middle, ~, ~] = computeBollingerBands(prices, 20, 2);
            testCase.verifyEqual(middle, movingAverage(prices, 20));
        end

        function upperIsAlwaysAboveLowerWherePresent(testCase)
            prices = 100 + cumsum(randn(80, 1));
            [~, upper, lower] = computeBollingerBands(prices, 20, 2);
            valid = ~isnan(upper);
            testCase.verifyTrue(all(upper(valid) >= lower(valid)));
        end

        function constantPriceGivesZeroWidthBands(testCase)
            % No volatility -> upper == middle == lower (std = 0)
            prices = 50 * ones(30, 1);
            [middle, upper, lower] = computeBollingerBands(prices, 10, 2);
            valid = ~isnan(middle);
            testCase.verifyEqual(upper(valid), middle(valid), 'AbsTol', 1e-12);
            testCase.verifyEqual(lower(valid), middle(valid), 'AbsTol', 1e-12);
        end

        function largerNumStdWidensTheBands(testCase)
            prices = 100 + cumsum(randn(80, 1));
            [~, upperNarrow, lowerNarrow] = computeBollingerBands(prices, 20, 1);
            [~, upperWide, lowerWide] = computeBollingerBands(prices, 20, 3);
            valid = ~isnan(upperNarrow);
            testCase.verifyTrue(all(upperWide(valid) >= upperNarrow(valid)));
            testCase.verifyTrue(all(lowerWide(valid) <= lowerNarrow(valid)));
        end
    end
end
