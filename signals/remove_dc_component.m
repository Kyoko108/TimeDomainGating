%% REMOVE_DC_COMPONENT - Remove DC (zero-frequency) component from signal
%
% Syntax:
%   H_no_dc = remove_dc_component(H_freq, varargin)
%
% Description:
%   Removes the DC component from frequency-domain signal.
%   Computes mean value and subtracts from all frequency points.
%
% Input Arguments:
%   H_freq      - Complex frequency response [V/V]
%
% Name-Value Arguments:
%   'Method'    - 'mean' or 'first' (default: 'mean')
%
% Output Arguments:
%   H_no_dc     - Frequency response with DC removed [V/V]
%
% Example:
%   H_no_dc = remove_dc_component(H_freq);
%
% See also: spectrum_normalization, phase_alignment

function H_no_dc = remove_dc_component(H_freq, varargin)
    
    % Input validation
    validateattributes(H_freq, {'numeric'}, {'vector'}, mfilename, 'H_freq');
    
    H_freq = H_freq(:);  % Column vector
    
    % Parse optional arguments
    p = inputParser;
    addParameter(p, 'Method', 'mean', @(x) ismember(x, {'mean', 'first'}));
    parse(p, varargin{:});
    
    % Compute and remove DC component
    switch p.Results.Method
        case 'mean'
            dc_component = mean(H_freq);
        case 'first'
            dc_component = H_freq(1);
    end
    
    H_no_dc = H_freq - dc_component;
    
end
