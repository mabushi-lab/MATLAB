function ma = movingAverage(x, windowSize)
%MOVINGAVERAGE Trailing simple moving average of each column of x.
%   MA = MOVINGAVERAGE(X, WINDOWSIZE) returns an array the same size as
%   X where MA(t) is the mean of X(t-windowSize+1 : t). Entries before
%   the window is fully populated (t < windowSize) are NaN, matching
%   MATLAB's own movmean 'SamplePoints' convention closely enough for
%   this project.
%
%   This is a thin, deliberately-readable wrapper around the built-in
%   MOVMEAN — see the local reference implementation below (commented
%   out) for what movmean is doing for you.

    if windowSize < 1 || windowSize ~= floor(windowSize)
        error('movingAverage:badWindow', 'windowSize must be a positive integer.');
    end

    ma = movmean(x, [windowSize-1, 0], 1, 'Endpoints', 'discard');
    % 'discard' returns fewer rows than x; pad the front with NaN so the
    % output lines up with the input timeline, which is what callers
    % (e.g. the backtest function) expect.
    padRows = size(x, 1) - size(ma, 1);
    ma = [nan(padRows, size(x, 2)); ma];

    %{
    Reference implementation without movmean, showing the vectorization
    pattern (a loop over the WINDOW, not over TIME, is fine — it's O(w)
    not O(n)):

        n = size(x, 1);
        ma = nan(size(x));
        for t = windowSize:n
            ma(t, :) = mean(x(t-windowSize+1:t, :), 1);
        end
    %}
end
