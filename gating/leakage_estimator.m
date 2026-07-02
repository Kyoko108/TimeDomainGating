%% LEAKAGE_ESTIMATOR - Estimate spectral leakage due to gating
%
% Syntax:
%   leakage_db = leakage_estimator(H_freq, varargin)
%   [leakage_db, leakage_factor] = leakage_estimator(H_freq, varargin)
%
% Description:
%   Estimates the amount of spectral leakage introduced by time-domain gating.
%   Computes ratio of out-of-band power to in-band power.
%
% Input Arguments:
%   H_freq      - Gated frequency response [V/V]
%
% Name-Value Arguments:
%   'MainLobeBW' - Main lobe bandwidth fraction (default: 0.1)
%
% Output Arguments:
%   leakage_db  - Leakage power in dB
%   leakage_factor - Leakage as fraction [0-1]
%
% See also: gate_metrics, estimate_gate_loss

function [leakage_db, leakage_factor] = leakage_estimator(H_freq, varargin)
    
    % Input validation
    validateattributes(H_freq, {'numeric'}, {'vector'}, mfilename, 'H_freq');
    
    H_freq = H_freq(:);
    H_mag = abs(H_freq);
    
    % Parse optional arguments
    p = inputParser;
    addParameter(p, 'MainLobeBW', 0.1, @isnumeric);
    parse(p, varargin{:});
    
    % Find main lobe
    [~, peak_idx] = max(H_mag);
    main_lobe_width = max(1, round(length(H_mag) * p.Results.MainLobeBW));
    main_lobe_idx = max(1, peak_idx - main_lobe_width):min(length(H_mag), peak_idx + main_lobe_width);
    
    % Compute leakage
    power_main = sum(H_mag(main_lobe_idx).^2);
    power_sidelobe = sum(H_mag.^2) - power_main;
    
    leakage_factor = power_sidelobe / (power_main + power_sidelobe + eps);
    leakage_db = 10 * log10(leakage_factor + eps);
    
end
