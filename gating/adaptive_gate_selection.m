%% ADAPTIVE_GATE_SELECTION - Automatically select gate parameters based on measured data
%
% Syntax:
%   gate_config = adaptive_gate_selection(h_time, freq, varargin)
%
% Description:
%   Analyzes impulse response characteristics and automatically selects
%   appropriate gate parameters (type, width, position).
%
% Input Arguments:
%   h_time      - Time-domain impulse response [V]
%   freq        - Frequency vector [Hz]
%
% Name-Value Arguments:
%   'SearchMethod' - 'auto', 'grid', 'exhaustive' (default: 'auto')
%
% Output Arguments:
%   gate_config     - Recommended gate configuration structure
%
% See also: optimize_gate, create_window

function gate_config = adaptive_gate_selection(h_time, freq, varargin)
    
    % Input validation
    validateattributes(h_time, {'numeric'}, {'vector', 'real'}, mfilename, 'h_time');
    validateattributes(freq, {'numeric'}, {'vector', 'real', 'positive'}, mfilename, 'freq');
    
    h_time = h_time(:);
    freq = freq(:);
    
    % Parse optional arguments
    p = inputParser;
    addParameter(p, 'SearchMethod', 'auto', @ischar);
    parse(p, varargin{:});
    
    % Time vector
    df = freq(2) - freq(1);
    dt = 1 / (length(h_time) * df);
    t = (0:length(h_time)-1)' * dt;
    
    % Analyze impulse response
    h_power = abs(h_time).^2;
    h_power_norm = h_power / max(h_power);
    
    % Find signal boundaries (above 0.1% threshold)
    threshold = 0.001;
    above_threshold = find(h_power_norm > threshold);
    
    if isempty(above_threshold)
        % Empty response
        gate_config.type = 'hann';
        gate_config.start_time = 0;
        gate_config.width = 1e-9;
        gate_config.confidence = 0;
        return;
    end
    
    % Estimate signal duration
    t_start = t(above_threshold(1));
    t_end = t(above_threshold(end));
    signal_duration = t_end - t_start;
    
    % Find main peak
    [~, peak_idx] = max(h_power);
    t_peak = t(peak_idx);
    
    % Determine gate width (1.5x signal duration as heuristic)
    gate_width = min(1.5 * signal_duration, 50e-9);
    gate_width = max(gate_width, 2e-9);
    
    % Determine gate position (centered on peak)
    gate_start = max(0, t_peak - gate_width/2);
    
    % Select window type based on spectral characteristics
    % Use Hann window as default (good sidelobe suppression)
    window_type = 'hann';
    
    % Compute multipath ratio
    multipath_power = sum(h_power(h_power_norm < 0.1));
    direct_power = sum(h_power(h_power_norm >= 0.1));
    multipath_ratio = multipath_power / (direct_power + eps);
    
    if multipath_ratio > 0.5
        % Strong multipath: use Blackman window for better sidelobe suppression
        window_type = 'blackman';
    elseif multipath_ratio > 0.1
        % Moderate multipath: use Hann (default)
        window_type = 'hann';
    else
        % Weak multipath: can use simpler window
        window_type = 'hamming';
    end
    
    % Create output structure
    gate_config.type = window_type;
    gate_config.start_time = gate_start;
    gate_config.width = gate_width;
    gate_config.dt = dt;
    gate_config.multipath_ratio = multipath_ratio;
    gate_config.confidence = 0.7;  % Heuristic confidence measure
    gate_config.analysis_method = p.Results.SearchMethod;
    
end
