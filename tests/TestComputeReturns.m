classdef TestComputeReturns < matlab.unittest.TestCase
    %TESTCOMPUTERETURNS Tests for toolbox/computeReturns.m

    methods (TestClassSetup)
        function addToolboxToPath(testCase)
            here = fileparts(mfilename('fullpath'));
            projectRoot = fileparts(here);
            addpath(fullfile(projectRoot, 'toolbox'));
        end
    end

    methods (Test)
        function simpleReturnsMatchHandCalculation(testCase)
            prices = [100; 110; 121];   % +10% each step
            r = computeReturns(prices);
            testCase.verifyEqual(r, [0.10; 0.10], 'AbsTol', 1e-12);
        end

        function logReturnsMatchHandCalculation(testCase)
            prices = [100; 110; 121];
            r = computeReturns(prices, 'log');
            testCase.verifyEqual(r, [log(1.1); log(1.1)], 'AbsTol', 1e-12);
        end

        function outputIsOneShorterThanInput(testCase)
            prices = (100:5:150)';   % 11 rows
            r = computeReturns(prices);
            testCase.verifyEqual(numel(r), numel(prices) - 1);
        end

        function handlesMultiColumnInputIndependently(testCase)
            prices = [100 200; 110 220; 121 242];   % col 2 = 2x col 1
            r = computeReturns(prices);
            testCase.verifyEqual(r(:,1), r(:,2), 'AbsTol', 1e-12);
        end

        function unknownMethodThrows(testCase)
            prices = [100; 110];
            testCase.verifyError(@() computeReturns(prices, 'bogus'), ...
                'computeReturns:badMethod');
        end

        function rowVectorInputIsNormalizedToColumn(testCase)
            prices = [100 110 121];   % row vector
            r = computeReturns(prices);
            testCase.verifyEqual(size(r), [2 1]);
        end
    end
end
