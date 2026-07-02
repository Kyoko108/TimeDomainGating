%% PROPAGATION_DELAY - Calculate propagation delay for multipath components
%
% Syntax:
%   delay = propagation_delay(distance)
%   [delay, phase] = propagation_delay(distance, freq)
%
% Description:
%   Computes propagation delay for a given distance.
%   Optionally computes phase shift at specific frequencies.
%
%   delay = distance / c
%   phase = 2*pi*freq*delay
%
% Input Arguments:
%   distance    - Distance or distance vector [m]
%   freq        - Frequency or frequency vector [Hz] (optional)
%
% Output Arguments:
%   delay       - Propagation delay [seconds]
%   phase       - Phase shift at specified frequencies [radians]
%
% Example:
%   distance = 10;  % 10 meters
%   delay = propagation_delay(distance);
%   
%   freq = linspace(8e9, 12e9, 401);
%   [delay, phase] = propagation_delay(distance, freq);
%
% See also: friis_path_loss, find_direct_path, synth_multipath_channel

function [delay, phase] = propagation_delay(distance, freq)
    
    % Input validation
    validateattributes(distance, {'numeric'}, {'real', 'positive'}, mfilename, 'distance');
    
    % Physical constant
    c = 3e8;  % Speed of light [m/s]
    
    % Calculate delay
    delay = distance / c;
    
    % Calculate phase if frequency is provided
    if nargin > 1
        validateattributes(freq, {'numeric'}, {'real', 'positive'}, mfilename, 'freq');
        freq = freq(:);
        phase = 2 * pi * freq * delay;
    end
    
end
