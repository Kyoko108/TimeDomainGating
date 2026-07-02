%% CREATE_FREQUENCY_RESPONSE - Generate frequency-domain antenna transfer function
%
% Syntax:
%   H = create_frequency_response(freq, antenna_config, channel_config, varargin)
%
% Description:
%   Creates a complex frequency-domain transfer function representing
%   the antenna measurement in a multipath environment. Combines antenna
%   gain, phase characteristics, and channel effects.
%
% Input Arguments:
%   freq                - Frequency vector [Hz]
%   antenna_config      - Antenna configuration structure
%   channel_config      - Channel configuration structure
%
% Name-Value Arguments:
%   'IncludeMultipath'  - Include multipath effects (default: true)
%   'NormalizationMode' - 'none', 'peak', 'rms' (default: 'peak')
%
% Output Arguments:
%   H                   - Complex frequency response [1]
%
% Example:
%   H = create_frequency_response(freq, ant_config, chan_config);
%
% See also: freq_to_time_gate, time_to_frequency

function H = create_frequency_response(freq, antenna_config, channel_config, varargin)
    
    % Input validation
    validateattributes(freq, {'numeric'}, {'real', 'positive', 'vector'}, mfilename, 'freq');
    
    freq = freq(:);  % Column vector
    num_freq = length(freq);
    
    % Parse optional arguments
    p = inputParser;
    addParameter(p, 'IncludeMultipath', true, @islogical);
    addParameter(p, 'NormalizationMode', 'peak', @(x) ismember(x, {'none', 'peak', 'rms'}));
    parse(p, varargin{:});
    
    % Initialize response
    H = ones(num_freq, 1);
    
    % Add frequency-dependent antenna gain
    % Gain = Gain_ref + slope * (f - f_ref)
    f_ref = antenna_config.frequency_ref;
    gain_ref_lin = 10.^(antenna_config.gain_ref / 20);  % Convert dBi to linear
    slope = antenna_config.gain_slope_db_per_ghz / (20 * 1e9);  % Convert to linear per Hz
    
    gain_variation = 10.^((antenna_config.gain_slope_db_per_ghz * (freq - f_ref) / 1e9) / 20);
    H = H .* gain_ref_lin .* gain_variation;
    
    % Add phase variation with frequency
    phase_slope_rad_per_hz = antenna_config.phase_shift_per_ghz * pi/180 / 1e9;
    phase_variation = exp(1j * phase_slope_rad_per_hz * (freq - f_ref));
    H = H .* phase_variation;
    
    % Add multipath channel effects if requested
    if p.Results.IncludeMultipath && channel_config.los_enabled
        % Simple multipath model: add delayed and attenuated copies
        c = 3e8;
        
        % Direct path phase shift
        delay_direct = channel_config.los_distance / c;
        phase_direct = exp(-1j * 2*pi*freq * delay_direct);
        H = H .* phase_direct;
        
        % Ground reflection (simplified image method)
        delay_refl = 2 * channel_config.los_distance / c;  % Approximate
        amplitude_refl = 0.85;  % Reflection coefficient
        phase_refl = exp(-1j * 2*pi*freq * delay_refl);
        H = H + amplitude_refl * phase_refl;
    end
    
    % Normalize output
    switch p.Results.NormalizationMode
        case 'peak'
            H = H / max(abs(H));
        case 'rms'
            H = H / sqrt(mean(abs(H).^2));
        case 'none'
            % No normalization
    end
    
end
