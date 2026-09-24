# MarketLens — Learn MATLAB by Building a Time-Series/Portfolio Toolbox

A self-contained MATLAB project for going from "comfortable in other
languages" to comfortable in MATLAB, by building something real: a small
toolbox that loads price data, computes returns/volatility/drawdown,
backtests three different trading rules, compares them, and displays
results in a GUI — plus a real test suite and lessons on testing, error
handling, struct/cell internals, and performance.

You don't need any paid toolboxes — everything here uses core MATLAB.

## How to work through it

1. **`lessons/`** — eleven short scripts, each focused on one MATLAB
   idiom you don't already have muscle memory for. Open each one in
   MATLAB and run it **section by section** (MATLAB scripts use `%%` to
   mark "cells" — press Ctrl+Enter / Cmd+Enter on a section to run just
   that block and inspect variables in the Workspace pane). Work through
   them in order, 01 through 11. Each one ends with a **"Try it
   yourself"** section — a few practice problems, no solutions given.
   Reading the lesson shows you the idiom; doing the exercise is what
   actually makes it stick. Don't skip these:

   | # | Topic |
   |---|-------|
   | 01 | Basics & variables (types, workspace, structs) |
   | 02 | Vectors & matrices (1-indexing, `.*` vs `*`, logical indexing) |
   | 03 | Control flow & functions (local functions in scripts) |
   | 04 | Vectorization (timed loop vs. vectorized comparison) |
   | 05 | Plotting |
   | 06 | Reading data (`readtable`, `table`) & `.mat` files |
   | 07 | Object-oriented MATLAB (`classdef`, handle vs. value classes) |
   | 08 | Unit testing with `matlab.unittest` |
   | 09 | Error handling (`try`/`catch`, identifiers, `MException`, `onCleanup`) |
   | 10 | Structs & cell arrays, deeper (struct arrays, dynamic fields, nesting) |
   | 11 | Performance & profiling (`timeit`, the Profiler, preallocation, `matfile`) |

2. **`toolbox/`** — the actual toolbox functions, each in its own `.m`
   file (MATLAB's convention — for a function to be callable, its
   filename must match the function name):

   - `loadPriceData.m` — read the CSV into a table
   - `computeReturns.m` — simple/log returns
   - `movingAverage.m`, `rollingVolatility.m` — rolling-window stats
   - `sharpeRatio.m`, `maxDrawdown.m` — risk/return metrics
   - `computeRSI.m`, `computeBollingerBands.m` — indicators
   - `backtestSMACrossover.m`, `backtestRSI.m`, `backtestBollinger.m` —
     three strategies that each work out their own `position` vector,
     then hand it to...
   - `buildBacktestResult.m` — the shared bookkeeping (returns, equity
     curves, Sharpe, drawdown) all three strategies used to duplicate,
     factored out into one place
   - `compareStrategies.m` — plot several backtest results together +
     summary table
   - `PortfolioAnalyzer.m` — a class wrapping all of the above into an
     object-oriented interface (the payoff for lesson 7); has one method
     per strategy plus `compareAllStrategies(ticker)`

3. **`tests/`** — a real `matlab.unittest` suite covering every function
   above except `PortfolioAnalyzer`/`compareStrategies` (those need
   `table`, which — like the tests themselves — needs real MATLAB to
   run). Run the whole suite from the project root:
   ```matlab
   results = runtests('tests');
   table(results)
   ```
   One test (`TestBacktestSMACrossover.signalIsLaggedByExactlyOneDay`)
   is a regression test for a real bug caught while building this: an
   early version tried to write `NaN` into a `logical` array, which
   MATLAB rejects. See lesson 9 for why the error identifier pattern
   used everywhere in `toolbox/` makes bugs like that easy to pin down.

4. **`data/sample_prices.csv`** — synthetic daily closing prices for 4
   tickers (AAPL, MSFT, TSLA, SPY-style index), generated with a
   reproducible random walk so results are deterministic. Swap in real
   data later — `loadPriceData.m` just needs a `Date` column plus one
   column per ticker.

5. **`main_demo.m`** — run this after the lessons. It loads the sample
   data, runs the whole toolbox end to end, and produces the plots
   (price chart, rolling volatility, SMA backtest, and a 3-way strategy
   comparison). This is the "does it all actually work" checkpoint.

6. **`app/MarketLensApp.m`** — an interactive GUI built by hand with
   `uifigure` and friends, *not* the drag-and-drop App Designer (reading
   it shows you what App Designer generates under the hood). Controls:
   - Ticker / MA window / show-MA — single-ticker view
   - **Compare all tickers** — switches to a normalized multi-ticker
     overlay (greys out the single-ticker controls while active)
   - **From / To** date pickers — filter either view to a date range
   - **Export PNG** — saves the current chart via a save dialog

   Run with:
   ```matlab
   app = MarketLensApp;
   ```
   This needs real MATLAB (uifigure apps aren't supported in Octave).

## Setup

Open MATLAB, `cd` into this folder, then run:
```matlab
addpath(genpath(pwd))
```
so the `toolbox/` functions are visible everywhere. Then:
```matlab
main_demo
```
Or better yet, convert the folder into a formal MATLAB **Project**
(*Home → New → Project → From Folder*) — it sets the path up for you
automatically every time you open it.

A `.gitignore` is included if you put this under version control (it
ignores `*.asv` autosave files, generated `.mat`/`.png` output, and
MATLAB Project sandbox state — keep `resources/project/` itself, just
not `resources/project/Sandbox/`).

## Why this project

Everything here is generic time-series/matrix work — the same functions
apply to sensor readings, experiment measurements, or any tabular numeric
data. Finance data just happens to be an easy, realistic dataset to
generate and reason about, and it lines up with the trading-system work
you've already done — but nothing in the toolbox is finance-specific
under the hood (it's rolling windows, cumulative products, and vectorized
math throughout).

## Suggested next steps once you're through this

- Point `loadPriceData.m` at a real CSV (e.g. exported from Yahoo Finance)
  instead of the synthetic data.
- Add a fourth strategy (e.g. momentum, or MACD) alongside the other
  three, with its own `tests/Test*.m` file written *before* the
  implementation (try writing the test first for once — it's a
  different way of thinking about the function's contract).
- Add tests for `PortfolioAnalyzer` and `compareStrategies` — you'll
  need to build a small in-memory `table` as test fixture data instead
  of loading the CSV, which is its own useful exercise.
- Wire `app/MarketLensApp.m`'s "Compare all tickers" view up to
  `compareAllStrategies` — let the user pick a strategy from a dropdown
  and see it backtested live on whichever ticker is selected.
