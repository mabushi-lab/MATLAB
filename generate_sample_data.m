%% generate_sample_data.m
% Creates data/sample_prices.csv: synthetic daily closing prices for 4
% tickers using geometric Brownian motion, so results are reproducible
% and there's no dependency on downloading real market data. The CSV in
% data/ is already committed (500 rows, seed 42) — you don't need to run
% this to use the project. Re-run it if you want to regenerate with
% different parameters (more days, different tickers, different vol).

rng(42);   % fixed seed -> identical CSV every time this is run

nDays = 500;                          % ~2 trading years
startDate = datetime(2024, 1, 2);
dates = businessDaysRange(startDate, nDays);   % local helper, see below

tickers   = {'AAPL',  'MSFT',  'TSLA',  'SPY'};
startPx   = [150,     380,     220,     420];
annualDrift = [0.12,  0.10,    0.05,    0.08];   % expected annual return
annualVol   = [0.28,  0.24,    0.55,    0.16];   % annual volatility

periodsPerYear = 252;
dt = 1 / periodsPerYear;

nTickers = numel(tickers);
prices = zeros(nDays, nTickers);
prices(1, :) = startPx;

for j = 1:nTickers
    mu = annualDrift(j);
    sigma = annualVol(j);
    z = randn(nDays-1, 1);
    % Geometric Brownian motion, exact discretization (no Euler bias):
    logReturns = (mu - 0.5*sigma^2)*dt + sigma*sqrt(dt)*z;
    prices(2:end, j) = startPx(j) * cumprod(exp(logReturns));
end

T = array2table(round(prices, 2), 'VariableNames', tickers);
T = addvars(T, dates, 'Before', 1, 'NewVariableNames', 'Date');

outPath = fullfile('data', 'sample_prices.csv');
writetable(T, outPath);
fprintf('Wrote %d rows to %s\n', height(T), outPath);

%% --- local helper ---
function d = businessDaysRange(startDate, n)
    % Returns n consecutive weekday (Mon-Fri) dates starting at startDate.
    d = NaT(n, 1);
    cur = startDate;
    count = 0;
    while count < n
        if ~isweekend(cur)
            count = count + 1;
            d(count) = cur;
        end
        cur = cur + days(1);
    end
end
