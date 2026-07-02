%% TIME_TO_FREQUENCY - Convert time-domain gated signal back to frequency domain
%
% Syntax:
%   H_freq = time_to_frequency(h_time, freq, varargin)
%
% Description:
%   Performs forward FFT to convert time-domain gated impulse response
%   back to frequency domain. Handles proper scaling and normalization.
%
%   Process:
%   1. Perform forward FFT
%   2. Extract frequency range of interest
%   3. Apply scaling to match input frequencies
%   4. Normalize output
%
% Input Arguments:
%   h_time      - Time-domain impulse response [V]
%   freq        - Target frequency vector [Hz]
%
% Name-Value Arguments:
%   'Normalization' - 'none', 'peak', 'energy' (default: 'peak')
%   'Window'        - Apply windowing before FFT: 'none', 'hann', 'hamming' (default: 'none')
%
% Output Arguments:
%   H_freq      - Complex frequency-domain transfer function [V/V]
%
% Example:
%   H_gated = time_to_frequency(h_gated, freq, 'Normalization', 'peak');
%
% See also: freq_to_time_gate, apply_gate

function H_freq = time_to_frequency(h_time, freq, varargin)

    % Input validation
    validateattributes(h_time, {'numeric'}, {'vector'}, mfilename, 'h_time');
    validateattributes(freq, {'numeric'}, {'real', 'positive', 'vector'}, mfilename, 'freq');

    h_time = h_time(:);  % Column vector
    freq = freq(:);
    num_freq = length(freq);
    num_time = length(h_time);

    % Parse optional arguments
    p = inputParser;
    addParameter(p, 'Normalization', 'peak', @(x) ismember(x, {'none', 'peak', 'energy'}));
    addParameter(p, 'Window', 'none', @(x) ismember(x, {'none', 'hann', 'hamming', 'blackman'}));
    parse(p, varargin{:});

    % Apply windowing if requested
    if ~strcmp(p.Results.Window, 'none')
        switch p.Results.Window
            case 'hann'
                win = hann(num_time);
            case 'hamming'
                win = hamming(num_time);
            case 'blackman'
                win = blackman(num_time);
            otherwise
                win = ones(num_time, 1);
        end
        h_windowed = h_time .* win;
    else
        h_windowed = h_time;
    end

    % Perform forward FFT
    H_fft = fft(h_windowed);

    % Normalize by FFT length
    H_fft = H_fft / num_time;

      % % Extract positive frequencies matching input freq vector
      %df_actual = 1 / (num_time * (freq(2) - freq(1)));
      %freq_actual = (0:num_time-1)' * df_actual;

      %% Interpolate or extract to match requested frequencies
      %H_freq = interp1(freq_actual, H_fft, freq, 'linear', 0);
      % Recover the original measured frequency samples.
    % freq_to_time_gate() created the time signal by zero-padding the measured
    % frequency response, so the first num_freq FFT bins correspond directly
    % to the original frequency samples.

    H_freq = H_fft(1:num_freq);
    H_freq = H_freq(:);  % Ensure column vector

    % Normalize output
    switch p.Results.Normalization
        case 'peak'
            max_val = max(abs(H_freq));
            if max_val > 0
                H_freq = H_freq / max_val;
            end
        case 'energy'
            energy = sqrt(sum(abs(H_freq).^2));
            if energy > 0
                H_freq = H_freq / energy;
            end
        case 'none'
            % No normalization
    end

end
