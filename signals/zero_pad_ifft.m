%% ZERO_PAD_IFFT - Perform inverse FFT with zero-padding for time-domain resolution
%
% Syntax:
%   h_time = zero_pad_ifft(H_freq, freq, varargin)
%   [h_time, t, H_padded] = zero_pad_ifft(H_freq, freq, varargin)
%
% Description:
%   Performs inverse FFT with zero-padding to obtain high-resolution
%   time-domain impulse response. Zero-padding improves time-domain
%   resolution without changing underlying signal information.
%
% Input Arguments:
%   H_freq      - Complex frequency response [V/V]
%   freq        - Frequency vector [Hz]
%
% Name-Value Arguments:
%   'PadFactor'     - Zero-padding factor: 1, 2, 4, 8, 16 (default: 4)
%   'TimeResolution' - Desired time resolution [seconds] (optional)
%   'RealOutput'    - Return only real part (default: true)
%
% Output Arguments:
%   h_time      - Time-domain impulse response [V]
%   t           - Time vector [seconds]
%   H_padded    - Zero-padded frequency response [V/V]
%
% Example:
%   [h_time, t] = zero_pad_ifft(H_freq, freq, 'PadFactor', 4);
%
% Physics:
%   Time resolution = 1 / (BW * PadFactor)
%   where BW is bandwidth of H_freq
%
% See also: freq_to_time_gate, apply_gate

function [h_time, t, H_padded] = zero_pad_ifft(H_freq, freq, varargin)
    
    % Input validation
    validateattributes(H_freq, {'numeric'}, {'vector'}, mfilename, 'H_freq');
    validateattributes(freq, {'numeric'}, {'real', 'positive', 'vector'}, mfilename, 'freq');
    
    H_freq = H_freq(:);  % Column vector
    freq = freq(:);
    num_freq = length(freq);
    
    if length(H_freq) ~= num_freq
        error('H_freq and freq must have same length');
    end
    
    % Parse optional arguments
    p = inputParser;
    addParameter(p, 'PadFactor', 4, @isnumeric);
    addParameter(p, 'TimeResolution', [], @isnumeric);
    addParameter(p, 'RealOutput', true, @islogical);
    parse(p, varargin{:});
    
    % Validate padding factor
    valid_pads = [1, 2, 4, 8, 16];
    if ~ismember(p.Results.PadFactor, valid_pads)
        warning('PadFactor should be power of 2. Using %d', p.Results.PadFactor);
    end
    
    % Compute FFT length
    fft_length = p.Results.PadFactor * num_freq;
    
    % If TimeResolution is specified, adjust FFT length accordingly
    if ~isempty(p.Results.TimeResolution)
        df = freq(2) - freq(1);
        required_fft = ceil(1 / (p.Results.TimeResolution * df));
        fft_length = max(fft_length, required_fft);
    end
    
    % Zero-pad the frequency response
    H_padded = [H_freq; zeros(fft_length - num_freq, 1)];
    
    % Perform inverse FFT
    h_time_raw = ifft(H_padded);
    
    % Scale appropriately
    % Account for the frequency resolution and normalization
    df = freq(2) - freq(1);
    h_time = h_time_raw * (fft_length * df);  % Normalize by number of points and freq resolution
    
    % Return only real part if requested
    if p.Results.RealOutput
        h_time = real(h_time);
    end
    
    % Create time vector
    dt = 1 / (fft_length * df);
    t = (0:fft_length-1)' * dt;
    
end
