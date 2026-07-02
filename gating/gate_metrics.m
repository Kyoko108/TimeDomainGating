%% GATE_METRICS - Compute quantitative metrics of gating performance
%
% Syntax:
%   metrics = gate_metrics(pattern_original, pattern_gated, channel_config)
%
% Description:
%   Computes performance metrics comparing gated and ungated antenna patterns.
%   Metrics include RMS error, peak error, dynamic range, and leakage.
%
% Input Arguments:
%   pattern_original    - Original antenna pattern (magnitude, linear)
%   pattern_gated       - Gated antenna pattern (magnitude, linear)
%   channel_config      - Channel configuration structure
%
% Output Arguments:
%   metrics             - Structure with computed metrics
%
% Example:
%   metrics = gate_metrics(pattern_orig, pattern_gated, chan_config);
%
% See also: reconstruct_pattern, optimize_gate

function metrics = gate_metrics(pattern_original, pattern_gated, channel_config)

    % Input validation
    validateattributes(pattern_original, {'numeric'}, {'vector', 'real', 'positive'}, mfilename, 'pattern_original');
    validateattributes(pattern_gated, {'numeric'}, {'vector', 'real', 'nonnegative'}, mfilename, 'pattern_gated');

    pattern_original = pattern_original(:);
    pattern_gated = pattern_gated(:);

    if length(pattern_original) ~= length(pattern_gated)
        error('Patterns must have same length');
    end

    % Normalize patterns to [0, 1]
    pat_orig_norm = pattern_original / max(pattern_original);
    pat_gated_norm = pattern_gated / max(pattern_gated);

    % RMS Error
    error_vector = pat_orig_norm - pat_gated_norm;
    metrics.rms_error = sqrt(mean(error_vector.^2));
    metrics.rms_error_db = 20 * log10(metrics.rms_error + eps);

    % Peak (maximum absolute) error
    metrics.peak_error = max(abs(error_vector));
    metrics.peak_error_db = 20 * log10(metrics.peak_error + eps);

    % Mean error
    metrics.mean_error = mean(error_vector);

    % Standard deviation of error
    metrics.std_error = std(error_vector);

    % Correlation coefficient
    cov_matrix = cov(pat_orig_norm, pat_gated_norm);
    std_orig = std(pat_orig_norm);
    std_gated = std(pat_gated_norm);
    if std_orig > 0 && std_gated > 0
        metrics.correlation = cov_matrix(1,2) / (std_orig * std_gated);
    else
        metrics.correlation = 0;
    end

    % Dynamic range
    metrics.dynamic_range_original = 20 * log10(max(pattern_original) / (min(pattern_original) + eps));
    metrics.dynamic_range_gated = 20 * log10(max(pattern_gated) / (min(pattern_gated) + eps));

    % Energy in main lobe vs sidelobe
    [~, main_lobe_idx] = max(pattern_gated);
    main_lobe_region = abs((1:length(pattern_gated)) - main_lobe_idx) < length(pattern_gated)/8;
    metrics.main_lobe_energy = sum(pattern_gated(main_lobe_region)) / sum(pattern_gated);

    % Leakage (out-of-band energy)
    metrics.leakage_db = 20 * log10(sum(pattern_gated(~main_lobe_region)) / sum(pattern_gated) + eps);

end
