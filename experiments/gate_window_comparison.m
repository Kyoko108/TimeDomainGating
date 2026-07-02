%% GATE_WINDOW_COMPARISON - Compare different gate window types
%
% Syntax:
%   run gate_window_comparison
%
% Description:
%   Experiment comparing performance of different time-domain gate windows.
%   Tests rectangular, Hann, Hamming, Blackman, Kaiser, and Tukey windows.
%
% Output:
%   Plots and metrics saved to results/ directory
%
% See also: optimize_gate, gate_metrics

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

% Add noise
H_noisy = add_awgn(H_multipath, cfg.snr_db);

% Convert to time domain
[h_time, t] = freq_to_time_gate(H_noisy, freq, 'ZeroPadFactor', cfg.zero_pad_factor);

%% Test different window types
window_types = {'rectangular', 'hann', 'hamming', 'blackman', 'kaiser', 'tukey'};
num_windows = length(window_types);

results = struct();
figure('Position', [100, 100, 1200, 800]);

for w_idx = 1:num_windows
    window_type = window_types{w_idx};
    
    % Create gate
    gate.type = window_type;
    gate.start_time = 5e-9;
    gate.width = 20e-9;
    gate.dt = t(2) - t(1);
    
    % Apply gate
    h_gated = apply_gate(h_time, gate);
    
    % Convert back to frequency domain
    H_gated = time_to_frequency(h_gated, freq, 'Normalization', 'peak');
    
    % Reconstruct pattern
    pattern_recon = reconstruct_pattern(H_gated, theta, ant);
    
    % Compute metrics
    metrics = gate_metrics(pattern_aut, pattern_recon, chan);
    
    results.(window_type) = metrics;
    
    % Plot
    subplot(2, 3, w_idx);
    plot(theta*180/pi, pattern_aut, 'b-', 'LineWidth', 2, 'DisplayName', 'Original');
    hold on;
    plot(theta*180/pi, pattern_recon, 'r--', 'LineWidth', 2, 'DisplayName', 'Gated');
    xlabel('Angle [degrees]');
    ylabel('Pattern (normalized)');
    title(sprintf('%s Window (RMS Error: %.4f)', window_type, metrics.rms_error));
    grid on;
    legend();
end

sgtitle('Gate Window Comparison');

%% Display results
disp('Gate Window Comparison Results:');
disp('================================');
for w_idx = 1:num_windows
    window_type = window_types{w_idx};
    m = results.(window_type);
    fprintf('%12s: RMS Error = %.6f, Peak Error = %.6f, Leakage = %.2f dB\n', ...
        window_type, m.rms_error, m.peak_error, m.leakage_db);
end
