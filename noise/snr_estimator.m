%% SNR_ESTIMATOR - Estimate signal-to-noise ratio
%
% Syntax:
%   snr_estimated = snr_estimator(signal_noisy, signal_ref, varargin)
%   [snr_estimated, snr_db] = snr_estimator(signal_noisy, signal_ref, varargin)
%
% Description:
%   Estimates SNR from noisy signal using reference signal or noise only.
%
% Input Arguments:
%   signal_noisy    - Signal with noise
%   signal_ref      - Reference signal (clean) or empty for noise-only estimate
%
% Output Arguments:
%   snr_estimated   - SNR in linear scale
%   snr_db          - SNR in dB
%
% Example:
%   snr_db = snr_estimator(signal_noisy, signal_clean);
%
% See also: add_awgn, noise_power_estimate

function [snr_estimated, snr_db] = snr_estimator(signal_noisy, signal_ref, varargin)
    
    % Input validation
    validateattributes(signal_noisy, {'numeric'}, {'vector'}, mfilename, 'signal_noisy');
    
    signal_noisy = signal_noisy(:);
    
    if ~isempty(signal_ref)
        validateattributes(signal_ref, {'numeric'}, {'vector'}, mfilename, 'signal_ref');
        signal_ref = signal_ref(:);
        
        if length(signal_noisy) ~= length(signal_ref)
            error('Signals must have same length');
        end
        
        % Compute noise as difference
        noise = signal_noisy - signal_ref;
        noise_power = mean(abs(noise).^2);
        signal_power = mean(abs(signal_ref).^2);
    else
        % Estimate noise power from signal itself (assumes sparse signal)
        signal_sorted = sort(abs(signal_noisy));
        noise_power = mean(signal_sorted(1:round(0.2*length(signal_sorted))).^2);
        signal_power = mean(abs(signal_noisy).^2) - noise_power;
    end
    
    % Avoid division by zero
    if noise_power == 0
        noise_power = eps;
    end
    
    snr_estimated = signal_power / noise_power;
    snr_db = 10 * log10(snr_estimated);
    
end
