%% NORMALIZE_PATTERN - Normalize antenna pattern to specified reference
%
% Syntax:
%   pattern_norm = normalize_pattern(pattern, varargin)
%   [pattern_norm, scale_factor] = normalize_pattern(pattern, varargin)
%
% Description:
%   Normalizes antenna pattern magnitude using specified method.
%
% Input Arguments:
%   pattern     - Antenna pattern (magnitude)
%
% Name-Value Arguments:
%   'Method'    - 'peak', 'directivity', 'rms' (default: 'peak')
%   'Reference' - Reference value for normalization (default: computed)
%
% Output Arguments:
%   pattern_norm - Normalized pattern
%   scale_factor - Normalization factor applied
%
% Example:
%   pattern_norm = normalize_pattern(pattern, 'Method', 'peak');
%
% See also: radiation_pattern, pattern_error

function [pattern_norm, scale_factor] = normalize_pattern(pattern, varargin)
    
    % Input validation
    validateattributes(pattern, {'numeric'}, {'vector', 'real', 'positive'}, mfilename, 'pattern');
    
    pattern = pattern(:);  % Column vector
    
    % Parse optional arguments
    p = inputParser;
    addParameter(p, 'Method', 'peak', @(x) ismember(x, {'peak', 'directivity', 'rms'}));
    addParameter(p, 'Reference', [], @isnumeric);
    parse(p, varargin{:});
    
    % Compute normalization factor
    if ~isempty(p.Results.Reference)
        scale_factor = p.Results.Reference;
    else
        switch p.Results.Method
            case 'peak'
                scale_factor = max(pattern);
            case 'directivity'
                % Normalize to integral
                scale_factor = sqrt(sum(pattern.^2) / length(pattern));
            case 'rms'
                scale_factor = sqrt(mean(pattern.^2));
        end
    end
    
    % Avoid division by zero
    if scale_factor == 0
        scale_factor = 1;
    end
    
    % Normalize
    pattern_norm = pattern / scale_factor;
    
end
