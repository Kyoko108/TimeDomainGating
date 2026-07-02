%% FREQ_TO_TIME_GATE - Convert frequency-domain response to time-domain impulse response
%
% Syntax:
%   h_time = freq_to_time_gate(H_freq, freq, varargin)
%   [h_time, t] = freq_to_time_gate(H_freq, freq, varargin)
%
% Description:
%   Performs inverse FFT with zero-padding to convert frequency-domain
%   transfer function to time-domain impulse response. Applies proper
%   scaling and handles FFT length computation for specified time resolution.
%
%   Process:
%   1. Apply zero-padding for improved time resolution
%   2. Perform inverse FFT
%   3. Scale by frequency resolution
%   4. Extract real impulse response
%
% Input Arguments:
%   H_freq      - Complex frequency response [V/V]
%   freq        - Frequency vector [Hz]
%
% Name-Value Arguments:
%   'ZeroPadFactor' - Zero-padding multiplication factor (default: 4)
%   'TimeScale'     - Multiply time response by this factor (default: 1)
%
% Output Arguments:
%   h_time      - Time-domain impulse response [V]
%   t           - Time vector [seconds]
%
% Example:
%   [h_time, t] = freq_to_time_gate(H_freq, freq, 'ZeroPadFactor', 4);
%
% Physics:
%   - Zero-padding improves time-domain resolution
%   - IFFT properly scaled gives physical impulse response
%   - Time resolution inversely proportional to bandwidth
%
% See also: time_to_frequency, apply_gate, create_frequency_response

function [h_time, t] = freq_to_time_gate(H_freq, freq, varargin)
    
    % Input validation
    validateattributes(H_freq, {'numeric'}, {'vector'}, mfilename, 'H_freq');
    validateattributes(freq, {'numeric'}, {'real', 'positive', 'vector'}, mfilename, 'freq');
    
    H_freq = H_freq(:);  % Column vector
    freq = freq(:);
    num_freq = length(freq);
    
    % Check dimensions match
    if length(H_freq) ~= num_freq
        error('H_freq and freq must have same length');
    end
    
    % Parse optional arguments
    p = inputParser;
    addParameter(p, 'ZeroPadFactor', 4, @isnumeric);
    addParameter(p, 'TimeScale', 1, @isnumeric);
    parse(p, varargin{:});
    
    % Frequency resolution
    df = freq(2) - freq(1);
    
    % FFT length with zero-padding
    fft_length = p.Results.ZeroPadFactor * num_freq;
    
    % Zero-pad the frequency response
    H_padded = [H_freq; zeros(fft_length - num_freq, 1)];
    
    % Perform inverse FFT
    % Scale by number of points for proper amplitude
    h_time_raw = ifft(H_padded) * fft_length;
    
    % Scale by frequency resolution to account for continuous-time assumption
    h_time = h_time_raw * df;
    
    % Apply additional time scaling if specified
    h_time = h_time * p.Results.TimeScale;
    
    % Extract real part (imaginary part should be negligible)
    h_time = real(h_time);
    
    % Create time vector
    dt = 1 / (fft_length * df);  % Time sample spacing
    t = (0:fft_length-1)' * dt;
    
end
