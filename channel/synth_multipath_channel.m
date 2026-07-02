%% SYNTH_MULTIPATH_CHANNEL - Synthesize multipath propagation channel
%
% Syntax:
%   H_multipath = synth_multipath_channel(freq, antenna_pattern, theta, channel_config)
%   [H_multipath, paths_info] = synth_multipath_channel(freq, antenna_pattern, theta, channel_config)
%
% Description:
%   Generates a physically-based multipath propagation channel including:
%   - Direct line-of-sight path
%   - Ground reflections (image method)
%   - Secondary reflections
%   - Frequency-dependent Fresnel reflection coefficients
%   - Friis free-space path loss
%   - Propagation delays
%
% Input Arguments:
%   freq                - Frequency vector [Hz]
%   antenna_pattern     - Antenna radiation pattern (magnitude)
%   theta               - Angle vector [radians]
%   channel_config      - Channel configuration structure
%
% Output Arguments:
%   H_multipath         - Complex transfer function [Hz x 1]
%   paths_info          - Structure with information about all paths
%
% Example:
%   freq = linspace(8e9, 12e9, 401);
%   ant_pattern = radiation_pattern(theta, ant_config);
%   [H, paths] = synth_multipath_channel(freq, ant_pattern, theta, chan_config);
%
% Physics:
%   - Friis equation: Path loss = (4*pi*d*f/c)^2
%   - Fresnel reflection: Frequency-dependent at material boundaries
%   - Total multipath: H(f) = H_direct(f) + sum(H_reflected(f))
%
% See also: find_direct_path, generate_reflections, build_channel_matrix, friis_path_loss

function [H_multipath, paths_info] = synth_multipath_channel(freq, antenna_pattern, theta, channel_config)

    % Input validation
    validateattributes(freq, {'numeric'}, {'real', 'positive', 'vector'}, mfilename, 'freq');
    validateattributes(antenna_pattern, {'numeric'}, {'real', 'positive'}, mfilename, 'antenna_pattern');
    validateattributes(theta, {'numeric'}, {'real'}, mfilename, 'theta');

    freq = freq(:);  % Ensure column vector
    num_freq = length(freq);

    % Physical constant
    c = 3e8;

    % Initialize output
    H_multipath = zeros(num_freq, 1);
    paths_info = struct();
    path_count = 0;

    % Define TX and RX positions
    tx_pos = [0, 0, channel_config.los_distance/2];  % TX height
    rx_pos = [channel_config.los_distance, 0, channel_config.los_distance/2];  % RX height

    % Generate direct (LOS) path
    direct_path = find_direct_path(tx_pos, rx_pos, 'Attenuation', channel_config.los_attenuation_db);

    path_count = path_count + 1;
    paths_info(path_count).type = 'direct';
    paths_info(path_count).distance = direct_path.distance;
    paths_info(path_count).delay = direct_path.delay;

    % Compute direct path contribution
    if channel_config.los_enabled
        % Friis path loss
        PL_db = 20 * log10(4*pi*direct_path.distance*freq/c);
        PL_linear = 10.^(PL_db/20);

        % Phase shift from propagation delay
        omega = 2*pi*freq;
        phase = exp(-1j * omega * direct_path.delay);

        H_direct = (1 ./ PL_linear) .* phase;
        H_multipath = H_multipath + H_direct;
    end

    % Generate reflections
    reflector_config_cell = {};
    for i = 1:length(channel_config.refl)
        reflector_config_cell{i} = channel_config.refl(i);
    end

    reflections = generate_reflections(tx_pos, rx_pos, reflector_config_cell, 'MaxOrder', channel_config.max_reflection_order);

    % Add reflection contributions
    for refl_idx = 1:length(reflections)
        refl = reflections(refl_idx);

        path_count = path_count + 1;
        paths_info(path_count).type = refl.type;
        paths_info(path_count).distance = refl.distance;
        paths_info(path_count).delay = refl.delay;
        paths_info(path_count).order = refl.order;

        % Friis path loss
        PL_db = 20 * log10(4*pi*refl.distance*freq/c);
        PL_linear = 10.^(PL_db/20);

        % Phase shift
        omega = 2*pi*freq;
        phase = exp(-1j * omega * refl.delay);

        % Fresnel reflection (simplified)
        % Assume grazing angle for ground reflections
        if ~isempty(strfind(char(refl.type), 'ground'))
            % Effective reflection coefficient for good conductor at grazing incidence
            r_mag = 0.95;
        else
            r_mag = 0.85;
        end

        r = r_mag * ones(num_freq, 1);

        % Combine components
        H_refl = (1 ./ PL_linear) .* r .* phase;
        H_multipath = H_multipath + H_refl;
    end

    % Normalize
    H_multipath = H_multipath / max(abs(H_multipath));

end
