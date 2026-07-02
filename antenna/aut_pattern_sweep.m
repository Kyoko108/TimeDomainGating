%% AUT_PATTERN_SWEEP - Sweep antenna under test over all measurement angles
%
% Syntax:
%   [pattern, theta_meas] = aut_pattern_sweep(antenna_config, varargin)
%
% Description:
%   Simulates measurement of antenna under test (AUT) pattern by sweeping
%   over angle range and measuring pattern at each angle.
%
% Input Arguments:
%   antenna_config      - Antenna configuration structure
%
% Name-Value Arguments:
%   'AngleStart'        - Start angle [degrees] (default: 0)
%   'AngleStop'         - Stop angle [degrees] (default: 360)
%   'NumAngles'         - Number of angle points (default: 360)
%
% Output Arguments:
%   pattern             - Antenna pattern at each angle
%   theta_meas          - Measurement angles [radians]
%
% See also: radiation_pattern, normalize_pattern

function [pattern, theta_meas] = aut_pattern_sweep(antenna_config, varargin)
    
    % Parse optional arguments
    p = inputParser;
    addParameter(p, 'AngleStart', 0, @isnumeric);
    addParameter(p, 'AngleStop', 360, @isnumeric);
    addParameter(p, 'NumAngles', 360, @isnumeric);
    parse(p, varargin{:});
    
    % Create angle vector
    theta_deg = linspace(p.Results.AngleStart, p.Results.AngleStop, p.Results.NumAngles);
    theta_meas = theta_deg(:) * pi/180;  % Convert to radians
    
    % Generate pattern at each angle
    pattern = radiation_pattern(theta_meas, antenna_config, ...
        'Frequency', antenna_config.frequency_ref, ...
        'NormalizationMode', 'peak');
    
end
