%% ANTENNA_CONFIG - Antenna configuration parameters
%
% This script defines antenna characteristics including type, dimensions,
% gain, directivity, and pattern generation parameters.
%
% Usage:
%   run('config/antenna_config.m')
%   % All parameters stored in 'ant' structure
%
% Output:
%   ant - Structure containing antenna configuration parameters
%
% See also: simulation_config, channel_config

%% Antenna Type and Basic Parameters
ant.type = 'horn';              % Antenna type: 'horn', 'dipole', 'array'
ant.name = 'Standard Horn Antenna';  % Antenna name/description
ant.frequency_ref = 10e9;       % Reference frequency [Hz]

%% Horn Antenna Specific Parameters
ant.horn_length = 0.15;         % Horn length [m]
ant.horn_aperture_width = 0.05; % Aperture width [m]
ant.horn_aperture_height = 0.03; % Aperture height [m]
ant.horn_flare_angle = 15;      % Flare angle [degrees]

%% Antenna Gain and Directivity
ant.gain_ref = 15;              % Gain at reference frequency [dBi]
ant.gain_vs_freq = 'linear';    % Gain variation: 'constant', 'linear', 'quadratic'
ant.directivity = 12;           % Directivity [dB]

%% Polarization
ant.polarization = 'vertical';  % 'vertical', 'horizontal', 'circular'
ant.axial_ratio = 1.0;          % Axial ratio (1.0 for linear polarization)

%% Beamwidth and Sidelobe Parameters
ant.beamwidth_3db = 20;         % 3dB beamwidth [degrees]
ant.sidelobe_level = -20;       % Sidelobe level [dB]
ant.beamwidth_vs_freq = 'inverse';  % Beamwidth scaling: 'constant', 'inverse'

%% Pattern Asymmetry (E-plane vs H-plane)
ant.e_plane_factor = 1.0;       % E-plane pattern scaling factor
ant.h_plane_factor = 0.95;      % H-plane pattern scaling factor
ant.cross_pol_isolation = 25;   % Cross-polarization isolation [dB]

%% Radiation Pattern Models
ant.pattern_model = 'cosine';   % Pattern model: 'cosine', 'sinc', 'gaussian', 'measured'
ant.pattern_order = 3;          % Order of pattern function

%% Frequency Dependent Behavior
ant.gain_slope_db_per_ghz = 0.5; % Gain variation with frequency
ant.phase_shift_per_ghz = 0;    % Phase shift with frequency [degrees/GHz]

%% Input/Output Configuration
ant.impedance = 50;             % Characteristic impedance [Ohms]
ant.port_type = 'waveguide';    % 'coax', 'waveguide', 'stripline'
ant.matching_network = true;    % Matched to 50 Ohms
ant.insertion_loss = 0.5;       % Cable/connector loss [dB]

%% Environmental Effects
ant.radome_material = 'none';   % 'none', 'foam', 'dielectric'
ant.radome_thickness = 0;       % Radome thickness [m]
ant.radome_loss = 0;            % Radome loss [dB]

%% Pattern Measurement Parameters
ant.measurement_distance = 10;  % Measurement distance [m]
ant.near_field_distance = 0;    % Near-field distance [m]
ant.pattern_resolution = 1;     % Angular resolution [degrees]
ant.pattern_symmetry = 'symmetric'; % 'symmetric', 'asymmetric'

%% Temperature and Environmental
ant.operating_temp_min = -40;   % Minimum operating temperature [C]
ant.operating_temp_max = 85;    % Maximum operating temperature [C]
ant.nominal_temp = 25;          % Nominal temperature for specs [C]

%% Validation
assert(ant.frequency_ref > 0, 'Reference frequency must be positive');
assert(ant.gain_ref > -50 && ant.gain_ref < 50, 'Gain must be reasonable');
assert(ant.impedance > 0, 'Impedance must be positive');
assert(ant.horn_aperture_width > 0, 'Horn aperture width must be positive');
assert(abs(ant.axial_ratio) > 0, 'Axial ratio must be non-zero');

disp('Antenna configuration loaded successfully.');
disp(sprintf('  Antenna type: %s', ant.type));
disp(sprintf('  Antenna: %s', ant.name));
disp(sprintf('  Reference gain: %.2f dBi at %.2f GHz', ant.gain_ref, ant.frequency_ref/1e9));
disp(sprintf('  3dB beamwidth: %.2f degrees', ant.beamwidth_3db));
disp(sprintf('  Sidelobe level: %.2f dB', ant.sidelobe_level));
