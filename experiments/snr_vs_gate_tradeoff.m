%% SNR_VS_GATE_TRADEOFF - Analyze SNR versus gate-width tradeoff
%
% Syntax:
%   run snr_vs_gate_tradeoff
%
% Description:
%   Experiment analyzing how SNR varies with gate width.
%   Shows tradeoff between signal retention and noise suppression.
%
% Output:
%   Plots and metrics saved to results/ directory
%
% See also: gate_width_search, optimize_gate

%% Setup
clear; close all;
run('config/simulation_config.m');
run('config/antenna_config.m');
run('config/channel_config.m');

%% Create test signal
freq = cfg.freq;
theta = cfg.theta;

% Generate antenna pattern
pattern_aut = radiation_pattern(theta, ant);

% Generate multipath channel
H_multipath = synth_multipath_channel(freq, pattern_aut, theta, chan);

% Test with different SNR levels
snr_levels = [20, 30, 40, 50];
gate_widths = linspace(2e-9, 50e-9, 30);

figure('Position', [100, 100, 1200, 600]);

for snr_idx = 1:length(snr_levels)
    snr_db = snr_levels(snr_idx);
    
    % Add noise
    H_noisy = add_awgn(H_multipath, snr_db);
    
    % Convert to time domain
    [h_time, t] = freq_to_time_gate(H_noisy, freq, 'ZeroPadFactor', cfg.zero_pad_factor);
    
    % Search for optimal gate width
    [best_width, best_metric, width_sweep] = gate_width_search(h_time, freq, 'energy', ...
        'NumPoints', 30, 'MinWidth', 2e-9, 'MaxWidth', 50e-9);
    
    % Plot
    subplot(2, 2, snr_idx);
    plot(width_sweep.widths*1e9, width_sweep.metrics, 'LineWidth', 2);
    hold on;
    plot(best_width*1e9, best_metric, 'r*', 'MarkerSize', 15);
    xlabel('Gate Width [ns]');
    ylabel('Energy Ratio');
    title(sprintf('SNR = %d dB (Optimal: %.2f ns)', snr_db, best_width*1e9));
    grid on;
end

sgtitle('SNR vs Gate-Width Tradeoff');
