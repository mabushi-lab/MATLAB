%% Lesson 5 — Plotting
% MATLAB's plotting is imperative/stateful (like matplotlib's pyplot
% interface): you issue commands against a "current figure/axes" rather
% than building an object graph up front, though you can grab handles
% too (shown below) for more control.

%% Basic line plot
x = linspace(0, 2*pi, 200);
y = sin(x);

figure;                    % opens a new figure window
plot(x, y);
title('sin(x)');
xlabel('x');
ylabel('sin(x)');
grid on;

%% Multiple series on one axes
figure;
plot(x, sin(x), 'b-', 'LineWidth', 1.5); hold on
plot(x, cos(x), 'r--', 'LineWidth', 1.5);
hold off
legend('sin(x)', 'cos(x)', 'Location', 'best');
title('sin and cos');

%% Subplots — a grid of small axes in one figure
figure;
subplot(2, 1, 1);          % 2 rows, 1 col, 1st panel
plot(x, sin(x));
title('sin');
subplot(2, 1, 2);          % 2nd panel
plot(x, cos(x));
title('cos');

%% Capturing handles for fine control (instead of relying on "current" state)
fig = figure;
ax = axes(fig);
plot(ax, x, sin(x));
ax.Title.String = 'Set properties via the handle';
ax.XLabel.String = 'x';
ax.FontSize = 11;

%% Bar / scatter / histogram — you'll use these on returns data later
figure;
subplot(1,3,1); bar([3 7 2 9]);         title('bar');
subplot(1,3,2); scatter(randn(1,100), randn(1,100), 10, 'filled');
title('scatter');
subplot(1,3,3); histogram(randn(1,1000), 30); title('histogram');

%% Saving a figure to disk
% saveas(fig, 'myplot.png');    % uncomment to actually write a file
% exportgraphics(ax, 'myplot.png', 'Resolution', 150);  % higher quality

%% Closing figures programmatically
% close all;   % uncomment if running this whole script headlessly

%% Try it yourself
% 1. Plot y = x.^2 and y = x.^3 on the SAME axes for x in [-5, 5], with
%    a legend and grid.
% 2. Build a 2x2 subplot showing sin, cos, tan, and exp, all over the
%    same x range, each with its own title.
% 3. Save one of your figures to a PNG using exportgraphics — then
%    check the file actually landed where you expected.
