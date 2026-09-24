%% Lesson 10 — Structs and cell arrays, deeper
% Lesson 1 introduced struct and cell as "MATLAB's dict/mixed-type
% container." This lesson covers the parts that trip people up: struct
% ARRAYS (not just one struct), dynamic field names, nested structures,
% and when to reach for a cell array instead.

%% A single struct vs an ARRAY of structs
% Lesson 1's `person.name = 'Florian'` made ONE struct. You can also
% have a struct ARRAY — many records, same fields, like a list of rows:
people(1).name = 'Florian';
people(1).age = 21;
people(2).name = 'Ada';
people(2).age = 30;

people                     % a 1x2 struct array
people(2).name             % 'Ada'
[people.age]                % pulls the 'age' field from EVERY element
                            % into a plain numeric array -> [21 30]
{people.name}               % same trick with {} -> cell array of names

%% Building a struct array with the struct() function directly
% struct() with array-valued fields "broadcasts" element-wise if the
% inputs are wrapped in a cell array — a common one-liner:
s = struct('name', {'Florian', 'Ada'}, 'age', {21, 30});
size(s)          % 1x2 — TWO structs, not one struct with cell fields
s(1).name

%% Dynamic field names — s.(name) instead of s.name
% Same idea as MarketLensApp.m's `app.Data.(ticker)` from the app —
% useful whenever the field name itself is a variable.
fieldToRead = 'age';
people(1).(fieldToRead)     % same as people(1).age

% Building a struct from variable field names in a loop:
stats = struct();
metricNames = {'mean', 'std', 'max'};
metricValues = {2.3, 0.5, 9.1};
for i = 1:numel(metricNames)
    stats.(metricNames{i}) = metricValues{i};
end
disp(stats)

%% Nested structs — struct fields containing structs
config.database.host = 'localhost';
config.database.port = 5432;
config.app.name = 'MarketLens';
config.app.version = '1.0';

config.database.host
fieldnames(config)
fieldnames(config.database)

%% Cell arrays: the general-purpose "anything, any shape" container
c = {1, 'two', [3 4 5], {6, 7}};    % numbers, text, arrays, even nested cells
c{1}          % content of cell 1 -> 1 (curly braces = unwrap)
c(1)          % a 1x1 CELL containing 1 (parens = still wrapped)
class(c{1})
class(c(1))

% This () vs {} distinction is the single biggest cell-array confusion
% point. Rule of thumb: {} when you want the VALUE inside, () when you
% want a (possibly smaller) cell array containing that value.

%% struct array vs cell array of structs — when to use which
% - struct ARRAY (people above): every element has the SAME fields.
%   Great for tabular/record-like data. [people.age] and {people.name}
%   work because the fields line up across all elements.
% - cell array of MIXED types/shapes: use when elements genuinely
%   differ (a list where element 3 is a matrix and element 4 is text),
%   or when you need to grow/shrink the container arbitrarily.
% - In practice, for TABULAR numeric+text data like the price data in
%   this project, a `table` (lesson 6) beats both — that's exactly why
%   loadPriceData.m returns a table, not an array of structs.

%% deal() — unpacking multiple outputs at once
[a, b, c2] = deal(1, 2, 3);
fprintf('a=%d b=%d c2=%d\n', a, b, c2);

[x, y] = deal(0);            % same value to multiple outputs
fprintf('x=%d y=%d\n', x, y);

%% Where this shows up in the toolbox
% PortfolioAnalyzer.m's summaryTable() and compareStrategies.m's
% cellfun(@(r) r.totalReturn, results(:)) both lean on exactly this:
% a CELL ARRAY of result STRUCTS, each with the same fields, converted
% to a table for display. Re-read compareStrategies.m now — the
% (r) r.totalReturn anonymous function pulls one field out of each
% struct in the cell array, all in one line.

%% Try it yourself
% 1. Build a struct array of 5 "trades" (ticker, quantity, price) and
%    compute the total dollar value of the portfolio using
%    [trades.quantity] and [trades.price] (no loop).
% 2. Convert that struct array to a table with struct2table(), then
%    back to a struct array with table2struct().
% 3. Build a config struct that's THREE levels deep (e.g.
%    config.app.ui.theme) and read the deepest field using a dynamic
%    field name stored in a variable.
