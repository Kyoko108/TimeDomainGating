%% SPECTRUM_NORMALIZATION - Normalize magnitude spectrum to unit peak
%
% Syntax:
%   H_norm = spectrum_normalization(H_freq, varargin)
%   [H_norm, norm_factor] = spectrum_normalization(H_freq, varargin)
%
% Description:
%   Normalizes magnitude spectrum while preserving phase relationship.
%   Useful for comparing frequency responses with different power levels.
%
% Input Arguments:
%   H_freq      - Complex frequency response [V/V]
%
% Name-Value Arguments:
%   'Method'    - 'peak', 'energy', 'rms' (default: 'peak')
%   'ReferenceValue' - Reference for normalization (default: computed from data)
%
% Output Arguments:
%   H_norm      - Normalized frequency response [1]
%   norm_factor - Normalization factor applied [1]
%
% Example:
%   H_norm = spectrum_normalization(H_freq, 'Method', 'peak');
%
% See also: remove_dc_component, phase_alignment

function [H_norm, norm_factor] = spectrum_normalization(H_freq, varargin)
    
    % Input validation
    validateattributes(H_freq, {'numeric'}, {'vector'}, mfilename, 'H_freq');
    
    H_freq = H_freq(:);  % Column vector
    
    % Parse optional arguments
    p = inputParser;
    addParameter(p, 'Method', 'peak', @(x) ismember(x, {'peak', 'energy', 'rms'}));
    addParameter(p, 'ReferenceValue', [], @isnumeric);
    parse(p, varargin{:});
    
    % Compute normalization factor
    if ~isempty(p.Results.ReferenceValue)
        norm_factor = p.Results.ReferenceValue;
    else
        H_magnitude = abs(H_freq);
        
        switch p.Results.Method
            case 'peak'
                norm_factor = max(H_magnitude);
            case 'energy'
                norm_factor = sqrt(sum(H_magnitude.^2));
            case 'rms'
                norm_factor = sqrt(mean(H_magnitude.^2));
        end
    end
    
    % Avoid division by zero
    if norm_factor == 0
        norm_factor = 1;
    end
    
    % Normalize while preserving phase
    H_norm = H_freq / norm_factor;
    
end
