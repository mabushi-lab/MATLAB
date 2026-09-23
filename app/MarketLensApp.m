classdef MarketLensApp < handle
    %MARKETLENSAPP Small interactive GUI over the toolbox, hand-built.
    %   app = MarketLensApp launches the window.
    %
    %   This is written the way App Designer's generated code looks
    %   under the hood: a handle class whose properties hold component
    %   handles (uifigure, uidropdown, uiaxes, ...), built in the
    %   constructor, wired up with callbacks. App Designer just does
    %   this for you via drag-and-drop and saves it as a binary .mlapp
    %   file instead of a plain .m file — same underlying model.
    %
    %   Requires real MATLAB (uifigure apps are not supported in GNU
    %   Octave as of this writing).

    properties (Access = private)
        UIFigure
        TickerDropDown
        MAWindowSpinner
        ShowMACheckBox
        UIAxes
        StatusLabel

        Data              % table from loadPriceData
        Tickers           % cellstr of ticker names
    end

    methods
        function app = MarketLensApp()
            thisDir = fileparts(mfilename('fullpath'));
            projectRoot = fileparts(thisDir);
            addpath(fullfile(projectRoot, 'toolbox'));

            app.Data = loadPriceData(fullfile(projectRoot, 'data', 'sample_prices.csv'));
            app.Tickers = setdiff(app.Data.Properties.VariableNames, {'Date'}, 'stable');

            app.buildUI();
            app.updatePlot();
        end
    end

    methods (Access = private)
        function buildUI(app)
            app.UIFigure = uifigure('Name', 'MarketLens', 'Position', [100 100 700 480]);

            uilabel(app.UIFigure, 'Text', 'Ticker:', 'Position', [20 440 50 22]);
            app.TickerDropDown = uidropdown(app.UIFigure, ...
                'Items', app.Tickers, ...
                'Position', [70 440 100 22], ...
                'ValueChangedFcn', @(src, evt) app.updatePlot());

            uilabel(app.UIFigure, 'Text', 'MA window (days):', 'Position', [190 440 110 22]);
            app.MAWindowSpinner = uispinner(app.UIFigure, ...
                'Limits', [2 100], 'Value', 20, 'Step', 1, ...
                'Position', [300 440 80 22], ...
                'ValueChangedFcn', @(src, evt) app.updatePlot());

            app.ShowMACheckBox = uicheckbox(app.UIFigure, ...
                'Text', 'Show moving average', 'Value', true, ...
                'Position', [400 440 160 22], ...
                'ValueChangedFcn', @(src, evt) app.updatePlot());

            app.UIAxes = uiaxes(app.UIFigure, 'Position', [20 60 660 360]);
            title(app.UIAxes, 'Price');
            xlabel(app.UIAxes, 'Date');
            ylabel(app.UIAxes, 'Price');

            app.StatusLabel = uilabel(app.UIFigure, ...
                'Text', '', 'Position', [20 20 660 22]);
        end

        function updatePlot(app)
            ticker = app.TickerDropDown.Value;
            windowSize = round(app.MAWindowSpinner.Value);

            dates = app.Data.Date;
            prices = app.Data.(ticker);

            cla(app.UIAxes);
            plot(app.UIAxes, dates, prices, 'LineWidth', 1.3, 'DisplayName', ticker);
            hold(app.UIAxes, 'on');

            if app.ShowMACheckBox.Value
                ma = movingAverage(prices, windowSize);
                plot(app.UIAxes, dates, ma, 'LineWidth', 1.3, ...
                    'DisplayName', sprintf('%d-day MA', windowSize));
            end

            hold(app.UIAxes, 'off');
            legend(app.UIAxes, 'show', 'Location', 'best');
            title(app.UIAxes, sprintf('%s price', ticker));

            r = computeReturns(prices);
            sr = sharpeRatio(r);
            mdd = maxDrawdown(prices);
            app.StatusLabel.Text = sprintf( ...
                'Annualized Sharpe: %.2f   |   Max drawdown: %.1f%%', sr, 100*mdd);
        end
    end
end
