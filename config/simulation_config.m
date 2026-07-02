%% SIMULATION_CONFIG - Configuration parameters for TimeDomainGating simulation
%
% This script defines all simulation parameters including frequency sweep,
% time-domain resolution, zero-padding, and general simulation settings.
%
% Usage:
%   run('config/simulation_config.m')
%   % All parameters stored in 'cfg' structure
%
% Output:
%   cfg - Structure containing all simulation configuration parameters
%
% See also: antenna_config, channel_config

%% Frequency Sweep Configuration
cfg.f_min = 8e9;              % Minimum frequency [Hz]
cfg.f_max = 12e9;             % Maximum frequency [Hz]
cfg.num_freq = 401;            % Number of frequency points
cfg.freq = linspace(cfg.f_min, cfg.f_max, cfg.num_freq);

%% Time Domain Configuration
cfg.c = 3e8;                   % Speed of light [m/s]
cfg.wavelength = cfg.c ./ cfg.freq;  % Wavelength at each frequency
cfg.bw = cfg.f_max - cfg.f_min; % Bandwidth [Hz]

%% Time-Domain Resolution and Zero-Padding
% Time resolution (Rayleigh resolution) from bandwidth
cfg.time_res = 1 / cfg.bw;      % [seconds] - fundamental time resolution
cfg.zero_pad_factor = 4;        % Zero-padding factor for improved resolution
cfg.fft_length = cfg.zero_pad_factor * cfg.num_freq;  % FFT length with zero-padding

% Time vector
cfg.dt = 1 / (cfg.bw * cfg.zero_pad_factor);  % Time sample spacing [s]
cfg.t_max = cfg.fft_length * cfg.dt;  % Maximum time
cfg.t = (0:cfg.fft_length-1) * cfg.dt;  % Time vector [s]

%% Gate Configuration Defaults
cfg.gate_type = 'hann';         % Default gate window type
cfg.gate_width_min = 1e-9;      % Minimum gate width [s]
cfg.gate_width_max = 100e-9;    % Maximum gate width [s]
cfg.gate_search_points = 50;    % Number of points in gate width search

%% SNR and Noise Configuration
cfg.snr_db = 40;               % Signal-to-noise ratio [dB]
cfg.noise_type = 'awgn';       % Type of noise: 'awgn', 'none'

%% Pattern Configuration Defaults
cfg.num_angles = 360;           % Number of angle points for pattern sweep
cfg.theta = linspace(0, 2*pi, cfg.num_angles); % Angle vector [rad]

%% Numerical Precision
cfg.phase_wrap_threshold = 1e-10; % Threshold for phase unwrapping
cfg.magnitude_floor = 1e-12;    % Minimum magnitude for numerical stability

%% Output Configuration
cfg.save_results = true;        % Save results to disk
cfg.results_dir = 'results';    % Results directory
cfg.figures_dir = fullfile(cfg.results_dir, 'figures');
cfg.data_dir = fullfile(cfg.results_dir, 'data');
cfg.logs_dir = fullfile(cfg.results_dir, 'logs');

%% Plotting Configuration
cfg.plot_enabled = true;        % Enable plotting
cfg.plot_format = {'png', 'pdf'}; % Export formats
cfg.plot_dpi = 300;             % DPI for PNG export
cfg.plot_font_size = 12;        % Font size for plots
cfg.plot_line_width = 1.5;      % Line width for plots

%% Validation
assert(cfg.f_min > 0, 'Minimum frequency must be positive');
assert(cfg.f_max > cfg.f_min, 'Maximum frequency must be greater than minimum');
assert(cfg.num_freq >= 3, 'Number of frequency points must be at least 3');
assert(cfg.zero_pad_factor >= 1, 'Zero-padding factor must be at least 1');
assert(cfg.snr_db >= 0, 'SNR must be non-negative');

disp('Simulation configuration loaded successfully.');
disp(sprintf('  Frequency range: %.2f - %.2f GHz', cfg.f_min/1e9, cfg.f_max/1e9));
disp(sprintf('  Number of frequency points: %d', cfg.num_freq));
disp(sprintf('  Time resolution: %.2f ns', cfg.time_res*1e9));
disp(sprintf('  FFT length (with zero-padding): %d', cfg.fft_length));
disp(sprintf('  SNR: %.2f dB', cfg.snr_db));
