%% PLOT_GATE_WINDOW - Visualize gate window function
%
% Syntax:
%   plot_gate_window(gate_window, t, varargin)
%
% Description:
%   Creates plots showing gate window shape and time-domain properties.
%
% Input Arguments:
%   gate_window - Gate structure with type, start_time, width
%   t           - Time vector [seconds]
%
% Example:
%   plot_gate_window(gate, t);
%
% See also: create_window, apply_gate

function plot_gate_window(gate_window, t, varargin)

disp('Entered plot_gate_window');

    % Input validation
    validateattributes(t, {'numeric'}, {'vector', 'real', 'nonnegative'}, mfilename, 't');

    % Create figure
    figure('Position', [100, 100, 1000, 750]);
    clf;

    % Create window
    window_length = length(t);
    window = create_window(gate_window.type, window_length);

    % Position window according to gate parameters
    gate_region = (t >= gate_window.start_time) & (t <= gate_window.start_time + gate_window.width);
    gate_applied = zeros(size(t));
    gate_applied(gate_region) = window(gate_region);

    % Plot window shape
    subplot(1, 2, 1);
    hold off;
    plot(t*1e9, window, 'LineWidth', 2);
    xlabel('Time [ns]', 'FontSize', 12);
    ylabel('Window Coefficient', 'FontSize', 12);
    title(sprintf('%s Window', gate_window.type), 'FontSize', 12);
    grid on;

    % Plot applied gate
    subplot(1, 2, 2);
    plot(t*1e9, gate_applied, 'LineWidth', 2);
    xlabel('Time [ns]', 'FontSize', 12);
    ylabel('Gate Coefficient', 'FontSize', 12);
    title('Applied Gate', 'FontSize', 12);
    grid on;

    %sgtitle('Time-Domain Gate Window', 'FontSize', 14, 'FontWeight', 'bold');

end
