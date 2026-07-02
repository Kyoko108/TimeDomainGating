%% FIND_DIRECT_PATH - Identify direct path from transmitter to receiver
%
% Syntax:
%   direct_path = find_direct_path(tx_pos, rx_pos, varargin)
%   [direct_path, distance, angle] = find_direct_path(tx_pos, rx_pos, varargin)
%
% Description:
%   Computes the direct (LOS) path geometry between transmitter and receiver.
%   Returns distance, angle of arrival, and path properties.
%
% Input Arguments:
%   tx_pos      - Transmitter position [x, y, z] in meters
%   rx_pos      - Receiver position [x, y, z] in meters
%
% Name-Value Arguments:
%   'Attenuation' - Additional path attenuation [dB] (default: 0)
%   'PhaseOffset' - Phase offset [radians] (default: 0)
%
% Output Arguments:
%   direct_path - Structure with path properties
%   distance    - Path distance [m]
%   angle       - Angle of arrival [radians]
%
% Example:
%   tx_pos = [0, 0, 5];
%   rx_pos = [10, 0, 2];
%   direct_path = find_direct_path(tx_pos, rx_pos);
%
% See also: generate_reflections, synth_multipath_channel

function [direct_path, distance, angle] = find_direct_path(tx_pos, rx_pos, varargin)
    
    % Input validation
    validateattributes(tx_pos, {'numeric'}, {'real', 'size', [1, 3]}, mfilename, 'tx_pos');
    validateattributes(rx_pos, {'numeric'}, {'real', 'size', [1, 3]}, mfilename, 'rx_pos');
    
    % Parse optional arguments
    p = inputParser;
    addParameter(p, 'Attenuation', 0, @isnumeric);
    addParameter(p, 'PhaseOffset', 0, @isnumeric);
    parse(p, varargin{:});
    
    % Calculate vector from TX to RX
    path_vector = rx_pos - tx_pos;
    
    % Calculate distance
    distance = norm(path_vector);
    
    % Calculate angle of arrival (elevation and azimuth)
    % Elevation angle from horizontal plane
    elevation = asin(path_vector(3) / distance);
    % Azimuth angle in horizontal plane
    azimuth = atan2(path_vector(2), path_vector(1));
    angle = elevation;  % Return elevation as primary angle
    
    % Create output structure
    direct_path.type = 'direct';
    direct_path.distance = distance;
    direct_path.delay = distance / 3e8;  % Propagation delay [s]
    direct_path.attenuation_db = p.Results.Attenuation;
    direct_path.phase_offset = p.Results.PhaseOffset;
    direct_path.elevation_rad = elevation;
    direct_path.azimuth_rad = azimuth;
    direct_path.vector = path_vector;
    
end
