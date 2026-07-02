%% MAIN - Main TimeDomainGating simulation script
%
% This is the entry point for the TimeDomainGating framework.
% Runs a complete simulation of antenna measurement with time-domain gating.
%
% Output:
%   - Console output with simulation results
%   - Saved figures in results/figures/
%   - Saved data in results/data/
%
% See also: config/simulation_config, config/antenna_config, config/channel_config

%% Clear workspace and close figures
clear; close all; clc;

cd(fileparts(mfilename('fullpath')));

% Add all project folders to the MATLAB/Octave path
addpath(genpath(pwd));
rehash;

%% Print header
fprintf('\n');
fprintf('========================================\n');
fprintf('  TimeDomainGating Simulation Framework\n');
fprintf('========================================\n');
fprintf('\n');

%% Load configuration files
fprintf('Loading configuration files...\n');
run('config/simulation_config.m');
run('config/antenna_config.m');
run('config/channel_config.m');
fprintf('Configuration loaded successfully.\n\n');

%% Create output directories
if cfg.save_results
    if ~exist(cfg.figures_dir, 'dir')
        mkdir(cfg.figures_dir);
    end
    if ~exist(cfg.data_dir, 'dir')
        mkdir(cfg.data_dir);
    end
    if ~exist(cfg.logs_dir, 'dir')
        mkdir(cfg.logs_dir);
    end
    fprintf('Output directories created.\n\n');
end

%% Generate antenna pattern
fprintf('Generating antenna radiation pattern...\n');
pattern_aut = radiation_pattern(cfg.theta, ant, 'Frequency', ant.frequency_ref);
fprintf('Pattern generated: %d angle points\n\n', length(cfg.theta));

%% Generate multipath channel
fprintf('Synthesizing multipath propagation channel...\n');
[H_multipath, paths_info] = synth_multipath_channel(cfg.freq, pattern_aut, cfg.theta, chan);
fprintf('Channel generated with %d paths\n\n', length(paths_info));

%% Add noise
fprintf('Adding AWGN (SNR = %.1f dB)...\n', cfg.snr_db);
H_noisy = add_awgn(H_multipath, cfg.snr_db);
snr_measured = snr_estimator(H_noisy, H_multipath);
fprintf('Noise added. Measured SNR: %.1f dB\n\n', snr_measured);

%% Convert to time domain
fprintf('Converting to time domain with zero-padding...\n');
[h_time, t] = freq_to_time_gate(H_noisy, cfg.freq, 'ZeroPadFactor', cfg.zero_pad_factor);
fprintf('Time-domain impulse response computed.\n');
fprintf('  Time samples: %d\n', length(t));
fprintf('  Time range: 0 - %.2f ns\n\n', max(t)*1e9);

%% Analyze impulse response
fprintf('Analyzing impulse response characteristics...\n');
h_info = impulse_response(h_time, t);
fprintf('  Peak magnitude: %.4f\n', h_info.peak_magnitude);
fprintf('  Peak time: %.2f ns\n', h_info.peak_time*1e9);
fprintf('  Signal duration: %.2f ns\n', h_info.duration*1e9);
fprintf('  Number of detected paths: %d\n\n', h_info.num_paths);

%% Optimize gate parameters
fprintf('Optimizing gate parameters...\n');
[gate_opt, opt_metrics] = optimize_gate(h_time, cfg.freq, chan, ...
    'SearchMethod', 'grid', 'NumPoints', 30, 'WindowType', cfg.gate_type);
fprintf('Gate optimization complete.\n');
fprintf('  Optimal window type: %s\n', gate_opt.type);
fprintf('  Optimal start time: %.2f ns\n', gate_opt.start_time*1e9);
fprintf('  Optimal width: %.2f ns\n', gate_opt.width*1e9);
fprintf('  Gate efficiency: %.1f%%\n\n', opt_metrics.gate_efficiency*100);

%% Apply optimized gate
fprintf('Applying time-domain gate...\n');
h_gated = apply_gate(h_time, gate_opt);
H_gated = time_to_frequency(h_gated, cfg.freq, 'Normalization', 'peak');
fprintf('Gate applied and signal converted back to frequency domain.\n\n');

