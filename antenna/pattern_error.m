%% PATTERN_ERROR - Compute error between two antenna patterns
%
% Syntax:
%   error_rms = pattern_error(pattern1, pattern2, varargin)
%   [error_rms, error_peak, error_vector] = pattern_error(pattern1, pattern2, varargin)
%
% Description:
%   Computes RMS and peak errors between reference and test patterns.
%
% Input Arguments:
%   pattern1        - Reference pattern
%   pattern2        - Test/reconstructed pattern
%
% Name-Value Arguments:
%   'Metric'        - 'rms', 'peak', 'correlation' (default: 'rms')
%
% Output Arguments:
%   error_rms       - RMS error
%   error_peak      - Peak error
%   error_vector    - Error at each point
%
% Example:
%   [err_rms, err_peak] = pattern_error(pattern_orig, pattern_gated);
%
% See also: gate_metrics, normalize_pattern

function [error_rms, error_peak, error_vector] = pattern_error(pattern1, pattern2, varargin)
    
    % Input validation
    validateattributes(pattern1, {'numeric'}, {'vector', 'real'}, mfilename, 'pattern1');
    validateattributes(pattern2, {'numeric'}, {'vector', 'real'}, mfilename, 'pattern2');
    
    pattern1 = pattern1(:);
    pattern2 = pattern2(:);
    
    if length(pattern1) ~= length(pattern2)
        error('Patterns must have same length');
    end
    
    % Parse optional arguments
    p = inputParser;
    addParameter(p, 'Metric', 'rms', @(x) ismember(x, {'rms', 'peak', 'correlation'}));
    parse(p, varargin{:});
    
    % Normalize patterns for comparison
    pat1_norm = pattern1 / max(pattern1);
    pat2_norm = pattern2 / max(pattern2);
    
    % Compute error vector
    error_vector = pat1_norm - pat2_norm;
    
    % Compute metrics
    switch p.Results.Metric
        case 'rms'
            error_rms = sqrt(mean(error_vector.^2));
            error_peak = max(abs(error_vector));
        case 'peak'
            error_peak = max(abs(error_vector));
            error_rms = sqrt(mean(error_vector.^2));
        case 'correlation'
            correlation = corrcoef(pat1_norm, pat2_norm);
            error_rms = 1 - correlation(1,2);
            error_peak = max(abs(error_vector));
    end
    
end
