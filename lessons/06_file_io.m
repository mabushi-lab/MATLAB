%% Lesson 6 — Reading data & saving your workspace
% Two separate things MATLAB calls "file I/O": tabular data (CSV etc via
% tables) and MATLAB's own binary format (.mat) for dumping variables.

%% readtable — the workhorse for CSV/Excel-like data
% This project's sample data lives at ../data/sample_prices.csv
thisFile = mfilename('fullpath');
projectRoot = fileparts(fileparts(thisFile));   % up two levels from lessons/
dataPath = fullfile(projectRoot, 'data', 'sample_prices.csv');

T = readtable(dataPath);
disp(head(T, 5))            % first 5 rows — 'head' works like pandas
class(T)                    % 'table'
T.Properties.VariableNames  % column names
size(T)

%% Working with a table
T.AAPL(1:5)                 % a column, by name, like a struct field
T{1:5, 'AAPL'}               % same thing, curly-brace / string indexing
T(T.AAPL > 150, :)           % filter rows — logical indexing works on tables too
summary(T)                   % quick stats per column

%% Converting between table and plain matrix
tickers = {'AAPL','MSFT','TSLA','SPY'};
priceMatrix = T{:, tickers};     % table -> plain double matrix
class(priceMatrix)
size(priceMatrix)

%% writetable — the reverse direction
% writetable(T, 'copy.csv');   % uncomment to actually write

%% struct — the general-purpose "bag of fields" container
result = struct('ticker', 'AAPL', 'meanReturn', 0.0012, 'volatility', 0.021);
disp(result)
fieldnames(result)
isfield(result, 'ticker')

%% Saving/loading your whole workspace (or specific variables) as .mat
% save('workspace_snapshot.mat');            % everything
% save('just_T.mat', 'T');                   % just one variable
% load('just_T.mat');                        % restores it into the workspace
% .mat is MATLAB's native binary format — fast, but not human-readable
% or portable outside MATLAB/Octave/scipy.io.loadmat.
