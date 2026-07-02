%% ADD_AWGN - Add additive white Gaussian noise to signal
%
% Syntax:
%   signal_noisy = add_awgn(signal, snr_db, varargin)
%   [signal_noisy, noise] = add_awgn(signal, snr_db, varargin)
%
% Description:
%   Adds AWGN to signal at specified SNR level.
%
% Input Arguments:
%   signal      - Input signal (real or complex)
%   snr_db      - Signal-to-noise ratio [dB]
%
% Name-Value Arguments:
%   'RNG_Seed'  - Random seed for reproducibility (default: [])
%
% Output Arguments:
%   signal_noisy - Signal with added noise
%   noise        - Generated noise signal
%
% Example:
%   signal_noisy = add_awgn(signal, 40);
%
% See also: snr_estimator, noise_power_estimate

function [signal_noisy, noise] = add_awgn(signal, snr_db, varargin)
    
    % Input validation
    validateattributes(signal, {'numeric'}, {'vector'}, mfilename, 'signal');
    validateattributes(snr_db, {'numeric'}, {'scalar', 'real'}, mfilename, 'snr_db');
    
    signal = signal(:);  % Column vector
    
    % Parse optional arguments
    p = inputParser;
    addParameter(p, 'RNG_Seed', [], @isnumeric);
    parse(p, varargin{:});
    
    % Set random seed if specified
    if ~isempty(p.Results.RNG_Seed)
        rng(p.Results.RNG_Seed);
    end
    
    % Compute signal power
    signal_power = mean(abs(signal).^2);
    
    % Compute noise power from SNR
    snr_linear = 10^(snr_db/10);
    noise_power = signal_power / snr_linear;
    noise_std = sqrt(noise_power);
    
    % Generate noise
    if isreal(signal)
        noise = noise_std * randn(size(signal));
    else
        noise = (noise_std/sqrt(2)) * (randn(size(signal)) + 1j*randn(size(signal)));
    end
    
    % Add noise to signal
    signal_noisy = signal + noise;
    
end
