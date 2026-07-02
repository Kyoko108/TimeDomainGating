%% CHANNEL_CONFIG - Multipath channel configuration parameters
%
% This script defines the multipath propagation environment including
% reflector geometry, materials, reflection coefficients, and multipath setup.
%
% Usage:
%   run('config/channel_config.m')
%   % All parameters stored in 'chan' structure
%
% Output:
%   chan - Structure containing channel configuration parameters
%
% See also: simulation_config, antenna_config

%% Basic Channel Parameters
chan.type = 'multipath';        % Channel type: 'free_space', 'multipath', 'urban'
chan.description = 'Multipath propagation with reflective surfaces';

%% Line-of-Sight (Direct Path) Configuration
chan.los_enabled = true;        % Enable line-of-sight path
chan.los_distance = 10;         % LOS path distance [m]
chan.los_attenuation_db = 0;    % LOS attenuation [dB]
chan.los_phase_offset = 0;      % LOS phase offset [radians]

%% Reflector Configuration
chan.num_reflectors = 2;        % Number of reflector surfaces
chan.reflector_type = 'ground';  % 'ground', 'wall', 'ceiling', 'arbitrary'

%% Reflector 1: Ground Plane (Primary)
chan.refl(1).type = 'ground_plane';
chan.refl(1).material = 'perfect_conductor';  % 'perfect_conductor', 'copper', 'aluminum', 'dielectric'
chan.refl(1).conductivity = inf;  % Conductivity [S/m]
chan.refl(1).relative_permittivity = 1;
chan.refl(1).relative_permeability = 1;
chan.refl(1).distance = 10;     % Distance to reflector [m]
chan.refl(1).height = 0;        % Height of reflector [m]
chan.refl(1).area = 100;        % Reflective area [m^2]
chan.refl(1).angle_to_los = 180; % Angle with respect to LOS [degrees]
chan.refl(1).roughness = 'smooth'; % 'smooth', 'rough'
chan.refl(1).enabled = true;    % Enable this reflector

%% Reflector 2: Secondary Wall
chan.refl(2).type = 'wall';
chan.refl(2).material = 'aluminum';
chan.refl(2).conductivity = 3.5e7;  % Aluminum conductivity [S/m]
chan.refl(2).relative_permittivity = 1;
chan.refl(2).relative_permeability = 1;
chan.refl(2).distance = 15;     % Distance to reflector [m]
chan.refl(2).height = 5;        % Height of reflector [m]
chan.refl(2).area = 50;         % Reflective area [m^2]
chan.refl(2).angle_to_los = 90; % Angle with respect to LOS [degrees]
chan.refl(2).roughness = 'smooth';
chan.refl(2).enabled = true;    % Enable this reflector

%% Reflection Coefficient Configuration
chan.fresnel_enabled = true;    % Enable frequency-dependent Fresnel coefficients
chan.polarization_mode = 'vertical'; % 'horizontal', 'vertical', 'mixed'
chan.angle_of_incidence_mode = 'compute'; % 'compute', 'grazing', 'normal'

%% Multipath Propagation Paths Configuration
chan.max_reflection_order = 2;  % Maximum reflection order (1=single bounce, 2=double bounce, etc.)
chan.include_higher_order = false; % Include higher order reflections

%% Path Loss Configuration
chan.pathloss_model = 'friis';  % 'friis', 'log-distance', 'close-in'
chan.friis_reference_distance = 1; % Reference distance for Friis model [m]
chan.path_loss_exponent = 2;    % Path loss exponent for log-distance model

%% Propagation Effects
chan.include_doppler = false;   % Include Doppler effects (for moving objects)
chan.include_scattering = false; % Include scattered multipath
chan.include_diffraction = false; % Include diffraction effects
chan.include_atmospheric_absorption = false; % Include atmospheric absorption

%% Shadowing and Blockage
chan.shadowing_enabled = false; % Random shadowing (log-normal)
chan.shadowing_std = 6;         % Shadowing standard deviation [dB]
chan.blockage_loss = 0;         % Blockage loss if LOS is blocked [dB]

%% Delay Spread and Coherence Bandwidth
chan.rms_delay_spread_target = 10e-9; % Target RMS delay spread [s]
chan.coherence_bandwidth = 1/(5*chan.rms_delay_spread_target); % Coherence bandwidth [Hz]

%% Antenna Coupling Effects
chan.coupling_loss_db = -30;    % Antenna-to-antenna coupling loss [dB]
chan.isolation_db = -40;        % TX-RX isolation [dB]

%% Frequency Dependent Attenuation
chan.attenuation_model = 'frequency_independent'; % 'frequency_independent', 'frequency_dependent'
chan.attenuation_slope_db_per_ghz = 0; % Attenuation increase with frequency

%% Temperature and Environmental Effects
chan.temperature = 25;          % Environmental temperature [C]
chan.humidity_percent = 50;     % Relative humidity [%]
chan.pressure_pa = 101325;      % Atmospheric pressure [Pa]

%% Time-domain gating parameters
chan.gate_width_min = 0.5e-9;    % Minimum gate width [s]
chan.gate_width_max = 10e-9;     % Maximum gate width [s]

%% Validation Checks
assert(chan.los_distance > 0, 'LOS distance must be positive');
assert(chan.num_reflectors >= 0, 'Number of reflectors must be non-negative');
assert(chan.max_reflection_order >= 1, 'Max reflection order must be at least 1');

disp('Channel configuration loaded successfully.');
disp(sprintf('  Channel type: %s', chan.type));
disp(sprintf('  LOS distance: %.2f m', chan.los_distance));
disp(sprintf('  Number of reflectors: %d', chan.num_reflectors));
disp(sprintf('  Maximum reflection order: %d', chan.max_reflection_order));
disp(sprintf('  Fresnel coefficients: %s', onoff(chan.fresnel_enabled)));

