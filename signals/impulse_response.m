%% IMPULSE_RESPONSE - Compute time-domain impulse response characteristics
%
% Syntax:
%   h_info = impulse_response(h_time, t, varargin)
%
% Description:
%   Computes various characteristics of time-domain impulse response including
%   peak value, energy, duration, and path identification.
%
% Input Arguments:
%   h_time      - Time-domain impulse response [V]
%   t           - Time vector [seconds]
%
% Name-Value Arguments:
%   'Threshold' - Threshold for path detection (default: 0.01)
%
% Output Arguments:
%   h_info      - Structure with impulse response characteristics
%
% Example:
%   h_info = impulse_response(h_time, t);
%
% See also: freq_to_time_gate, channel_statistics

function h_info = impulse_response(h_time, t, varargin)

    % Input validation
    validateattributes(h_time, {'numeric'}, {'vector', 'real'}, mfilename, 'h_time');
    validateattributes(t, {'numeric'}, {'vector', 'real', 'finite', 'nonnegative'}, mfilename, 't');

    h_time = h_time(:);
    t = t(:);

    if length(h_time) ~= length(t)
        error('h_time and t must have same length');
    end

    % Parse optional arguments
    p = inputParser;
    addParameter(p, 'Threshold', 0.01, @isnumeric);
    parse(p, varargin{:});

    % Compute basic properties
    h_power = abs(h_time).^2;
    h_power_norm = h_power / max(h_power);

    % Peak values
    h_info.peak_value = max(abs(h_time));
    [h_info.peak_magnitude, peak_idx] = max(abs(h_time));
    h_info.peak_time = t(peak_idx);

    % Energy
    dt = t(2) - t(1);
    h_info.total_energy = sum(h_power) * dt;
    h_info.rms_value = sqrt(mean(h_power));

    % Duration (above threshold)
    above_threshold = find(h_power_norm > p.Results.Threshold);
    if ~isempty(above_threshold)
        h_info.duration = t(above_threshold(end)) - t(above_threshold(1));
        h_info.start_time = t(above_threshold(1));
        h_info.end_time = t(above_threshold(end));
    else
        h_info.duration = 0;
        h_info.start_time = 0;
        h_info.end_time = 0;
    end

    % Path detection
    [peaks_mag, peaks_idx] = findpeaks(h_power_norm, 'MinPeakHeight', p.Results.Threshold);
    h_info.num_paths = length(peaks_idx);
    h_info.path_delays = t(peaks_idx);
    h_info.path_magnitudes = peaks_mag;

end
