classdef TestSharpeRatio < matlab.unittest.TestCase
    %TESTSHARPERATIO Tests for toolbox/sharpeRatio.m

    methods (TestClassSetup)
        function addToolboxToPath(testCase)
            here = fileparts(mfilename('fullpath'));
            projectRoot = fileparts(here);
            addpath(fullfile(projectRoot, 'toolbox'));
        end
    end

    methods (Test)
        function matchesHandCalculationWithNoRiskFreeRate(testCase)
            r = [0.01; -0.02; 0.03; 0.00; 0.015];
            expected = (mean(r) / std(r)) * sqrt(252);
            testCase.verifyEqual(sharpeRatio(r), expected, 'AbsTol', 1e-12);
        end

        function subtractsRiskFreeRateBeforeAnnualizing(testCase)
            r = [0.01; -0.02; 0.03; 0.00; 0.015];
            annualRf = 0.05;
            periodsPerYear = 252;
            periodRf = annualRf / periodsPerYear;
            expected = (mean(r - periodRf) / std(r - periodRf)) * sqrt(periodsPerYear);
            testCase.verifyEqual(sharpeRatio(r, annualRf), expected, 'AbsTol', 1e-12);
        end

        function respectsCustomAnnualizationFactor(testCase)
            r = [0.01; -0.02; 0.03; 0.00; 0.015];
            monthly = sharpeRatio(r, 0, 12);
            expected = (mean(r) / std(r)) * sqrt(12);
            testCase.verifyEqual(monthly, expected, 'AbsTol', 1e-12);
        end

        function handlesMultiColumnInputIndependently(testCase)
            r1 = [0.01; -0.02; 0.03; 0.00; 0.015];
            r2 = 2 * r1;   % scaled version, same shape -> same Sharpe
            r = [r1, r2];
            sr = sharpeRatio(r);
            testCase.verifyEqual(sr(1), sr(2), 'AbsTol', 1e-9);
        end

        function outputIsRowVectorForMatrixInput(testCase)
            r = randn(50, 3) * 0.01;
            sr = sharpeRatio(r);
            testCase.verifyEqual(size(sr), [1 3]);
        end
    end
end
