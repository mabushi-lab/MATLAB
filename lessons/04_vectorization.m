%% Lesson 4 — Vectorization
% Loops in interpreted MATLAB (pre-JIT-friendly code) are usually much
% slower than the equivalent vectorized (whole-array) operation, and
% idiomatic MATLAB code leans hard on this. This lesson makes the case
% with a real timing comparison, then a few patterns you'll use constantly
% in the toolbox.

%% Timing: loop vs vectorized
n = 1e6;
x = rand(1, n);

tic
y_loop = zeros(1, n);
for i = 1:n
    y_loop(i) = x(i)^2 + 3*x(i) + 1;
end
t_loop = toc;

tic
y_vec = x.^2 + 3*x + 1;
t_vec = toc;

fprintf('loop:       %.4f s\n', t_loop);
fprintf('vectorized: %.4f s\n', t_vec);
fprintf('speedup:    %.1fx\n', t_loop / t_vec);
% Note: don't use isequal() for float comparisons like this — the
% vectorized power operator can take a different internal code path than
% scalar-by-scalar ^, so results can differ by a tiny rounding error
% (a few ULPs) even though the formula is identical. Always compare
% floats with a tolerance:
assert(max(abs(y_loop - y_vec)) < 1e-9, 'results should match within tolerance');

%% Preallocation still matters if you DO need a loop
% Growing an array inside a loop (y(i) = ... without predefining y)
% forces MATLAB to reallocate and copy on every iteration. Always
% preallocate with zeros/nan/cell when the final size is known:
%   y = zeros(1, n);   <- do this BEFORE the loop, like above

%% arrayfun / cellfun — functional-style alternatives to explicit loops
squares = arrayfun(@(v) v^2, 1:5)          % applies a function elementwise
lens = cellfun(@length, {'a','bb','ccc'})  % applies a function to each cell

% 'UniformOutput', false lets the function return something non-scalar
upper_names = cellfun(@upper, {'ana','bo'}, 'UniformOutput', false)

%% Logical indexing instead of if-inside-a-loop
data = [-3 5 -1 8 0 -7 2];
% Slow style: loop + if, building up a result
% Fast/idiomatic style:
positives = data(data > 0)              % filter
clipped = data;
clipped(clipped < 0) = 0;               % conditional assignment, in place

%% Broadcasting (implicit expansion)
% Since R2016b, operations between a matrix and a vector automatically
% "broadcast" the vector across the matching dimension — no need for
% repmat in most cases.
M = [1 2 3; 4 5 6; 7 8 9];
col_means = mean(M, 1);          % 1x3, mean of each column
M_centered = M - col_means;      % subtracts col_means from every row
disp(M_centered)

%% Rule of thumb for this whole toolbox
% Anywhere you're tempted to write "for each day, compute...", first ask
% whether movmean/movstd/diff/cumprod/cumsum/filter already expresses it
% over the whole vector at once. The toolbox functions in ../toolbox/
% are deliberately written this way.

%% Try it yourself
% 1. Given x = rand(1, 100000), write BOTH a loop and a vectorized
%    version that clips every negative-after-subtracting-0.5 value to
%    zero (i.e. y = max(x - 0.5, 0)). Time both with tic/toc and report
%    the speedup.
% 2. Use arrayfun to compute the cube of every integer from 1 to 10
%    without writing a for loop.
% 3. (Stretch) Given two vectors of x and y coordinates for a handful of
%    points, compute the full pairwise distance matrix between them
%    using broadcasting (no loops) — look up how subtracting a column
%    vector from a row vector broadcasts into a matrix.
