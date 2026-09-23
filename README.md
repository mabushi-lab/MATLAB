# MarketLens — Learn MATLAB by Building a Time-Series/Portfolio Toolbox

A self-contained MATLAB project for going from "comfortable in other
languages" to comfortable in MATLAB, by building something real: a small
toolbox that loads price data, computes returns/volatility/drawdown,
backtests a simple trading rule, and displays results in a GUI.

You don't need any paid toolboxes — everything here uses core MATLAB.

## How to work through it

1. **`lessons/`** — seven short scripts, each focused on one MATLAB idiom
   you don't already have muscle memory for (1-indexed vectors, `.m` files
   as the unit of code, vectorization culture, `classdef`, etc). Open each
   one in MATLAB and run it **section by section** (MATLAB scripts use
   `%%` to mark "cells" — press Ctrl+Enter / Cmd+Enter on a section to run
   just that block and inspect variables in the Workspace pane).
   Work through them in order, 01 → 07.

2. **`toolbox/`** — the actual toolbox functions, each in its own `.m`
   file (MATLAB's convention — for a function to be callable, its
   filename must match the function name). Read each one; they're short.
   `PortfolioAnalyzer.m` is a class that wraps the plain functions into an
   object-oriented interface — the payoff for lesson 7.

3. **`data/sample_prices.csv`** — synthetic daily closing prices for 4
   tickers (AAPL, MSFT, TSLA, SPY-style index), generated with a
   reproducible random walk so results are deterministic. Swap in real
   data later — `loadPriceData.m` just needs a `Date` column plus one
   column per ticker.

4. **`main_demo.m`** — run this after the lessons. It loads the sample
   data, runs the whole toolbox end to end, and produces the plots
   (price chart, rolling volatility, SMA-crossover backtest equity
   curve). This is the "does it all actually work" checkpoint.

5. **`app/MarketLensApp.m`** — a small interactive GUI (ticker dropdown,
   date range, live-updating chart) built by hand with `uifigure` and
   friends, *not* the drag-and-drop App Designer. Reading it shows you
   what App Designer generates under the hood. Run with:
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
- Add a new strategy function (e.g. RSI-based) alongside
  `backtestSMACrossover.m` and compare equity curves on the same plot.
- Add a unit test file using MATLAB's `matlab.unittest` framework — a
  natural 8th lesson once the basics feel comfortable.
