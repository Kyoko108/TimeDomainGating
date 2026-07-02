%% APPLY_GATE - Apply time-domain gate window to impulse response
%
% Syntax:
%   h_gated = apply_gate(h_time, gate_window, varargin)
%   [h_gated, gate_applied] = apply_gate(h_time, gate_window, varargin)
%
% Description:
%   Applies a time-domain gate window to the impulse response to suppress
%   multipath and noise components outside the gate interval.
%
%   Gate is defined by:
%   - Start time
%   - Width (duration)
%   - Window function (rectangular, Hann, Hamming, etc.)
%
% Input Arguments:
%   h_time          - Time-domain impulse response [V]
%   gate_window     - Gate window structure with fields:
%       .type       - Window type: 'rectangular', 'hann', 'hamming', etc.
%       .start_time - Gate start time [seconds]
%       .width      - Gate width/duration [seconds]
%       .dt         - Time sample spacing [seconds] (default: compute from h_time)
%
% Name-Value Arguments:
%   'ZeroOutside'   - Zero samples outside gate (default: true)
%   'Taper'         - Apply smooth taper at edges (default: false)
%
% Output Arguments:
%   h_gated         - Gated impulse response [V]
%   gate_applied    - Binary gate mask [1]
%
% Example:
%   gate.type = 'hann';
%   gate.start_time = 5e-9;
%   gate.width = 10e-9;
%   gate.dt = 0.1e-9;
%   h_gated = apply_gate(h_time, gate);
%
% See also: create_window, optimize_gate, freq_to_time_gate

function [h_gated, gate_applied] = apply_gate(h_time, gate_window, varargin)
    
    % Input validation
    validateattributes(h_time, {'numeric'}, {'vector', 'real'}, mfilename, 'h_time');
    
    h_time = h_time(:);  % Column vector
    num_samples = length(h_time);
    
    % Parse optional arguments
    p = inputParser;
    addParameter(p, 'ZeroOutside', true, @islogical);
    addParameter(p, 'Taper', false, @islogical);
    parse(p, varargin{:});
    
    % Compute time step if not provided
    if ~isfield(gate_window, 'dt')
        % Default: assume 4x zero-padded FFT from 401-point frequency sweep
        gate_window.dt = 1 / (4 * 401 * (12e9 - 8e9));
    end
    
    % Create time vector
    t = (0:num_samples-1)' * gate_window.dt;
    
    % Create gate mask
    t_start = gate_window.start_time;
    t_end = t_start + gate_window.width;
    
    gate_region = (t >= t_start) & (t <= t_end);
    
    % Create window function
    if strcmp(gate_window.type, 'rectangular')
        % Rectangular window
        window_fn = ones(num_samples, 1);
        window_fn(~gate_region) = 0;
    else
        % Get indices within gate region
        gate_indices = find(gate_region);
        gate_length = length(gate_indices);
        
        % Create base window
        switch gate_window.type
            case 'hann'
                base_window = hann(gate_length);
            case 'hamming'
                base_window = hamming(gate_length);
            case 'blackman'
                base_window = blackman(gate_length);
            case 'kaiser'
                base_window = kaiser(gate_length, 8.6);  % Default beta for ~100 dB sidelobe
            case 'tukey'
                r = 0.5;  % Cosine fraction
                base_window = tukeywin(gate_length, r);
            otherwise
                base_window = hann(gate_length);
        end
        
        % Map window to full time vector
        window_fn = zeros(num_samples, 1);
        if ~isempty(gate_indices)
            window_fn(gate_indices) = base_window;
        end
    end
    
    % Apply taper if requested (smooth edges outside gate)
    if p.Results.Taper
        % Create smooth transition outside gate
        taper_length = max(1, round(gate_length / 10));
        for i = 1:taper_length
            taper_factor = i / taper_length;
            if gate_indices(1) - i >= 1
                window_fn(gate_indices(1) - i) = taper_factor * window_fn(gate_indices(1));
            end
            if gate_indices(end) + i <= num_samples
                window_fn(gate_indices(end) + i) = taper_factor * window_fn(gate_indices(end));
            end
        end
    end
    
    % Apply gate to impulse response
    h_gated = h_time .* window_fn;
    
    % Zero outside gate if requested
    if p.Results.ZeroOutside
        h_gated(~gate_region) = 0;
    end
    
    gate_applied = window_fn;
    
end
