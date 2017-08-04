function [Cell] = AnalyzeCell(Cell)


%% Value from CalculateInputResistance function
[Cell.Properties.Rin.value] = CalculateInputResistance(Cell);

% Values from CalculateSag function
% Can only run Calculate Sag if have curve fitting toolbox

[Cell.Properties.SagReb.Sag] = CalculateSag(Cell);

%% Values from CalculateRebound function
[Cell.Properties.SagReb.Rebound] = CalculateRebound(Cell);


%% FI curve and doublet/adaptation

% Uses the Neural Network Toolbox for "regression" function

% [Cell.Properties.FICurve.slope, Cell.Properties.FICurve.intercept, Cell.Properties.FiringProperties.adaptation_index_2ndto3rd, ...
%     Cell.Properties.FiringProperties.adaptation_index_3rdto4th, Cell.Properties.FiringProperties.doublet_index, ...
%     Cell.Properties.FiringProperties.adaptation_sweeps, Cell.Properties.FiringProperties.doublet_sweeps, ...
%     Cell.Properties.FiringProperties.mean_swp_time_adaptation, Cell.Properties.FiringProperties.mean_swp_time_doublet] = SpikeFiringAnalysis(Cell);
% 

Cell.Properties.FICurve.slope = nan; 
Cell.Properties.FICurve.intercept = nan;
Cell.Properties.FiringProperties.adaptation_index_2ndto3rd = nan;
Cell.Properties.FiringProperties.adaptation_index_3rdto4th = nan;
Cell.Properties.FiringProperties.doublet_index = nan;
Cell.Properties.FiringProperties.adaptation_sweeps = nan;
Cell.Properties.FiringProperties.doublet_sweeps =nan; 
Cell.Properties.FiringProperties.mean_swp_time_adaptation = nan;
Cell.Properties.FiringProperties.mean_swp_time_doublet = nan;


%% AP Waveform
include_long_sweeps = 'yes';

Cell.Properties.APWaveformValues_3spikes = APWaveformSummaryStats(Cell, 3, include_long_sweeps);
Cell.Properties.APWaveformValues_4spikes = APWaveformSummaryStats(Cell, 4, include_long_sweeps);
Cell.Properties.APWaveformValues_5spikes = APWaveformSummaryStats(Cell, 5, include_long_sweeps);
Cell.Properties.APWaveformValues_6spikes = APWaveformSummaryStats(Cell, 6, include_long_sweeps);
Cell.Properties.APWaveformValues_7spikes = APWaveformSummaryStats(Cell, 7, include_long_sweeps);
Cell.Properties.APWaveformValues_8spikes = APWaveformSummaryStats(Cell, 8, include_long_sweeps);



end



