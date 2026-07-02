%% FRESNEL_REFLECTION - Calculate frequency-dependent Fresnel reflection coefficient
%
% Syntax:
%   r = fresnel_reflection(freq, theta_i, material_params)
%   r = fresnel_reflection(freq, theta_i, material_params, Name, Value)
%
% Description:
%   Computes frequency-dependent Fresnel reflection coefficients for
%   electromagnetic waves incident on a surface.
%
%   Fresnel equations for parallel (p) and perpendicular (s) polarization:
%   r_p = (n2*cos(theta_i) - n1*cos(theta_t)) / (n2*cos(theta_i) + n1*cos(theta_t))
%   r_s = (n1*cos(theta_i) - n2*cos(theta_t)) / (n1*cos(theta_i) + n2*cos(theta_t))
%
% Input Arguments:
%   freq            - Frequency or frequency vector [Hz]
%   theta_i         - Angle of incidence [radians]
%   material_params - Structure with material properties:
%       .conductivity          - Material conductivity [S/m]
%       .relative_permittivity - Relative permittivity (default: 1)
%       .relative_permeability - Relative permeability (default: 1)
%
% Name-Value Arguments:
%   'Polarization'  - 'vertical' or 'horizontal' (default: 'vertical')
%   'Medium'        - 'vacuum', 'air', or 'custom' (default: 'air')
%
% Output Arguments:
%   r               - Reflection coefficient (complex, magnitude typically <= 1)
%
% Example:
%   freq = 10e9;
%   theta_i = 45 * pi/180;  % 45 degrees
%   material.conductivity = 5.96e7;  % Copper
%   material.relative_permittivity = 1;
%   r = fresnel_reflection(freq, theta_i, material);
%
% See also: friis_path_loss, propagation_delay

function r = fresnel_reflection(freq, theta_i, material_params, varargin)
    
    % Input validation
    validateattributes(freq, {'numeric'}, {'real', 'positive'}, mfilename, 'freq');
    validateattributes(theta_i, {'numeric'}, {'real', '>=', 0, '<=', pi/2}, mfilename, 'theta_i');
    
    % Parse optional arguments
    p = inputParser;
    addParameter(p, 'Polarization', 'vertical', @(x) ismember(x, {'vertical', 'horizontal', 'p', 's'}));
    addParameter(p, 'Medium', 'air', @(x) ismember(x, {'vacuum', 'air', 'custom'}));
    parse(p, varargin{:});
    
    % Physical constants
    c = 3e8;          % Speed of light [m/s]
    mu_0 = 4*pi*1e-7; % Permeability of free space [H/m]
    eps_0 = 8.854e-12; % Permittivity of free space [F/m]
    
    % Medium parameters
    if strcmp(p.Results.Medium, 'air')
        eps_r_incident = 1.0;
        mu_r_incident = 1.0;
    else
        eps_r_incident = 1.0;  % Assume air as incident medium
        mu_r_incident = 1.0;
    end
    
    % Material parameters
    sigma = material_params.conductivity;
    eps_r = material_params.relative_permittivity;
    mu_r = material_params.relative_permeability;
    
    % Compute complex permittivity for conductor
    % eps_c = eps_r - j*sigma/(omega*eps_0)
    omega = 2*pi*freq(:);
    eps_c = eps_r - 1j * sigma ./ (omega * eps_0);
    
    % Refractive indices
    n1 = sqrt(mu_r_incident * eps_r_incident);
    n2 = sqrt(mu_r * eps_c);
    
    % Angle of transmission using Snell's law
    sin_theta_t = (n1/n2) * sin(theta_i);
    theta_t = asin(sin_theta_t);
    
    % Fresnel reflection coefficient
    if strcmp(p.Results.Polarization, 'vertical') || strcmp(p.Results.Polarization, 'p')
        % Parallel polarization (p-wave)
        numerator = n2 * cos(theta_i) - n1 * cos(theta_t);
        denominator = n2 * cos(theta_i) + n1 * cos(theta_t);
    else
        % Perpendicular polarization (s-wave)
        numerator = n1 * cos(theta_i) - n2 * cos(theta_t);
        denominator = n1 * cos(theta_i) + n2 * cos(theta_t);
    end
    
    r = numerator ./ denominator;
    
    % Ensure magnitude <= 1 for physical validity
    mag_r = abs(r);
    if any(mag_r > 1.0001)  % Small tolerance for numerical errors
        warning('Fresnel reflection magnitude exceeds 1 (mag = %.4f)', max(mag_r));
    end
    
end
