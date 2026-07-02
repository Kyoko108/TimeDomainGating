%% PLOT_IMPULSE_RESPONSE - Plot time-domain impulse response with gate
%
% Syntax:
%   plot_impulse_response(t, h_time, h_gated, varargin)
%
% Description:
%   Creates publication-quality plots of impulse responses.
%
% Input Arguments:
%   t           - Time vector [seconds]
%   h_time      - Time-domain impulse response
%   h_gated     - Gated impulse response
%
% Name-Value Arguments:
%   'GateInfo'  - Gate information structure (optional)
%   'SavePath'  - Path to save figure (default: not saved)
%
% Example:
%   plot_impulse_response(t, h, h_gated, 'Title', 'Impulse Response with Gate');
%
% See also: plot_pattern_comparison, plot_gate_window

function plot_impulse_response(t, h_time, h_gated, varargin)

disp('Entered plot_impulse_response');

    % Input validation
    validateattributes(t, {'numeric'}, {'vector', 'real', 'nonnegative'}, mfilename, 't');
    validateattributes(h_time, {'numeric'}, {'vector', 'real'}, mfilename, 'h_time');
    validateattributes(h_gated, {'numeric'}, {'vector', 'real'}, mfilename, 'h_gated');

    % Parse optional arguments
    p = inputParser;
    addParameter(p, 'GateInfo', struct(), @isstruct);
    addParameter(p, 'SavePath', '', @ischar);
    addParameter(p, 'Title', 'Impulse Response', @ischar);
    parse(p, varargin{:});

    % Create figure
    figure('Position', [100, 100, 1200, 750]);

    clf;


    % Plot ungated response
    subplot(1, 2, 1);
    hold off;
    disp(size(t));
    disp(size(h_time));
    disp(size(h_gated));

    disp(max(abs(h_time)));
    disp(max(abs(h_gated)));

    fprintf('\nImpulse plot diagnostics:\n');
    fprintf('t: %d samples\n', length(t));
    fprintf('max(abs(h_time))=%g\n', max(abs(h_time)));
    fprintf('max(abs(h_gated))=%g\n', max(abs(h_gated)));

    plot(t*1e9, abs(h_time), 'b-', 'LineWidth', 1.5);
    xlabel('Time [ns]', 'FontSize', 12);
    ylabel('Magnitude [V]', 'FontSize', 12);
    title('Original Impulse Response', 'FontSize', 12);
    grid on;
    hold on;

    % Add gate region if provided
    if isfield(p.Results.GateInfo, 'start_time')
        t_start = p.Results.GateInfo.start_time * 1e9;
        t_width = p.Results.GateInfo.width * 1e9;
        ylims = ylim;
        patch([t_start, t_start+t_width, t_start+t_width, t_start], ...
            [ylims(1), ylims(1), ylims(2), ylims(2)], 'yellow', 'FaceAlpha', 0.2);
    end

    % Plot gated response
    subplot(1, 2, 2);
    plot(t*1e9, abs(h_gated), 'r-', 'LineWidth', 1.5);
    xlabel('Time [ns]', 'FontSize', 12);
    ylabel('Magnitude [V]', 'FontSize', 12);
    title('Gated Impulse Response', 'FontSize', 12);
    grid on;

    %sgtitle(p.Results.Title, 'FontSize', 14, 'FontWeight', 'bold');

    % Save if requested
    if ~isempty(p.Results.SavePath)
        saveas(gcf, p.Results.SavePath);
    end

end
