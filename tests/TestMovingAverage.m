classdef TestMovingAverage < matlab.unittest.TestCase
    %TESTMOVINGAVERAGE Tests for toolbox/movingAverage.m

    methods (TestClassSetup)
        function addToolboxToPath(testCase)
            here = fileparts(mfilename('fullpath'));
            projectRoot = fileparts(here);
            addpath(fullfile(projectRoot, 'toolbox'));
        end
    end

    methods (Test)
        function warmupPeriodIsNaN(testCase)
            x = (1:10)';
            ma = movingAverage(x, 3);
            testCase.verifyTrue(all(isnan(ma(1:2))));
        end

        function firstFullWindowMatchesHandCalculation(testCase)
            x = (1:10)';
            ma = movingAverage(x, 3);
            % window [1 2 3] -> mean 2
            testCase.verifyEqual(ma(3), 2, 'AbsTol', 1e-12);
        end

        function lastValueMatchesHandCalculation(testCase)
            x = (1:10)';
            ma = movingAverage(x, 3);
            % window [8 9 10] -> mean 9
            testCase.verifyEqual(ma(end), 9, 'AbsTol', 1e-12);
        end

        function outputIsSameSizeAsInput(testCase)
            x = (1:17)';
            ma = movingAverage(x, 5);
            testCase.verifyEqual(size(ma), size(x));
        end

        function constantSeriesGivesConstantAverage(testCase)
            x = 7 * ones(10, 1);
            ma = movingAverage(x, 4);
            testCase.verifyEqual(ma(4:end), 7 * ones(7, 1), 'AbsTol', 1e-12);
        end

        function nonIntegerWindowThrows(testCase)
            x = (1:10)';
            testCase.verifyError(@() movingAverage(x, 2.5), ...
                'movingAverage:badWindow');
        end

        function zeroWindowThrows(testCase)
            x = (1:10)';
            testCase.verifyError(@() movingAverage(x, 0), ...
                'movingAverage:badWindow');
        end
    end
end
