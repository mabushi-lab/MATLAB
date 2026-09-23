%% Lesson 7 — Object-oriented MATLAB (classdef)
% This script uses BankAccount.m (same folder) — open that file first,
% it's short and heavily commented.

%% Creating and using an object
acc = BankAccount('Florian', 100);
disp(acc.summary())

acc.deposit(50);
disp(acc.summary())

acc.withdraw(30);
disp(acc.summary())

try
    acc.withdraw(1000);     % triggers the error() call inside the method
catch ME
    fprintf('Caught error: %s\n', ME.message);
end

%% handle vs value semantics — the thing that bites people
acc2 = acc;                  % acc2 is the SAME object as acc (handle class)
acc2.deposit(1000);
fprintf('acc balance is also changed: %.2f\n', acc.Balance);   % yes, changed!

% If BankAccount did NOT inherit from `handle`, acc2 = acc would have
% made an independent copy, and acc.Balance would be untouched above.
% Pick `handle` when the object represents something with an identity
% that should be shared/mutated (a live connection, a stateful analyzer,
% a GUI app) — pick a plain value class for things that behave like data
% (a coordinate, an immutable config).

%% dot notation for both properties and methods
acc.Owner                    % property access
acc.summary()                % method call — note the ()
acc.summary                  % also works without () if no args, but () is clearer

%% Where this goes next
% ../toolbox/PortfolioAnalyzer.m applies exactly this pattern to wrap
% the plain analysis functions (computeReturns, sharpeRatio, ...) into
% one object you construct once and then call methods on — the same
% shape as BankAccount, just doing portfolio math instead of banking.
