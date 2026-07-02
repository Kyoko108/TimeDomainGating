%% GATE_WIDTH_SEARCH - Search for optimal gate width
%
% Syntax:
%   [best_width, best_metric, width_sweep] = gate_width_search(h_time, freq, metric_type, varargin)
%
% Description:
%   Sweeps over range of gate widths and finds optimal width based on specified metric.
%
% Input Arguments:
%   h_time          - Time-domain impulse response [V]
%   freq            - Frequency vector [Hz]
%   metric_type     - Optimization metric: 'energy', 'leakage', 'snr' (default: 'energy')
%
% Name-Value Arguments:
%   'NumPoints'     - Number of width search points (default: 50)
%   'MinWidth'      - Minimum gate width [seconds] (default: 1e-9)
%   'MaxWidth'      - Maximum gate width [seconds] (default: 100e-9)
%
% Output Arguments:
%   best_width      - Optimal gate width [seconds]
%   best_metric     - Value of metric at optimum
%   width_sweep     - Structure with sweep results
%
% See also: optimize_gate, gate_metrics

function [best_width, best_metric, width_sweep] = gate_width_search(h_time, freq, metric_type, varargin)
    
    % Input validation
    validateattributes(h_time, {'numeric'}, {'vector', 'real'}, mfilename, 'h_time');
    validateattributes(freq, {'numeric'}, {'vector', 'real', 'positive'}, mfilename, 'freq');
    
    h_time = h_time(:);
    freq = freq(:);
    
    % Parse optional arguments
    p = inputParser;
    addParameter(p, 'NumPoints', 50, @isnumeric);
    addParameter(p, 'MinWidth', 1e-9, @isnumeric);
    addParameter(p, 'MaxWidth', 100e-9, @isnumeric);
    parse(p, varargin{:});
    
    % Width sweep vector
    widths = linspace(p.Results.MinWidth, p.Results.MaxWidth, p.Results.NumPoints);
    metrics_sweep = zeros(p.Results.NumPoints, 1);
    
    % Time vector
    df = freq(2) - freq(1);
    dt = 1 / (length(h_time) * df);
    t = (0:length(h_time)-1)' * dt;
    
    % Find main peak for gate positioning
    [~, peak_idx] = max(abs(h_time));
    t_peak = t(peak_idx);
    
    % Sweep over widths
    for width_idx = 1:p.Results.NumPoints
        width = widths(width_idx);
        
        % Position gate around peak
        t_start = max(0, t_peak - width/2);
        t_end = t_start + width;
        
        % Create gate
        gate_region = (t >= t_start) & (t <= t_end);
        h_gated = h_time .* gate_region;
        
        % Compute metric
        switch lower(metric_type)
            case 'energy'
                energy_in = sum(abs(h_gated).^2) * dt;
                energy_out = sum(abs(h_time(~gate_region)).^2) * dt;
                metrics_sweep(width_idx) = energy_in / (energy_in + energy_out + eps);
                
            case 'leakage'
                H_gated = fft(h_gated);
                [leakage_db, ~] = leakage_estimator(H_gated);
                metrics_sweep(width_idx) = leakage_db;
                
            case 'snr'
                % Simplified SNR metric
                signal_power = sum(abs(h_gated).^2);
                noise_power = sum(abs(h_time(~gate_region)).^2);
                metrics_sweep(width_idx) = 10 * log10(signal_power / (noise_power + eps));
        end
    end
    
    % Find best width
    if strcmp(lower(metric_type), 'leakage')
        [best_metric, best_idx] = min(metrics_sweep);  % Minimize leakage
    else
        [best_metric, best_idx] = max(metrics_sweep);  % Maximize energy/SNR
    end
    
    best_width = widths(best_idx);
    
    % Return sweep data
    width_sweep.widths = widths;
    width_sweep.metrics = metrics_sweep;
    width_sweep.best_width = best_width;
    width_sweep.best_metric = best_metric;
    width_sweep.metric_type = metric_type;
    
end
