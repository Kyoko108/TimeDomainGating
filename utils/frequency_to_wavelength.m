%% FREQUENCY_TO_WAVELENGTH - Convert frequency to wavelength
%
% Syntax:
%   wavelength = frequency_to_wavelength(frequency)
%
% Description:
%   Converts frequency to corresponding wavelength.
%
% Input Arguments:
%   frequency   - Frequency [Hz]
%
% Output Arguments:
%   wavelength  - Wavelength [m]
%
% Example:
%   lambda = frequency_to_wavelength(10e9);
%
% See also: db_convert

function wavelength = frequency_to_wavelength(frequency)
    
    validateattributes(frequency, {'numeric'}, {'real', 'positive'}, mfilename, 'frequency');
    
    c = 3e8;  % Speed of light [m/s]
    wavelength = c ./ frequency;
    
end
