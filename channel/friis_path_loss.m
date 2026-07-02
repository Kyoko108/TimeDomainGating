%% FRIIS_PATH_LOSS - Calculate free-space path loss using Friis equation
%
% Syntax:
%   PL_db = friis_path_loss(freq, distance, varargin)
%   [PL_db, PL_linear] = friis_path_loss(freq, distance, varargin)
%
% Description:
%   Computes free-space path loss using the Friis transmission equation.
%   Path loss is expressed in both dB and linear scale.
%
%   Friis equation: PL = (4*pi*d/lambda)^2
%
% Input Arguments:
%   freq        - Frequency or frequency vector [Hz]
%   distance    - Distance or distance vector [m]
%
% Name-Value Arguments:
%   'Gain_tx'   - Transmit antenna gain [dBi] (default: 0)
%   'Gain_rx'   - Receive antenna gain [dBi] (default: 0)
%   'Losses'    - Additional losses [dB] (default: 0)
%
% Output Arguments:
%   PL_db       - Path loss [dB]
%   PL_linear   - Path loss [linear scale]
%
% Example:
%   freq = 10e9;  % 10 GHz
%   distance = 10;  % 10 meters
%   PL_db = friis_path_loss(freq, distance);
%
% See also: fresnel_reflection, propagation_delay

function [PL_db, PL_linear] = friis_path_loss(freq, distance, varargin)
    
    % Input validation
    validateattributes(freq, {'numeric'}, {'real', 'positive'}, mfilename, 'freq');
    validateattributes(distance, {'numeric'}, {'real', 'positive'}, mfilename, 'distance');
    
    % Parse optional arguments
    p = inputParser;
    addParameter(p, 'Gain_tx', 0, @isnumeric);
    addParameter(p, 'Gain_rx', 0, @isnumeric);
    addParameter(p, 'Losses', 0, @isnumeric);
    parse(p, varargin{:});
    
    % Constants
    c = 3e8;  % Speed of light [m/s]
    
    % Broadcast arrays for vectorized computation
    freq = freq(:);
    distance = distance(:);
    
    if length(freq) > 1 && length(distance) > 1
        if length(freq) ~= length(distance)
            error('freq and distance must have same length or one must be scalar');
        end
    end
    
    % Calculate wavelength
    wavelength = c ./ freq;
    
    % Friis path loss: (4*pi*d/lambda)^2
    % In dB: 20*log10(4*pi*d/lambda)
    friis_term = (4 * pi * distance ./ wavelength);
    PL_linear = friis_term.^2;
    PL_db = 20 * log10(friis_term);
    
    % Add antenna gains and losses
    PL_db = PL_db - p.Results.Gain_tx - p.Results.Gain_rx + p.Results.Losses;
    
end
