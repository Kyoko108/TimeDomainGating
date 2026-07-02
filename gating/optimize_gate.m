%% OPTIMIZE_GATE - Automatically optimize time-domain gate parameters
%
% Syntax:
%   [gate_opt, metrics] = optimize_gate(h_time, freq, channel_config, varargin)
%
% Description:
%   Finds optimal gate width and position that minimize multipath leakage
%   while maximizing signal energy within the gate.
%
%   Optimization criterion:
%   J = energy_in_gate - lambda * energy_outside_gate
%
% Input Arguments:
%   h_time          - Time-domain impulse response [V]
%   freq            - Frequency vector [Hz]
%   channel_config  - Channel configuration structure
%
% Name-Value Arguments:
%   'SearchMethod'  - 'grid', 'exhaustive' (default: 'grid')
%   'NumPoints'     - Number of search points (default: 50)
%   'WindowType'    - Default window type (default: 'hann')
%
% Output Arguments:
%   gate_opt        - Optimized gate structure with fields:
%       .type       - Window type
%       .start_time - Optimal start time [seconds]
%       .width      - Optimal gate width [seconds]
%       .cost       - Optimization cost value
%   metrics         - Structure with optimization metrics
%
% Example:
%   [gate_opt, metrics] = optimize_gate(h_time, freq, chan_config);
%
% See also: create_window, gate_metrics, apply_gate

function [gate_opt, metrics] = optimize_gate(h_time, freq, channel_config, varargin)
    
    % Input validation
    validateattributes(h_time, {'numeric'}, {'vector', 'real'}, mfilename, 'h_time');
    validateattributes(freq, {'numeric'}, {'vector', 'real', 'positive'}, mfilename, 'freq');
    
    h_time = h_time(:);  % Column vector
    num_samples = length(h_time);
    
    % Parse optional arguments
    p = inputParser;
    addParameter(p, 'SearchMethod', 'grid', @(x) ismember(x, {'grid', 'exhaustive'}));
    addParameter(p, 'NumPoints', 50, @isnumeric);
    addParameter(p, 'WindowType', 'hann', @ischar);
    parse(p, varargin{:});
    
    % Time vector
    df = freq(2) - freq(1);
    dt = 1 / (num_samples * df);
    t = (0:num_samples-1)' * dt;
    
    % Find significant signal region
    h_power = abs(h_time).^2;
    h_power_norm = h_power / max(h_power);
    above_threshold = find(h_power_norm > 0.001);
    
    if isempty(above_threshold)
        % No significant energy, return empty gate
        gate_opt.type = p.Results.WindowType;
        gate_opt.start_time = 0;
        gate_opt.width = 1e-9;
        gate_opt.cost = inf;
        metrics.search_points = 0;
        return;
    end
    
    t_start_min = max(0, t(above_threshold(1)) - 0.5e-9);
    t_start_max = t(above_threshold(end));
    t_width_min = channel_config.gate_width_min;
    t_width_max = channel_config.gate_width_max;
    
    % Grid search over gate parameters
    num_starts = p.Results.NumPoints;
    num_widths = p.Results.NumPoints;
    
    t_starts = linspace(t_start_min, t_start_max, num_starts);
    t_widths = linspace(t_width_min, t_width_max, num_widths);
    
    best_cost = inf;
    best_gate = struct();
    
    % Search loop
    for start_idx = 1:num_starts
        for width_idx = 1:num_widths
            t_start = t_starts(start_idx);
            t_width = t_widths(width_idx);
            
            % Define gate
            gate_region = (t >= t_start) & (t <= t_start + t_width);
            
            % Compute cost
            energy_in = sum(h_power(gate_region)) * dt;
            energy_out = sum(h_power(~gate_region)) * dt;
            
            % Cost function: maximize in-gate energy, minimize out-gate energy
            lambda = 0.5;  % Weighting factor
            cost = -energy_in + lambda * energy_out;
            
            % Update best
            if cost < best_cost
                best_cost = cost;
                best_gate.start_time = t_start;
                best_gate.width = t_width;
                best_gate.energy_in = energy_in;
                best_gate.energy_out = energy_out;
            end
        end
    end
    
    % Set output
    gate_opt.type = p.Results.WindowType;
    gate_opt.start_time = best_gate.start_time;
    gate_opt.width = best_gate.width;
    gate_opt.dt = dt;
    gate_opt.cost = best_cost;
    
    % Compute metrics
    metrics.search_points = num_starts * num_widths;
    metrics.best_cost = best_cost;
    metrics.energy_in_gate = best_gate.energy_in;
    metrics.energy_out_gate = best_gate.energy_out;
    metrics.gate_efficiency = best_gate.energy_in / (best_gate.energy_in + best_gate.energy_out);
    
end
