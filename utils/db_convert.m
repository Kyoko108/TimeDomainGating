%% DB_CONVERT - Convert between dB and linear scales
%
% Syntax:
%   value_linear = db_convert(value_db, 'to_linear')
%   value_db = db_convert(value_linear, 'to_db')
%
% Description:
%   Converts values between dB and linear scales.
%
% Input Arguments:
%   value       - Value to convert
%   direction   - 'to_linear' or 'to_db'
%
% Output Arguments:
%   value_converted - Converted value
%
% Example:
%   lin_val = db_convert(20, 'to_linear');
%   db_val = db_convert(0.1, 'to_db');
%
% See also: rms_error, frequency_to_wavelength

function value_converted = db_convert(value, direction)
    
    validateattributes(value, {'numeric'}, {'real'}, mfilename, 'value');
    validateattributes(direction, {'char'}, {}, mfilename, 'direction');
    
    switch lower(direction)
        case 'to_linear'
            value_converted = 10.^(value/20);  % Amplitude
        case 'to_db'
            value_converted = 20 * log10(abs(value) + eps);
        otherwise
            error('direction must be "to_linear" or "to_db"');
    end
    
end
