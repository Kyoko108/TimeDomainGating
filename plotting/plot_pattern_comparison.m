%% PLOT_PATTERN_COMPARISON - Plot original and gated antenna patterns
%
% Syntax:
%   plot_pattern_comparison(theta, pattern_orig, pattern_gated, varargin)
%
% Description:
%   Creates publication-quality comparison plots of antenna patterns.
%
% Input Arguments:
%   theta               - Angle vector [radians]
%   pattern_orig        - Original antenna pattern
%   pattern_gated       - Gated antenna pattern
%
% Name-Value Arguments:
%   'Title'             - Plot title
%   'SavePath'          - Path to save figure (default: not saved)
%
% Example:
%   plot_pattern_comparison(theta, pat_orig, pat_gated, 'Title', 'Pattern Comparison');
%
% See also: plot_frequency_response, plot_gate_window

function plot_pattern_comparison(theta, pattern_orig, pattern_gated, varargin)

disp('Entered plot_pattern_comparison');

    % Input validation
    validateattributes(theta, {'numeric'}, {'vector', 'real'}, mfilename, 'theta');
    validateattributes(pattern_orig, {'numeric'}, {'vector', 'real', 'nonnegative'}, mfilename, 'pattern_orig');
    validateattributes(pattern_gated, {'numeric'}, {'vector', 'real', 'nonnegative'}, mfilename, 'pattern_gated');

    % Parse optional arguments
    p = inputParser;
    addParameter(p, 'Title', 'Pattern Comparison', @ischar);
    addParameter(p, 'SavePath', '', @ischar);
    addParameter(p, 'PlotType', 'linear', @ischar);
    parse(p, varargin{:});

    % Create figure
    %% Create figure
figure('Name','Pattern Comparison',...
       'NumberTitle','off',...
       'Position',[100 100 1200 750],...
       'Color','w');

%% ---------------- Linear Scale ----------------
subplot(1,2,1)

plot(theta*180/pi, pattern_orig,...
    'b-','LineWidth',2);
hold on

plot(theta*180/pi, pattern_gated,...
    'r--','LineWidth',2);

grid on
box on

xlabel('Angle [degrees]','FontSize',12)
ylabel('Magnitude (normalized)','FontSize',12)
title('Linear Scale','FontSize',14,'FontWeight','bold')

xlim([0 360])

%% ---------------- dB Scale ----------------
subplot(1,2,2)

pattern_orig_db = 20*log10(pattern_orig + eps);
pattern_gated_db = 20*log10(pattern_gated + eps);

plot(theta*180/pi, pattern_orig_db,...
    'b-','LineWidth',2);
hold on

plot(theta*180/pi, pattern_gated_db,...
    'r--','LineWidth',2);

grid on
box on

xlabel('Angle [degrees]','FontSize',12)
ylabel('Magnitude [dB]','FontSize',12)
title('dB Scale','FontSize',14,'FontWeight','bold')

xlim([0 360])

legend({'Original','Gated'}, ...
       'Location','northoutside', ...
       'Orientation','horizontal', ...
       'FontSize',12, ...
       'Box','off');

%% ---------------- Overall Title ----------------
if exist('sgtitle','file')
   sgtitle('Antenna Pattern Comparison');
else
    annotation('textbox',...
        [0.32 -0.010 0.40 0.04],...
        'String','Antenna Pattern Comparison',...
        'HorizontalAlignment','center',...
        'EdgeColor','none',...
        'FontSize',16,...
        'FontWeight','bold');
end
    %end

end
