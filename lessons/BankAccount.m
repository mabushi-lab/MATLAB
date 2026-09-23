classdef BankAccount < handle
    % BANKACCOUNT  Minimal classdef example for Lesson 7.
    %
    % A classdef file MUST live in its own .m file, named exactly after
    % the class ("BankAccount.m" defines "classdef BankAccount"). That's
    % a hard MATLAB rule, unlike functions-in-a-script from lesson 3.
    %
    % Inheriting from `handle` (as opposed to `matlab.mixin.Copyable` or
    % nothing) makes this a REFERENCE type: copies of the variable point
    % to the same underlying object, like a Python class instance, and
    % methods can mutate it in place. Leave off `< handle` and MATLAB
    % classes are VALUE types by default (like a struct — copies are
    % independent, methods must return a new copy to "change" anything).

    properties
        Owner
        Balance
    end

    methods
        function obj = BankAccount(owner, openingBalance)
            % Constructor — same name as the class, runs on `BankAccount(...)`
            if nargin < 2
                openingBalance = 0;
            end
            obj.Owner = owner;
            obj.Balance = openingBalance;
        end

        function deposit(obj, amount)
            if amount <= 0
                error('BankAccount:invalidAmount', 'Deposit must be positive.');
            end
            obj.Balance = obj.Balance + amount;
        end

        function withdraw(obj, amount)
            if amount > obj.Balance
                error('BankAccount:insufficientFunds', 'Not enough balance.');
            end
            obj.Balance = obj.Balance - amount;
        end

        function s = summary(obj)
            s = sprintf('%s: $%.2f', obj.Owner, obj.Balance);
        end
    end
end