%% Reconstruct antenna pattern from gated measurements
fprintf('Reconstructing antenna pattern from gated measurements...\n');
pattern_reconstructed = reconstruct_pattern(H_gated, cfg.theta, ant);
fprintf('Pattern reconstruction complete.\n\n');

%% Compute performance metrics
fprintf('Computing performance metrics...\n');


fprintf('\n===== Pattern Diagnostics =====\n');

fprintf('Original: min=%g max=%g anyNaN=%d\n', ...
    min(pattern_aut), max(pattern_aut), any(isnan(pattern_aut)));

fprintf('Reconstructed: min=%g max=%g anyNaN=%d\n', ...
    min(pattern_reconstructed), max(pattern_reconstructed), any(isnan(pattern_reconstructed)));

metrics = gate_metrics(pattern_aut, pattern_reconstructed, chan);

fprintf('Gating Performance Metrics:\n');
%metrics = gate_metrics(pattern_aut, pattern_reconstructed, chan);
%fprintf('Gating Performance Metrics:\n');
fprintf('  RMS error: %.6f (%.2f dB)\n', metrics.rms_error, metrics.rms_error_db);
fprintf('  Peak error: %.6f (%.2f dB)\n', metrics.peak_error, metrics.peak_error_db);
fprintf('  Correlation: %.4f\n', metrics.correlation);
fprintf('  Main lobe energy: %.1f%%\n', metrics.main_lobe_energy*100);
fprintf('  Leakage: %.2f dB\n\n', metrics.leakage_db);

%% Generate plots
if cfg.plot_enabled
    fprintf('Generating plots...\n');

    % Pattern comparison plot
    %figure('Position', [100, 100, 1200, 600]);
    plot_pattern_comparison(cfg.theta, pattern_aut, pattern_reconstructed, ...
        'Title', 'Antenna Pattern: Original vs Gated Reconstruction');
    if cfg.save_results
        saveas(gcf, fullfile(cfg.figures_dir, 'pattern_comparison.png'));
    end

    % Impulse response plot
    %figure('Position', [100, 100, 1200, 600]);
    plot_impulse_response(t, h_time, h_gated, ...
        'GateInfo', gate_opt, 'Title', 'Time-Domain Impulse Response');
    if cfg.save_results
        saveas(gcf, fullfile(cfg.figures_dir, 'impulse_response.png'));
    end

    % Gate window plot
    %figure('Position', [100, 100, 1000, 600]);
    plot_gate_window(gate_opt, t);
    if cfg.save_results
        saveas(gcf, fullfile(cfg.figures_dir, 'gate_window.png'));
    end

    fprintf('Plots generated and saved.\n\n');
end

%% Save results
if cfg.save_results
    fprintf('Saving results to disk...\n');

    % Save data
    results_data.freq = cfg.freq;
    results_data.theta = cfg.theta;
    results_data.pattern_original = pattern_aut;
    results_data.pattern_reconstructed = pattern_reconstructed;
    results_data.H_multipath = H_multipath;
    results_data.H_gated = H_gated;
    results_data.h_time = h_time;
    results_data.h_gated = h_gated;
    results_data.t = t;
    results_data.gate_opt = gate_opt;
    results_data.metrics = metrics;

    save(fullfile(cfg.data_dir, 'simulation_results.mat'), 'results_data');
    fprintf('Data saved to: %s\n', fullfile(cfg.data_dir, 'simulation_results.mat'));
end

%% Print summary
fprintf('\n');
fprintf('========================================\n');
fprintf('  Simulation Complete!\n');
fprintf('========================================\n');
fprintf('\n');

fprintf('Summary:\n');
fprintf('  Frequency range: %.1f - %.1f GHz\n', cfg.f_min/1e9, cfg.f_max/1e9);
fprintf('  Antenna: %s\n', ant.name);
fprintf('  Channel: %s\n', chan.description);
fprintf('  SNR: %.1f dB\n', cfg.snr_db);
fprintf('  Gate type: %s\n', gate_opt.type);
fprintf('  RMS pattern error: %.6f\n', metrics.rms_error);
fprintf('  Main lobe energy: %.1f%%\n', metrics.main_lobe_energy*100);
fprintf('\n');
disp(get(0,'Children'))

if cfg.save_results
    fprintf('Results saved to: %s\n', cfg.results_dir);
end

fprintf('\n');
