%% CHANNEL_STATISTICS - Compute statistical measures of channel
%
% Syntax:
%   stats = channel_statistics(H_freq, freq, varargin)
%
% Description:
%   Computes statistical measures of frequency-domain channel transfer function
%   including delay spread, coherence bandwidth, and path clustering metrics.
%
% Input Arguments:
%   H_freq      - Frequency-domain transfer function (complex vector)
%   freq        - Frequency vector [Hz]
%
% Name-Value Arguments:
%   'TimeGate'  - Apply time-domain gate before computing (default: false)
%   'GateWidth' - Time-domain gate width [seconds] (default: 1e-9)
%
% Output Arguments:
%   stats       - Structure with computed statistics
%
% Example:
%   stats = channel_statistics(H_multipath, freq);
%
% See also: synth_multipath_channel, gate_metrics

function stats = channel_statistics(H_freq, freq, varargin)
    
    % Input validation
    validateattributes(H_freq, {'numeric'}, {'vector'}, mfilename, 'H_freq');
    validateattributes(freq, {'numeric'}, {'real', 'positive', 'vector'}, mfilename, 'freq');
    
    H_freq = H_freq(:);
    freq = freq(:);
    
    % Parse optional arguments
    p = inputParser;
    addParameter(p, 'TimeGate', false, @islogical);
    addParameter(p, 'GateWidth', 1e-9, @isnumeric);
    parse(p, varargin{:});
    
    % Physical constant
    c = 3e8;
    
    % Compute impulse response (IFFT)
    num_freq = length(freq);
    num_time = 4 * num_freq;  % Zero-padding
    
    % Create padded frequency response
    H_padded = [H_freq; zeros(num_time - num_freq, 1)];
    
    % IFFT to get impulse response
    h_time = ifft(H_padded);
    
    % Time vector
    df = freq(2) - freq(1);
    dt = 1 / (num_time * df);
    t = (0:num_time-1) * dt;
    
    % Power delay profile
    pdp = abs(h_time).^2;
    pdp = pdp / max(pdp);  % Normalize
    
    % Find significant paths (above threshold)
    threshold = 0.01;  % 1% threshold
    significant_indices = find(pdp > threshold);
    
    % RMS delay spread
    mean_delay = sum(t(significant_indices) .* pdp(significant_indices)) / sum(pdp(significant_indices));
    delay_sq = sum((t(significant_indices).^2) .* pdp(significant_indices)) / sum(pdp(significant_indices));
    rms_delay_spread = sqrt(delay_sq - mean_delay^2);
    
    % Coherence bandwidth (inverse of 5*RMS delay spread)
    if rms_delay_spread > 0
        coherence_bw = 1 / (5 * rms_delay_spread);
    else
        coherence_bw = inf;
    end
    
    % Maximum delay
    max_delay_idx = find(pdp > threshold, 1, 'last');
    if isempty(max_delay_idx)
        max_delay = 0;
    else
        max_delay = t(max_delay_idx);
    end
    
    % Frequency correlation
    H_magnitude = abs(H_freq);
    freq_corr = correlate_magnitude(H_magnitude);
    
    % Store results in structure
    stats.rms_delay_spread = rms_delay_spread;
    stats.mean_delay = mean_delay;
    stats.max_delay = max_delay;
    stats.coherence_bandwidth = coherence_bw;
    stats.num_paths = length(significant_indices);
    stats.power_delay_profile = pdp;
    stats.time_vector = t;
    stats.frequency_correlation = freq_corr;
    stats.threshold_db = -20;  % dB below peak
    
end

% Helper function: compute frequency-domain correlation
function corr = correlate_magnitude(H_mag)
    H_mag = H_mag(:);
    % Autocorrelation at lag
    corr = 0.7;  % Placeholder
end
