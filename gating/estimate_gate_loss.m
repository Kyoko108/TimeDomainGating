%% ESTIMATE_GATE_LOSS - Estimate signal loss due to gating
%
% Syntax:
%   loss_db = estimate_gate_loss(H_freq, H_gated_freq)
%   [loss_db, metrics] = estimate_gate_loss(H_freq, H_gated_freq)
%
% Description:
%   Estimates the amount of signal lost due to gating in frequency domain.
%
% Input Arguments:
%   H_freq          - Original frequency response [V/V]
%   H_gated_freq    - Gated frequency response [V/V]
%
% Output Arguments:
%   loss_db         - Loss in dB
%   metrics         - Structure with additional metrics
%
% See also: gate_metrics, leakage_estimator

function [loss_db, metrics] = estimate_gate_loss(H_freq, H_gated_freq)
    
    % Input validation
    validateattributes(H_freq, {'numeric'}, {'vector'}, mfilename, 'H_freq');
    validateattributes(H_gated_freq, {'numeric'}, {'vector'}, mfilename, 'H_gated_freq');
    
    % Energy before and after gating
    energy_before = sum(abs(H_freq).^2);
    energy_after = sum(abs(H_gated_freq).^2);
    
    % Gate loss in dB
    loss_db = 10 * log10(energy_before / (energy_after + eps));
    
    % Additional metrics
    if nargout > 1
        metrics.energy_before = energy_before;
        metrics.energy_after = energy_after;
        metrics.energy_retained = energy_after / energy_before;
        metrics.power_loss_percent = (1 - energy_after/energy_before) * 100;
    end
    
end
