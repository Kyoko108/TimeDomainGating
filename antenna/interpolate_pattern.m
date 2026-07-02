%% INTERPOLATE_PATTERN - Interpolate antenna pattern to finer angular resolution
%
% Syntax:
%   pattern_interp = interpolate_pattern(theta, pattern, theta_new, varargin)
%
% Description:
%   Interpolates antenna pattern to new angle vector using specified method.
%
% Input Arguments:
%   theta           - Original angle vector [radians]
%   pattern         - Pattern at original angles
%   theta_new       - New angle vector [radians]
%
% Name-Value Arguments:
%   'Method'        - 'linear', 'spline', 'cubic' (default: 'linear')
%
% Output Arguments:
%   pattern_interp  - Interpolated pattern
%
% Example:
%   pattern_fine = interpolate_pattern(theta, pattern, theta_fine, 'Method', 'spline');
%
% See also: radiation_pattern, reconstruct_pattern

function pattern_interp = interpolate_pattern(theta, pattern, theta_new, varargin)
    
    % Input validation
    validateattributes(theta, {'numeric'}, {'vector', 'real'}, mfilename, 'theta');
    validateattributes(pattern, {'numeric'}, {'vector', 'real'}, mfilename, 'pattern');
    validateattributes(theta_new, {'numeric'}, {'vector', 'real'}, mfilename, 'theta_new');
    
    theta = theta(:);
    pattern = pattern(:);
    theta_new = theta_new(:);
    
    % Parse optional arguments
    p = inputParser;
    addParameter(p, 'Method', 'linear', @(x) ismember(x, {'linear', 'spline', 'cubic'}));
    parse(p, varargin{:});
    
    % Perform interpolation
    pattern_interp = interp1(theta, pattern, theta_new, p.Results.Method, 'extrap');
    
    % Ensure non-negative
    pattern_interp = max(pattern_interp, 0);
    
end
