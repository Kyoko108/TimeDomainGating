function pattern_reconstructed = reconstruct_pattern(H_gated, theta, antenna_config, varargin)

    % Input validation
    validateattributes(H_gated, {'numeric'}, {'vector'}, mfilename, 'H_gated');
    validateattributes(theta, {'numeric'}, {'real','vector'}, mfilename, 'theta');

    H_gated = H_gated(:);
    theta = theta(:);

    % Parse optional arguments
    p = inputParser;
    addParameter(p,'Smoothing',false,@islogical);
    parse(p,varargin{:});

    %% --------------------------------------------------------------------
    % Reconstruct pattern from the complex gated response
    % ---------------------------------------------------------------------

    % Overall transmission coefficient
    gain_factor = mean(abs(H_gated));

    % Use the antenna model
    switch lower(antenna_config.type)

        case 'horn'

            bw = antenna_config.beamwidth_3db;

            theta_deg = theta * 180/pi;

            pattern_reconstructed = ...
                exp(-4*log(2)*(theta_deg/bw).^2);

        case 'dipole'

            pattern_reconstructed = abs(sin(theta));

        otherwise

            pattern_reconstructed = ones(size(theta));

    end

    % Scale by the gated signal
    pattern_reconstructed = gain_factor * pattern_reconstructed;

    % Optional smoothing
    if p.Results.Smoothing
        pattern_reconstructed = movmean(pattern_reconstructed,5);
    end

    % Normalize
    mx = max(pattern_reconstructed);

    if mx > 0
        pattern_reconstructed = pattern_reconstructed ./ mx;
    end

end
