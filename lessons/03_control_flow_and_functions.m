%% Lesson 3 — Control flow & functions
% Everything here should feel familiar syntactically once you know the
% keywords: blocks end with `end`, not braces or indentation.

%% if / elseif / else
score = 72;
if score >= 90
    grade = 'A';
elseif score >= 70
    grade = 'B';
else
    grade = 'C';
end
disp(grade)

%% for loops — iterate over columns of whatever you give it
for i = 1:5
    fprintf('i = %d\n', i);     % fprintf works like C's printf
end

names = {'alpha', 'beta', 'gamma'};   % looping over a cell array
for i = 1:numel(names)
    fprintf('%s\n', names{i});        % {} extracts the CONTENT of a cell
end

%% while loops
n = 1;
total = 0;
while total < 20
    total = total + n;
    n = n + 1;
end
fprintf('total=%d after n reached %d\n', total, n);

%% switch — cleaner than a long elseif chain
day = 'Tue';
switch day
    case {'Sat', 'Sun'}
        disp('weekend')
    case {'Mon','Tue','Wed','Thu','Fri'}
        disp('weekday')
    otherwise
        disp('unknown')
end

%% Functions defined locally in a script
% Since R2016b, a .m script can define functions at the BOTTOM of the
% file, after all the script code. They're only visible within this file.
result = celsiusToFahrenheit(20);
fprintf('20C = %.1fF\n', result);

[avg, sd] = meanAndStd([2 4 4 4 5 5 7 9]);
fprintf('mean=%.3f std=%.3f\n', avg, sd);

greet();            % using a default argument via nargin
greet('Florian');   % overriding it

%% Try it yourself
% 1. Write a local function isPrime(n) (add it to the functions at the
%    bottom of this file) that returns true/false. Test it in a for
%    loop over 1:20 and print which numbers are prime.
% 2. Take an if/elseif/else chain that classifies a numeric score into
%    a letter grade and rewrite it as a switch statement instead.
% 3. Write a function with TWO optional inputs (using nargin, like
%    greet() above) — e.g. a function that formats a name with an
%    optional title and an optional suffix.

%% --- local functions below this point ---
function f = celsiusToFahrenheit(c)
    % A plain single-output function.
    f = c * 9/5 + 32;
end

function [m, s] = meanAndStd(v)
    % Multiple return values — call with [a, b] = f(...) to get both,
    % or just a = f(...) to get only the first.
    m = mean(v);
    s = std(v);
end

function greet(name)
    % nargin = "number of input arguments actually passed" — this is
    % how MATLAB does optional/default arguments without a special
    % syntax (newer MATLAB also supports `arguments` blocks, see below).
    if nargin < 1
        name = 'friend';
    end
    fprintf('Hello, %s!\n', name);
end
