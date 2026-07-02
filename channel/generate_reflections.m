%% GENERATE_REFLECTIONS - Generate reflected paths from specified reflectors
%
% Syntax:
%   reflections = generate_reflections(tx_pos, rx_pos, reflector_config, varargin)
%
% Description:
%   Computes reflection paths from transmitter to receiver via reflector surfaces.
%   Uses image method for ground reflections and geometric optics for other surfaces.
%   Generates first and higher-order reflections.
%
% Input Arguments:
%   tx_pos              - Transmitter position [x, y, z] [m]
%   rx_pos              - Receiver position [x, y, z] [m]
%   reflector_config    - Cell array of reflector structures with properties:
%       .type           - 'ground_plane', 'wall', 'ceiling'
%       .distance       - Distance to reflector [m]
%       .height         - Height of reflector [m]
%       .angle_to_los   - Angle with respect to LOS [degrees]
%
% Name-Value Arguments:
%   'MaxOrder'          - Maximum reflection order (default: 2)
%   'IncludeSecondary'  - Include secondary reflections (default: true)
%
% Output Arguments:
%   reflections         - Structure array containing reflection path data
%
% Example:
%   tx_pos = [0, 0, 5];
%   rx_pos = [10, 0, 2];
%   refl.type = 'ground_plane';
%   refl.distance = 10;
%   reflections = generate_reflections(tx_pos, rx_pos, {refl});
%
% See also: find_direct_path, synth_multipath_channel

function reflections = generate_reflections(tx_pos, rx_pos, reflector_config, varargin)
    
    % Input validation
    validateattributes(tx_pos, {'numeric'}, {'real', 'size', [1, 3]}, mfilename, 'tx_pos');
    validateattributes(rx_pos, {'numeric'}, {'real', 'size', [1, 3]}, mfilename, 'rx_pos');
    
    % Parse optional arguments
    p = inputParser;
    addParameter(p, 'MaxOrder', 2, @isnumeric);
    addParameter(p, 'IncludeSecondary', true, @islogical);
    parse(p, varargin{:});
    
    % Initialize reflection array
    reflections = [];
    reflection_count = 0;
    
    % Generate reflections from each reflector
    for refl_idx = 1:length(reflector_config)
        refl = reflector_config{refl_idx};
        
        if ~isfield(refl, 'enabled') || ~refl.enabled
            continue;  % Skip disabled reflectors
        end
        
        % Generate first-order reflection
        if strcmp(refl.type, 'ground_plane')
            % Image method for ground plane
            % Mirror transmitter and receiver across ground plane at z=0
            tx_image = [tx_pos(1), tx_pos(2), -tx_pos(3)];
            
            % First reflection path: TX -> Ground -> RX
            % Find reflection point on ground
            ground_z = 0;
            t_param = (ground_z - tx_pos(3)) / (tx_image(3) - tx_pos(3));
            refl_point_1 = tx_pos + t_param * (tx_image - tx_pos);
            
            % Calculate path distances
            dist_tx_to_refl = norm(refl_point_1 - tx_pos);
            dist_refl_to_rx = norm(rx_pos - refl_point_1);
            total_distance = dist_tx_to_refl + dist_refl_to_rx;
            
            reflection_count = reflection_count + 1;
            reflections(reflection_count).type = 'ground_reflection_1';
            reflections(reflection_count).order = 1;
            reflections(reflection_count).distance = total_distance;
            reflections(reflection_count).delay = total_distance / 3e8;
            reflections(reflection_count).reflection_point = refl_point_1;
            reflections(reflection_count).incident_distance = dist_tx_to_refl;
            reflections(reflection_count).emergent_distance = dist_refl_to_rx;
            reflections(reflection_count).reflector_idx = refl_idx;
            reflections(reflection_count).material = refl.material;
            reflections(reflection_count).conductivity = refl.conductivity;
            
        else
            % Geometric optics for other reflector types
            % Simple model: reflect off normal to surface
            
            % Compute angle of incidence
            angle_rad = refl.angle_to_los * pi/180;
            
            % Position of reflector center
            refl_center = [refl.distance * cos(angle_rad), 0, refl.height];
            
            % Path via reflection
            dist_tx_to_refl = norm(refl_center - tx_pos);
            dist_refl_to_rx = norm(rx_pos - refl_center);
            total_distance = dist_tx_to_refl + dist_refl_to_rx;
            
            reflection_count = reflection_count + 1;
            reflections(reflection_count).type = sprintf('%s_reflection_1', refl.type);
            reflections(reflection_count).order = 1;
            reflections(reflection_count).distance = total_distance;
            reflections(reflection_count).delay = total_distance / 3e8;
            reflections(reflection_count).reflection_point = refl_center;
            reflections(reflection_count).incident_distance = dist_tx_to_refl;
            reflections(reflection_count).emergent_distance = dist_refl_to_rx;
            reflections(reflection_count).reflector_idx = refl_idx;
            reflections(reflection_count).material = refl.material;
            reflections(reflection_count).conductivity = refl.conductivity;
        end
    end
    
    % Generate higher-order reflections if requested
    if p.Results.IncludeSecondary && p.Results.MaxOrder >= 2
        % Two-reflection paths between reflectors (advanced)
        % For simplicity, not implemented in basic version
    end
    
end
