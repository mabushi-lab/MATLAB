function rsi = computeRSI(prices, windowSize)
%COMPUTERSI Relative Strength Index of a single price series.
%   RSI = COMPUTERSI(PRICES, WINDOWSIZE) returns an array the same size
%   as PRICES (NaN during warm-up), with values in [0, 100]. RSI near
%   100 = mostly up days recently ("overbought"); near 0 = mostly down
%   days ("oversold"). windowSize defaults to 14 (the traditional value).
%
%   This uses a SIMPLE rolling average of gains/losses (built on this
%   toolbox's own movingAverage), not Wilder's exponential smoothing
%   that most trading platforms use — the shape is the same, the exact
%   numbers will differ slightly from what you'd see on a chart in
%   TradingView/Bloomberg. Good enough to learn the pattern; a real
%   implementation is a one-line swap to an exponential moving average.

    if nargin < 2
        windowSize = 14;
    end
    if ~iscolumn(prices)
        prices = prices(:);
    end

    delta = [NaN; diff(prices)];         % align: delta(t) = prices(t)-prices(t-1)
    gain = max(delta, 0);
    loss = max(-delta, 0);

    avgGain = movingAverage(gain, windowSize);
    avgLoss = movingAverage(loss, windowSize);

    rs = avgGain ./ avgLoss;             % Inf where avgLoss == 0 (all up days) -> RSI 100, handled below
    rsi = 100 - 100 ./ (1 + rs);
    rsi(avgLoss == 0 & avgGain > 0) = 100;
    rsi(avgLoss == 0 & avgGain == 0) = 50;   % flat market, no gains or losses
end
