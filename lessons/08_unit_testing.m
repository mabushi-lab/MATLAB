%% Lesson 8 — Unit testing with matlab.unittest
% MATLAB has a real, built-in test framework (matlab.unittest), not a
% third-party add-on like pytest/JUnit. A test file is a classdef, same
% shape as BankAccount.m from lesson 7, but inheriting from
% matlab.unittest.TestCase instead of handle.
%
% This lesson is a tiny worked example; the REAL tests for this project
% live in ../tests/ and test the actual toolbox functions. Run them with:
%
%   results = runtests('tests');   % from the project root
%   table(results)                 % pretty summary
%
% (This needs real MATLAB — GNU Octave does not implement matlab.unittest.)

%% Anatomy of a test file (this is what's in a *.m test file, not run here)
%{
classdef TestExample < matlab.unittest.TestCase
    methods (Test)
        function additionWorks(testCase)
            testCase.verifyEqual(1 + 1, 2);
        end

        function floatsNeedTolerance(testCase)
            % Never verifyEqual two floats exactly (see lesson 4) — use
            % a tolerance object instead.
            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.AbsoluteTolerance
            testCase.verifyThat(0.1 + 0.2, ...
                IsEqualTo(0.3, 'Within', AbsoluteTolerance(1e-9)));
            % or the shorthand:
            testCase.verifyEqual(0.1 + 0.2, 0.3, 'AbsTol', 1e-9);
        end

        function badInputThrows(testCase)
            testCase.verifyError(@() sqrt('not a number'), ...
                'MATLAB:UndefinedFunction');   % or whatever error ID applies
        end
    end
end
%}
% Key pieces:
%   - One classdef per file, filename == class name (same rule as
%     BankAccount.m).
%   - `methods (Test)` — every method in this block is auto-discovered
%     and run as a separate test case. No decorator/registration needed.
%   - `testCase.verifyXxx(...)` records a failure but keeps running the
%     rest of that test method (good for "check several things, report
%     them all"). `testCase.assertXxx(...)` stops immediately (good when
%     a later check would crash if an earlier one failed, e.g. asserting
%     a variable isn't empty before indexing into it).
%   - `verifyError(@() someCall(), 'id:here')` checks that a function
%     handle throws — you wrap the call in @() so it isn't executed
%     until inside the verify.

%% Try it for real
% Open a file in ../tests/, e.g. TestComputeReturns.m, then from the
% Command Window (project root):
%
%   runtests('tests/TestComputeReturns.m')
%
% or run the whole suite:
%
%   runtests('tests')

%% Why bother, for a solo learning project?
% Two honest reasons, not just "best practice":
%   1. You WILL refactor movingAverage.m or backtestSMACrossover.m at
%      some point (add a feature, fix an edge case). Tests tell you in
%      one command whether you broke something that used to work,
%      instead of noticing three files later.
%   2. Writing the test forces you to state, precisely, what a function
%      is supposed to do on a KNOWN input — which is exactly the kind of
%      "did I actually get this right" check this whole project relies
%      on Octave for, in lieu of having MATLAB here. tests/ is that same
%      idea, permanent, and runnable by you at any time.
