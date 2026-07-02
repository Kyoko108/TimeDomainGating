%% RMS_ERROR - Compute root mean square error between two signals
%
% Syntax:
%   error_rms = rms_error(signal1, signal2)
%
% Description:
%   Computes RMS error between two signals.
%
% Input Arguments:
%   signal1     - Reference signal
%   signal2     - Test signal
%
% Output Arguments:
%   error_rms   - RMS error value
%
% Example:
%   err = rms_error(signal_ref, signal_test);
%
% See also: db_convert, peak_error

function error_rms = rms_error(signal1, signal2)
    
    validateattributes(signal1, {'numeric'}, {'vector'}, mfilename, 'signal1');
    validateattributes(signal2, {'numeric'}, {'vector'}, mfilename, 'signal2');
    
    signal1 = signal1(:);
    signal2 = signal2(:);
    
    if length(signal1) ~= length(signal2)
        error('Signals must have same length');
    end
    
    error_rms = sqrt(mean((signal1 - signal2).^2));
    
end
