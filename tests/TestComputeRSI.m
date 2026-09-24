classdef TestComputeRSI < matlab.unittest.TestCase
    %TESTCOMPUTERSI Tests for toolbox/computeRSI.m

    methods (TestClassSetup)
        function addToolboxToPath(testCase)
            here = fileparts(mfilename('fullpath'));
            projectRoot = fileparts(here);
            addpath(fullfile(projectRoot, 'toolbox'));
        end
    end

    methods (Test)
        function warmupLengthIsWindowSizeMinusOne(testCase)
            prices = 100 + cumsum(randn(50, 1));
            rsi = computeRSI(prices, 14);
            testCase.verifyEqual(sum(isnan(rsi)), 13);
        end

        function valuesStayWithinZeroToHundred(testCase)
            prices = 100 + cumsum(randn(200, 1) * 0.5);
            rsi = computeRSI(prices, 14);
            valid = rsi(~isnan(rsi));
            testCase.verifyTrue(all(valid >= 0 & valid <= 100));
        end

        function strictlyRisingPricesGiveMaximumRSI(testCase)
            prices = (100:150)';
            rsi = computeRSI(prices, 14);
            testCase.verifyEqual(rsi(15:end), 100 * ones(37, 1));
        end

        function strictlyFallingPricesGiveMinimumRSI(testCase)
            prices = (150:-1:100)';
            rsi = computeRSI(prices, 14);
            testCase.verifyEqual(rsi(15:end), zeros(37, 1));
        end

        function defaultWindowIs14(testCase)
            % Note: verifyEqual treats NaN as equal to NaN (unlike the
            % == operator), so this correctly passes even though both
            % sides start with 13 NaN warm-up entries.
            prices = 100 + cumsum(randn(50, 1));
            testCase.verifyEqual(computeRSI(prices), computeRSI(prices, 14));
        end
    end
end
