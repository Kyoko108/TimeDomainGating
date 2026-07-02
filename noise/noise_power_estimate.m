%% NOISE_POWER_ESTIMATE - Estimate noise power from measurement
%
% Syntax:
%   noise_power = noise_power_estimate(signal, varargin)
%
% Description:
%   Estimates noise power from received signal using various methods.
%
% Input Arguments:
%   signal      - Input signal (potentially noisy)
%
% Name-Value Arguments:
%   'Method'    - 'percentile', 'median', 'iqr' (default: 'percentile')
%
% Output Arguments:
%   noise_power - Estimated noise power
%
% See also: snr_estimator, add_awgn

function noise_power = noise_power_estimate(signal, varargin)
    
    % Input validation
    validateattributes(signal, {'numeric'}, {'vector'}, mfilename, 'signal');
    
    signal = signal(:);
    signal_mag = abs(signal);
    
    % Parse optional arguments
    p = inputParser;
    addParameter(p, 'Method', 'percentile', @(x) ismember(x, {'percentile', 'median', 'iqr'}));
    parse(p, varargin{:});
    
    % Estimate noise from low-amplitude samples
    switch p.Results.Method
        case 'percentile'
            % Use 20th percentile as noise estimate
            noise_estimate = prctile(signal_mag, 20);
            
        case 'median'
            % Use median of lower half
            low_samples = signal_mag(signal_mag < median(signal_mag));
            noise_estimate = mean(low_samples);
            
        case 'iqr'
            % Use interquartile range
            q1 = prctile(signal_mag, 25);
            q3 = prctile(signal_mag, 75);
            noise_estimate = (q3 - q1) / 1.35;  % Gaussian scaling
    end
    
    noise_power = noise_estimate^2;
    
end
