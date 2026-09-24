%% Lesson 11 — Performance & profiling
% Lesson 4 covered vectorization with a manual tic/toc timing. This
% lesson covers the tools you reach for when tic/toc isn't precise
% enough, or when you don't yet know WHICH line is slow.

%% timeit — more reliable than a single tic/toc
% A single tic/toc measurement is noisy (OS scheduling, JIT warm-up,
% caching). timeit() runs your code several times and returns a
% trustworthy median-ish estimate. It needs a function handle with NO
% arguments, so wrap whatever you're timing in an anonymous function:
%
%   n = 1e6;
%   x = rand(1, n);
%   t = timeit(@() x.^2 + 3*x + 1);
%   fprintf('%.6f s per call\n', t);
%
% (timeit is a real MATLAB function; it's not available in GNU Octave,
% so this block is written as a comment rather than run here — copy it
% into MATLAB to try it.)

%% The Profiler — finding out WHERE time goes in a whole function
% For anything bigger than one line, don't guess — profile it. This
% part DOES run the same way in MATLAB and Octave:
profile on
n = 2000;
M = zeros(n);
for i = 1:n
    for j = 1:n
        M(i,j) = sin(i) * cos(j);   % deliberately slow double loop
    end
end
profile off

% In real MATLAB: profile viewer   opens an interactive report showing
% time spent per line/function, call counts, etc. From the command
% line (works here too):
stats = profile('info');
fprintf('Profiled %d function calls.\n', numel(stats.FunctionTable));

% The point of the exercise above: that double loop is exactly the kind
% of thing lesson 4 says to avoid. The vectorized replacement:
tic
[J, I] = meshgrid(1:n, 1:n);
M2 = sin(I) .* cos(J);
tVec = toc;
fprintf('Vectorized version: %.4f s\n', tVec);
assert(max(abs(M(:) - M2(:))) < 1e-9);

%% Preallocation, revisited with real numbers
% Lesson 4 mentioned this; here's the actual cost of NOT doing it.
n = 50000;

tic
y = [];
for i = 1:n
    y(end+1) = i^2;    %#ok<AGROW> -- growing the array every iteration
end
tGrow = toc;

tic
y2 = zeros(1, n);
for i = 1:n
    y2(i) = i^2;
end
tPrealloc = toc;

fprintf('Growing array:    %.4f s\n', tGrow);
fprintf('Preallocated:     %.4f s\n', tPrealloc);
fprintf('Speedup:          %.1fx\n', tGrow / tPrealloc);
% MATLAB's Editor even flags "y(end+1)=..." in a loop with a warning
% (the #ok<AGROW> above suppresses it, since here it's deliberate).

%% matfile — reading PART of a big .mat file without loading all of it
% For a .mat file too big to comfortably fit in memory, `load` reads
% everything. matfile() gives you an object you can index into like a
% struct, loading only the slice you ask for:
%
%   save('big_data.mat', 'M');              % M is the 2000x2000 matrix above
%   mf = matfile('big_data.mat');
%   firstRow = mf.M(1, :);                  % loads ONLY that row
%   corner = mf.M(1:10, 1:10);              % loads only a 10x10 corner
%
% This matters the moment your data stops fitting comfortably in RAM —
% worth knowing exists even if this project's data never needs it.

%% Rule of thumb
% Don't optimize blind. Profile first, find the actual bottleneck (it's
% often not where you'd guess), then reach for vectorization,
% preallocation, or matfile as appropriate to what the profiler shows.

%% Try it yourself
% 1. Wrap `profile on ... profile off` around a call to main_demo, then
%    inspect `profile('info')` (or `profile viewer` in real MATLAB) and
%    note, as a comment, which function used the most time.
% 2. Take a loop from your OWN code (or from an earlier lesson) and
%    vectorize it. In real MATLAB, confirm the speedup with timeit
%    rather than a single tic/toc.
% 3. Save a large matrix to a .mat file, then use matfile() to load
%    only a 10x10 corner of it without loading the whole thing.
