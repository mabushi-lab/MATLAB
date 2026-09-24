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
    %   Controls:
    %     Ticker / MA window / Show moving average — single-ticker view
    %     Compare all tickers  — switches to a normalized multi-ticker view
    %     Start / End date     — filters BOTH views to a date range
    %     Export PNG           — saves the current chart via uiputfile
    %
    %   Requires real MATLAB (uifigure apps are not supported in GNU
    %   Octave as of this writing).

    properties (Access = private)
        UIFigure
        TickerDropDown
        MAWindowSpinner
        ShowMACheckBox
        CompareCheckBox
        StartDatePicker
        EndDatePicker
        ExportButton
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
            app.UIFigure = uifigure('Name', 'MarketLens', 'Position', [100 100 760 540]);

            %% Row 1: single-ticker controls
            uilabel(app.UIFigure, 'Text', 'Ticker:', 'Position', [20 500 50 22]);
            app.TickerDropDown = uidropdown(app.UIFigure, ...
                'Items', app.Tickers, ...
                'Position', [70 500 90 22], ...
                'ValueChangedFcn', @(src, evt) app.updatePlot());

            uilabel(app.UIFigure, 'Text', 'MA window (days):', 'Position', [175 500 110 22]);
            app.MAWindowSpinner = uispinner(app.UIFigure, ...
                'Limits', [2 100], 'Value', 20, 'Step', 1, ...
                'Position', [285 500 70 22], ...
                'ValueChangedFcn', @(src, evt) app.updatePlot());

            app.ShowMACheckBox = uicheckbox(app.UIFigure, ...
                'Text', 'Show moving average', 'Value', true, ...
                'Position', [370 500 160 22], ...
                'ValueChangedFcn', @(src, evt) app.updatePlot());

            %% Row 2: compare mode, date range, export
            app.CompareCheckBox = uicheckbox(app.UIFigure, ...
                'Text', 'Compare all tickers', 'Value', false, ...
                'Position', [20 465 150 22], ...
                'ValueChangedFcn', @(src, evt) app.compareModeChanged());

            minDate = min(app.Data.Date);
            maxDate = max(app.Data.Date);

            uilabel(app.UIFigure, 'Text', 'From:', 'Position', [185 465 40 22]);
            app.StartDatePicker = uidatepicker(app.UIFigure, ...
                'Value', minDate, 'Limits', [minDate maxDate], ...
                'Position', [225 465 115 22], ...
                'ValueChangedFcn', @(src, evt) app.updatePlot());

            uilabel(app.UIFigure, 'Text', 'To:', 'Position', [350 465 25 22]);
            app.EndDatePicker = uidatepicker(app.UIFigure, ...
                'Value', maxDate, 'Limits', [minDate maxDate], ...
                'Position', [375 465 115 22], ...
                'ValueChangedFcn', @(src, evt) app.updatePlot());

            app.ExportButton = uibutton(app.UIFigure, 'push', ...
                'Text', 'Export PNG', ...
                'Position', [640 465 100 22], ...
                'ButtonPushedFcn', @(src, evt) app.exportChart());

            %% Axes
            app.UIAxes = uiaxes(app.UIFigure, 'Position', [20 70 720 380]);
            title(app.UIAxes, 'Price');
            xlabel(app.UIAxes, 'Date');
            ylabel(app.UIAxes, 'Price');

            %% Status line
            app.StatusLabel = uilabel(app.UIFigure, ...
                'Text', '', 'Position', [20 20 720 22]);
        end

        function compareModeChanged(app)
            % Single-ticker controls don't mean anything in compare
            % mode, so grey them out instead of leaving them silently
            % ignored — a UI that lies about what's active is worse
            % than one that's a little more cluttered.
            comparing = app.CompareCheckBox.Value;
            onOff = {'on', 'off'};
            app.TickerDropDown.Enable = onOff{comparing + 1};
            app.MAWindowSpinner.Enable = onOff{comparing + 1};
            app.ShowMACheckBox.Enable = onOff{comparing + 1};
            app.updatePlot();
        end

        function mask = dateRangeMask(app)
            startDate = app.StartDatePicker.Value;
            endDate = app.EndDatePicker.Value;
            if startDate > endDate
                % Swapped range — treat it as the user meant it the
                % other way round, rather than showing an empty chart.
                [startDate, endDate] = deal(endDate, startDate);
            end
            mask = app.Data.Date >= startDate & app.Data.Date <= endDate;
        end

        function updatePlot(app)
            mask = app.dateRangeMask();
            dates = app.Data.Date(mask);

            cla(app.UIAxes);

            if nnz(mask) < 2
                title(app.UIAxes, 'Not enough data in selected range');
                app.StatusLabel.Text = 'Pick a wider date range.';
                return
            end

            if app.CompareCheckBox.Value
                app.plotCompareMode(dates, mask);
            else
                app.plotSingleTickerMode(dates, mask);
            end
        end

        function plotSingleTickerMode(app, dates, mask)
            ticker = app.TickerDropDown.Value;
            windowSize = round(app.MAWindowSpinner.Value);
            prices = app.Data.(ticker)(mask);

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
            ylabel(app.UIAxes, 'Price');

            r = computeReturns(prices);
            sr = sharpeRatio(r);
            mdd = maxDrawdown(prices);
            app.StatusLabel.Text = sprintf( ...
                'Annualized Sharpe: %.2f   |   Max drawdown: %.1f%%', sr, 100*mdd);
        end

        function plotCompareMode(app, dates, mask)
            priceMatrix = app.Data{mask, app.Tickers};
            normalized = priceMatrix ./ priceMatrix(1, :);

            plot(app.UIAxes, dates, normalized, 'LineWidth', 1.3);
            legend(app.UIAxes, app.Tickers, 'Location', 'best');
            title(app.UIAxes, 'Normalized price comparison (start = 1.0)');
            ylabel(app.UIAxes, 'Growth of $1');

            mdd = maxDrawdown(priceMatrix);
            [~, worst] = max(mdd);
            app.StatusLabel.Text = sprintf( ...
                'Largest max drawdown in range: %s (%.1f%%)', ...
                app.Tickers{worst}, 100*mdd(worst));
        end

        function exportChart(app)
            [file, path] = uiputfile('*.png', 'Save chart as', 'marketlens_chart.png');
            if isequal(file, 0)
                return   % user cancelled
            end
            outPath = fullfile(path, file);
            exportgraphics(app.UIAxes, outPath, 'Resolution', 150);
            app.StatusLabel.Text = sprintf('Saved chart to %s', outPath);
        end
    end
end
