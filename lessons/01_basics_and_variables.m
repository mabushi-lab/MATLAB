%% Lesson 1 — Basics & variables
% Run this section-by-section (Ctrl+Enter on each %% block) and watch the
% Workspace pane fill up. MATLAB is a scripting language like Python, but
% with a few load-bearing differences this lesson calls out.

%% No semicolon = print the result
x = 5          % prints "x = 5" to the Command Window
y = 5;         % semicolon suppresses output — use this almost always,
               % except when you deliberately want to inspect a value

%% clc / clear
clc            % clears the Command Window (cosmetic only)
clear          % clears all variables from the workspace — good habit at
               % the top of a script so stale variables can't fool you

%% Everything is a double by default
a = 5;
class(a)                 % 'double' — even a lone integer-looking literal
whos a                   % size, bytes, class — 'whos' is your best friend

%% Other basic types
s = 'single quotes = char array';     class(s)
str = "double quotes = string";       class(str)   % newer type, richer API
b = true;                              class(b)     % logical
c = {1, 'two', [3 4 5]};               class(c)     % cell array — mixed types

% char vs string matters: 'abc' is a 1x3 array of characters,
% "abc" is a 1x1 string object. String is usually nicer to work with;
% char shows up constantly in older code and file I/O, so know both.

%% Structs — MATLAB's dict/record type
person.name = 'Florian';
person.age = 21;
disp(person)
fieldnames(person)

%% Basic operators
7 / 2          % true division -> 3.5000 (no int-division surprises)
mod(7, 2)      % remainder -> 1
2 ^ 10         % power -> 1024
5 == 5.0       % -> 1 (logical true is displayed as 1)

%% Comments
% A single-line comment starts with %
%{
A block comment is wrapped in %{ ... %}
on their own lines.
%}

%% Key mental model
% MATLAB variables live in a "workspace" tied to whatever scope is
% running (base workspace for scripts typed at the prompt, a private
% workspace per function call). There's no implicit global state between
% functions the way a Python module's top level can leak variables —
% each function only sees what you pass in.
