%% VALIDATE_INPUT - Validate input parameters and structures
%
% Syntax:
%   is_valid = validate_input(data, data_type, varargin)
%
% Description:
%   Validates input data against expected type and constraints.
%
% Input Arguments:
%   data        - Data to validate
%   data_type   - Expected type: 'frequency_response', 'impulse_response', 'pattern', etc.
%
% Output Arguments:
%   is_valid    - Boolean indicating if data is valid
%
% Example:
%   is_valid = validate_input(H_freq, 'frequency_response');
%
% See also: assert_valid_config

function is_valid = validate_input(data, data_type, varargin)
    
    is_valid = true;
    
    switch data_type
        case 'frequency_response'
            if ~isvector(data) || ~isnumeric(data)
                is_valid = false;
            elseif isempty(data)
                is_valid = false;
            end
            
        case 'impulse_response'
            if ~isvector(data) || ~isnumeric(data)
                is_valid = false;
            elseif isempty(data)
                is_valid = false;
            end
            
        case 'pattern'
            if ~isvector(data) || ~isnumeric(data) || any(data < 0)
                is_valid = false;
            elseif isempty(data)
                is_valid = false;
            end
            
        case 'configuration'
            if ~isstruct(data)
                is_valid = false;
            end
    end
    
end
