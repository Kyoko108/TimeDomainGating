%% BUILD_CHANNEL_MATRIX - Construct frequency-domain channel transfer matrix
%
% Syntax:
%   H = build_channel_matrix(freq, direct_path, reflections, varargin)
%   H = build_channel_matrix(freq, direct_path, reflections, antenna_config, channel_config)
%
% Description:
%   Constructs the complex frequency-domain transfer function combining
%   direct path and all reflective paths with appropriate path loss,
%   Fresnel reflection, and propagation delay.
%
% Input Arguments:
%   freq            - Frequency vector [Hz]
%   direct_path     - Structure with direct path information
%   reflections     - Structure array with reflection paths
%   antenna_config  - Antenna configuration structure
%   channel_config  - Channel configuration structure
%
% Output Arguments:
%   H               - Complex frequency-domain transfer function [V/V]
%
% Example:
%   H = build_channel_matrix(freq, direct_path, reflections, ant, chan);
%
% See also: find_direct_path, generate_reflections, synth_multipath_channel

function H = build_channel_matrix(freq, direct_path, reflections, antenna_config, channel_config)
    
    % Input validation
    validateattributes(freq, {'numeric'}, {'real', 'positive', 'vector'}, mfilename, 'freq');
    
    freq = freq(:);  % Ensure column vector
    num_freq = length(freq);
    
    % Physical constant
    c = 3e8;
    
    % Initialize transfer function
    H = zeros(num_freq, 1);
    
    % Add direct path contribution
    if channel_config.los_enabled
        % Compute path loss (Friis equation)
        PL_db = 20 * log10(4*pi*direct_path.distance*freq/c);
        PL_linear = 10.^(PL_db/20);
        
        % Compute phase shift due to propagation delay
        omega = 2*pi*freq;
        phase_shift = exp(-1j * omega * direct_path.delay);
        
        % Combine: amplitude loss and phase shift
        H_direct = (1 ./ PL_linear) .* phase_shift;
        H = H + H_direct;
    end
    
    % Add reflection path contributions
    for refl_idx = 1:length(reflections)
        refl = reflections(refl_idx);
        
        % Friis path loss for reflection
        PL_db = 20 * log10(4*pi*refl.distance*freq/c);
        PL_linear = 10.^(PL_db/20);
        
        % Propagation delay (phase shift)
        omega = 2*pi*freq;
        phase_shift = exp(-1j * omega * refl.delay);
        
        % Fresnel reflection coefficient (simplified - normal incidence assumed)
        % For ground reflections at grazing incidence, use Fresnel for s-pol
        material_params.conductivity = refl.conductivity;
        material_params.relative_permittivity = 1;
        material_params.relative_permeability = 1;
        
        % Grazing incidence angle (approximately 90 degrees for ground reflections)
        theta_grazing = 85 * pi/180;
        
        if isfield(refl, 'order') && refl.order == 1
            % Approximate Fresnel reflection coefficient
            % For good conductors at grazing incidence: |r| ≈ 1
            r_magnitude = 0.95;  % Slight loss factor
            r = r_magnitude * ones(num_freq, 1);
        else
            r = 0.5 * ones(num_freq, 1);  % Default reflection
        end
        
        % Combine: amplitude loss, Fresnel coefficient, and phase shift
        H_refl = (1 ./ PL_linear) .* r .* phase_shift;
        H = H + H_refl;
    end
    
    % Normalize to prevent excessive amplitudes
    H = H / max(abs(H));
    
end
