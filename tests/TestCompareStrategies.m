classdef TestCompareStrategies < matlab.unittest.TestCase
    %TESTCOMPARESTRATEGIES Tests for toolbox/compareStrategies.m
    %   Needs real MATLAB (builds a table) — see the note at the top of
    %   TestPortfolioAnalyzer.m for why this file couldn't be executed
    %   here either. The underlying aggregation arithmetic (pulling
    %   totalReturn/sharpe/maxDrawdown out of a cell array of result
    %   structs) WAS verified independently, without table(), while
    %   building this project; this file locks in the table-building
    %   step on top of that already-checked arithmetic.

    properties
        Prices
        R1
        R2
        R3
    end

    methods (TestClassSetup)
        function addToolboxToPath(testCase)
            here = fileparts(mfilename('fullpath'));
            projectRoot = fileparts(here);
            addpath(fullfile(projectRoot, 'toolbox'));
        end
    end

    methods (TestMethodSetup)
        function makeResults(testCase)
            rngState = rng(11, 'twister');
            testCase.addTeardown(@() rng(rngState));
            testCase.addTeardown(@() close('all'));   % every test here plots

            testCase.Prices = 100 + cumsum(randn(150, 1) * 0.5);
            testCase.R1 = backtestSMACrossover(testCase.Prices, 10, 30);
            testCase.R2 = backtestRSI(testCase.Prices, 14, 30, 70);
            testCase.R3 = backtestBollinger(testCase.Prices, 20, 2);
        end
    end

    methods (Test)
        function mismatchedResultsAndLabelsThrow(testCase)
            testCase.verifyError(@() compareStrategies( ...
                {testCase.R1, testCase.R2}, {'Only one label'}), ...
                'compareStrategies:sizeMismatch');
        end

        function tableHasOneRowPerStrategyInGivenOrder(testCase)
            T = compareStrategies({testCase.R1, testCase.R2, testCase.R3}, ...
                {'SMA', 'RSI', 'Bollinger'});
            testCase.verifyEqual(height(T), 3);
            testCase.verifyEqual(T.Strategy, {'SMA'; 'RSI'; 'Bollinger'});
        end

        function tableColumnsMatchSourceStructFields(testCase)
            T = compareStrategies({testCase.R1, testCase.R2, testCase.R3}, ...
                {'SMA', 'RSI', 'Bollinger'});
            testCase.verifyEqual(T.TotalReturn, ...
                [testCase.R1.totalReturn; testCase.R2.totalReturn; testCase.R3.totalReturn], ...
                'AbsTol', 1e-12);
            testCase.verifyEqual(T.Sharpe, ...
                [testCase.R1.sharpe; testCase.R2.sharpe; testCase.R3.sharpe], ...
                'AbsTol', 1e-12);
            testCase.verifyEqual(T.MaxDrawdown, ...
                [testCase.R1.maxDrawdown; testCase.R2.maxDrawdown; testCase.R3.maxDrawdown], ...
                'AbsTol', 1e-12);
        end

        function acceptsDatesForXAxisWithoutError(testCase)
            dates = (datetime(2024, 1, 1) + days(0:149))';
            testCase.verifyWarningFree(@() compareStrategies( ...
                {testCase.R1, testCase.R2, testCase.R3}, ...
                {'SMA', 'RSI', 'Bollinger'}, dates));
        end
    end
end
