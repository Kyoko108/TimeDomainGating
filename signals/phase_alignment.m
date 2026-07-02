%% PHASE_ALIGNMENT - Align phase response for consistent measurement
%
% Syntax:
%   H_aligned = phase_alignment(H_freq, varargin)
%   [H_aligned, phase_offset] = phase_alignment(H_freq, varargin)
%
% Description:
%   Adjusts phase of frequency response to align with reference phase.
%   Useful for comparing measurements with different phase origins.
%
% Input Arguments:
%   H_freq      - Complex frequency response [V/V]
%
% Name-Value Arguments:
%   'ReferencePhase' - Phase offset [radians] (default: 0)
%   'Method'         - 'linear', 'minimum' (default: 'linear')
%
% Output Arguments:
%   H_aligned   - Phase-aligned frequency response [V/V]
%   phase_offset - Phase shift applied [radians]
%
% Example:
%   H_aligned = phase_alignment(H_freq, 'Method', 'linear');
%
% See also: spectrum_normalization, remove_dc_component

function [H_aligned, phase_offset] = phase_alignment(H_freq, varargin)
    
    % Input validation
    validateattributes(H_freq, {'numeric'}, {'vector'}, mfilename, 'H_freq');
    
    H_freq = H_freq(:);  % Column vector
    
    % Parse optional arguments
    p = inputParser;
    addParameter(p, 'ReferencePhase', 0, @isnumeric);
    addParameter(p, 'Method', 'linear', @(x) ismember(x, {'linear', 'minimum'}));
    parse(p, varargin{:});
    
    % Compute phase
    phase = angle(H_freq);
    
    % Determine phase offset
    switch p.Results.Method
        case 'linear'
            % Remove linear phase trend
            freq_idx = (0:length(phase)-1)';
            phase_trend = polyfit(freq_idx, phase, 1);
            phase_linear = polyval(phase_trend, freq_idx);
            phase_offset = mean(phase_linear);
            
        case 'minimum'
            % Align to minimum phase at first point
            phase_offset = phase(1);
    end
    
    % Apply offset
    phase_offset = phase_offset + p.Results.ReferencePhase;
    phase_aligned = phase - phase_offset;
    
    % Reconstruct complex signal with aligned phase
    magnitude = abs(H_freq);
    H_aligned = magnitude .* exp(1j * phase_aligned);
    
end
