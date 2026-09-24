%% Lesson 2 — Vectors & matrices (the whole point of MATLAB)
% MATLAB = MATrix LABoratory. Everything is fundamentally a matrix — a
% scalar is a 1x1 matrix. Get comfortable here and the rest is easy.

%% Creating vectors
row = [1 2 3 4 5]              % row vector — commas or spaces separate
col = [1; 2; 3; 4; 5]          % column vector — semicolons separate rows
r2 = 1:5                       % colon operator: start:end (step 1)
r3 = 1:2:10                    % start:step:end -> 1 3 5 7 9
r4 = linspace(0, 1, 5)         % 5 evenly spaced points from 0 to 1

%% *** Indexing starts at 1, not 0 ***
% This trips up everyone coming from Python/C/JS. row(1) is the FIRST
% element. row(0) is an error.
row(1)          % 1st element
row(end)        % last element ('end' is a keyword meaning "last index")
row(2:4)        % elements 2 through 4 -> [2 3 4]
row([1 3 5])    % arbitrary index list -> [1 3 5]

%% Matrices
M = [1 2 3; 4 5 6; 7 8 9]      % 3x3, rows separated by ;
size(M)                        % [3 3]
M(2, 3)                        % row 2, col 3 -> 6
M(2, :)                        % whole 2nd row -> [4 5 6]
M(:, 1)                        % whole 1st column -> [1; 4; 7]
M(:)                           % flattened column vector (column-major order)

%% Building matrices
zeros(2, 3)
ones(3, 1)
eye(3)                          % identity matrix
M'                               % transpose

%% *** Elementwise vs matrix operators — the #1 source of bugs ***
A = [1 2; 3 4];
B = [5 6; 7 8];
A * B          % MATRIX multiplication (linear algebra)
A .* B         % ELEMENTWISE multiplication (like numpy's default *)
A ^ 2          % matrix power (A*A)
A .^ 2         % elementwise square
A / 2          % elementwise here because 2 is scalar
[1 4 9] .^ 0.5 % elementwise sqrt -> [1 2 3]

% Rule of thumb: if you mean "do this operation to every element
% independently," you almost always want the dot version: .* ./ .^

%% Concatenation
v1 = [1 2 3];
v2 = [4 5 6];
[v1 v2]         % horizontal concat -> 1x6
[v1; v2]        % vertical concat -> 2x3
[M, M]          % concatenate matrices horizontally (dims must match)

%% Logical indexing — extremely common in real MATLAB code
prices = [101 98 105 99 110 95];
prices(prices > 100)            % elements greater than 100
idx = prices > 100;              % idx is a logical array, same size
class(idx)
sum(idx)                         % how many satisfy the condition

%% Useful shape/size functions
numel(M)     % total element count
length(M)    % size of the LARGEST dimension (careful with matrices)
ndims(M)     % number of dimensions
reshape(1:6, 2, 3)   % reshape 6 elements into a 2x3 matrix

%% Try it yourself
% 1. Build a 4x4 matrix of the numbers 1-16 with reshape(1:16, 4, 4).
%    Extract its 2nd column and its last row.
% 2. Given v = [3 -1 4 -1 5 -9 2 6], use logical indexing to extract
%    only the negative numbers, then count how many there are.
% 3. Compute the ELEMENTWISE square of a vector AND the MATRIX square
%    of a 2x2 matrix (using ^ vs .^). Add a comment explaining, in your
%    own words, why the two results differ.
