%% RADIATION_PATTERN - Generate antenna radiation pattern
%
% Syntax:
%   pattern = radiation_pattern(theta, antenna_config, varargin)
%
% Description:
%   Generates antenna radiation pattern as a function of angle using
%   specified pattern model (cosine, sinc, Gaussian, etc.).
%
% Input Arguments:
%   theta               - Angle vector [radians]
%   antenna_config      - Antenna configuration structure
%
% Name-Value Arguments:
%   'Frequency'         - Frequency for pattern computation [Hz]
%   'NormalizationMode' - 'peak', 'directivity', 'none' (default: 'peak')
%
% Output Arguments:
%   pattern             - Antenna pattern magnitude (linear)
%
% Example:
%   theta = linspace(0, 2*pi, 360);
%   pattern = radiation_pattern(theta, ant_config);
%
% See also: normalize_pattern, reconstruct_pattern

function pattern = radiation_pattern(theta, antenna_config, varargin)
    
    % Input validation
    validateattributes(theta, {'numeric'}, {'real', 'vector'}, mfilename, 'theta');
    
    theta = theta(:);  % Column vector
    
    % Parse optional arguments
    p = inputParser;
    addParameter(p, 'Frequency', antenna_config.frequency_ref, @isnumeric);
    addParameter(p, 'NormalizationMode', 'peak', @(x) ismember(x, {'peak', 'directivity', 'none'}));
    parse(p, varargin{:});
    
    % Compute pattern based on model
    switch lower(antenna_config.pattern_model)
        case 'cosine'
            % Cosine pattern: |cos(theta/2)|^n
            n = antenna_config.pattern_order;
            pattern = abs(cos(theta/2)).^n;
            
        case 'sinc'
            % Sinc pattern
            u = pi * sin(theta) * antenna_config.horn_aperture_width / 0.3;
            pattern = abs(sinc(u/pi)).^2;
            
        case 'gaussian'
            % Gaussian pattern
            beamwidth_rad = antenna_config.beamwidth_3db * pi/180;
            sigma = beamwidth_rad / (2*sqrt(2*log(2)));
            pattern = exp(-(theta.^2) / (2*sigma^2));
            
        case 'measured'
            % Placeholder for measured pattern
            % In practice, would load from data file
            pattern = antenna_config.pattern_measured;
            
        otherwise
            % Default: cosine pattern
            pattern = abs(cos(theta/2)).^3;
    end
    
    % Add frequency-dependent gain variation
    freq = p.Results.Frequency;
    f_ref = antenna_config.frequency_ref;
    gain_slope = antenna_config.gain_slope_db_per_ghz;
    gain_variation = 10.^((gain_slope * (freq - f_ref) / 1e9) / 20);
    pattern = pattern * gain_variation;
    
    % Add E-plane and H-plane asymmetry
    % Simple model: modulate pattern with asymmetry factor
    asymmetry = antenna_config.e_plane_factor * antenna_config.h_plane_factor;
    pattern = pattern * asymmetry;
    
    % Normalize output
    switch p.Results.NormalizationMode
        case 'peak'
            pattern = pattern / max(pattern);
        case 'directivity'
            % Normalize to directivity integral
            dtheta = theta(2) - theta(1);
            pattern = pattern / sqrt(sum(pattern.^2) * dtheta / (2*pi));
        case 'none'
            % No normalization
    end
    
end
