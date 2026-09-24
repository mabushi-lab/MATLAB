%% Lesson 9 — Error handling
% You've already seen error() and try/catch used throughout the toolbox
% (loadPriceData, computeReturns, backtestSMACrossover all validate
% their inputs this way). This lesson makes the pattern explicit.
%
% Note on structure: as in lesson 3, all local functions used below
% (safeDivide, checkPositive, demoCleanup) are defined together at the
% BOTTOM of this file — MATLAB requires every local function in a
% script to come after all top-level script statements, not
% interleaved with them.

%% Throwing an error
try
    error('This stops execution immediately.');
catch ME
    fprintf('Caught: %s\n', ME.message);
end

%% Errors with an identifier (the toolbox convention)
% An identifier is 'component:mnemonic' — it lets CALLERS catch a
% SPECIFIC kind of error without string-matching your message text
% (message text is for humans and can change; identifiers are the
% stable, checkable contract). This is exactly what the tests/ folder's
% verifyError(..., 'movingAverage:badWindow') relies on.
try
    error('myLesson:badInput', 'x must be positive, got %d.', -5);
catch ME
    fprintf('id=%s  message=%s\n', ME.identifier, ME.message);
end

%% try/catch with the exception object, dispatched by identifier
try
    safeDivide(10, 0);
catch ME
    switch ME.identifier
        case 'myLesson:divideByZero'
            fprintf('Handled the expected case: %s\n', ME.message);
        otherwise
            rethrow(ME);   % don't silently swallow errors you didn't expect
    end
end

%% MException — building an error object explicitly
% Useful when you want to construct the error before deciding whether
% to throw it (e.g. accumulating multiple problems), or attach extra
% info via addCause.
try
    baseException = MException('myLesson:multipleProblems', ...
        'Found %d problems with the input.', 3);
    throw(baseException);
catch ME
    disp(ME.identifier)
    disp(ME.message)
end

%% assert — a shorthand for "error if this condition is false"
try
    checkPositive(-1);
catch ME
    fprintf('assert caught it: %s\n', ME.message);
end

%% The stack trace lives on the exception object
try
    safeDivide(1, 0);
catch ME
    fprintf('Error occurred in: %s (line %d)\n', ...
        ME.stack(1).name, ME.stack(1).line);
end

%% Cleanup that must run even if an error occurs: onCleanup
try
    demoCleanup();
catch ME
    fprintf('Caught after cleanup ran: %s\n', ME.message);
end

%% Where this shows up in the toolbox
% loadPriceData.m validates its input path and required column and
% raises 'loadPriceData:notFound' / 'loadPriceData:missingDate' with
% specific identifiers — open it again with this lesson in mind. Every
% toolbox function follows the same rule: validate early, fail with a
% specific identifier and a message that says exactly what was wrong
% and what was expected.

%% --- local functions below this point ---

function result = safeDivide(a, b)
    if b == 0
        error('myLesson:divideByZero', 'Cannot divide %g by zero.', a);
    end
    result = a / b;
end

function checkPositive(x)
    assert(x > 0, 'myLesson:notPositive', 'Expected positive, got %g.', x);
end

function demoCleanup()
    fprintf('Opening resource...\n');
    c = onCleanup(@() fprintf('Resource closed (ran even on error).\n')); %#ok<NASGU>
    error('myLesson:forcedFailure', 'Something went wrong mid-function.');
end
