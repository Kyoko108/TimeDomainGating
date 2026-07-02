%% CREATE_WINDOW - Create time-domain gate window function
%
% Syntax:
%   window = create_window(window_type, length, varargin)
%   [window, t] = create_window(window_type, length, varargin)
%
% Description:
%   Creates standard window functions for time-domain gating.
%   Supports rectangular, Hann, Hamming, Blackman, Kaiser, and Tukey windows.
%
% Input Arguments:
%   window_type - String: 'rectangular', 'hann', 'hamming', 'blackman', 'kaiser', 'tukey'
%   length      - Window length (number of samples)
%
% Name-Value Arguments:
%   'Beta'      - Kaiser window parameter (default: 8.6)
%   'TukeyParam' - Tukey window taper fraction (default: 0.5)
%
% Output Arguments:
%   window      - Window coefficients [1 x length]
%   t           - Time vector [seconds]
%
% Example:
%   window = create_window('hann', 100);
%   [window, t] = create_window('kaiser', 200, 'Beta', 10);
%
% See also: apply_gate, optimize_gate

function [window, t] = create_window(window_type, length, varargin)
    
    % Input validation
    validateattributes(length, {'numeric'}, {'positive', 'integer'}, mfilename, 'length');
    
    % Parse optional arguments
    p = inputParser;
    addParameter(p, 'Beta', 8.6, @isnumeric);
    addParameter(p, 'TukeyParam', 0.5, @isnumeric);
    parse(p, varargin{:});
    
    % Create window based on type
    switch lower(window_type)
        case 'rectangular'
            window = ones(length, 1);
        case 'hann'
            window = hann(length);
        case 'hamming'
            window = hamming(length);
        case 'blackman'
            window = blackman(length);
        case 'kaiser'
            window = kaiser(length, p.Results.Beta);
        case 'tukey'
            window = tukeywin(length, p.Results.TukeyParam);
        otherwise
            error('Unknown window type: %s', window_type);
    end
    
    % Ensure column vector
    window = window(:);
    
    % Create time vector if requested
    if nargout > 1
        t = (0:length-1)' / length;
    end
    
end
