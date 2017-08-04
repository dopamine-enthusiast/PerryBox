function [all_variables, Baseline_variables, Sag_variables, Reb_variables, Adaptation_Doublet_variables, AHP_vs_Threshold_variables, threshold_vs_threshold_variables, AHP_vs_AHP_variables, AHP_timing_variables,AHP_timing_ratios_versus_spike1_variables,AHP_timing_ratios_versus_spike2_variables, Spike_width_variables, Spike_width_ratios_variables, dVdt_rising_variables, dVdt_falling_variables, adaptation_ratio_1_variables, adaptation_ratio_2_variables] = GenerateVariableNames(min_spike_number, var)
% GenerateVariableNames 
%   This generates all the variable names that are in the table - and then
%   groups them into subsets.
%% 

for i = 1:min_spike_number
    AHP_vs_Threshold_names{i} = sprintf('AHP_vs_Threshold_%d', i);
    threshold_vs_threshold_names{i} = sprintf('Threshold_vs_Threshold_%d', i);
    AHP_vs_AHP_names{i} = sprintf('AHP_vs_AHP_%d', i);

    AHP_timing_names{i} = sprintf('AHP_timing_%d', i);
    AHP_timing_ratios_versus_spike1_names{i} = sprintf('AHP_timing_ratios_vs_Spike1_%d', i);
    AHP_timing_ratios_versus_spike2_names{i} = sprintf('AHP_timing_ratios_vs_Spike2_%d', i); 

    spike_width_threshold_names{i} = sprintf('Spike_Width_at_Threshold_%d', i); 
    spike_width_percent20_names{i} = sprintf('Spike_Width_at_20percent_%d', i);
    spike_width_percent50_names{i} = sprintf('Spike_Width_at_50percent_%d', i);

    spike_width_ratios_threshold_names{i} = sprintf('Spike_Width_Ratios_at_Threshold_%d', i);
    spike_width_ratios_percent20_names{i} = sprintf('Spike_Width_Ratios_at_20percent_%d', i);
    spike_width_ratios_percent50_names{i} = sprintf('Spike_Width_Ratios_at_50percent_%d', i);

    dVdt_rising_max_names{i} = sprintf('dVdt_rising_max_%d', i);
    dVdt_rising_percent20_names{i} = sprintf('dVdt_rising_at_20percent_%d', i);
    dVdt_rising_percent50_names{i} = sprintf('dVdt_rising_at_50percent_%d', i);

    dVdt_falling_max_names{i} = sprintf('dVdt_falling_max_%d', i);
    dVdt_falling_percent20_names{i} = sprintf('dVdt_falling_at_20percent_%d', i);
    dVdt_falling_percent50_names{i} = sprintf('dVdt_falling_at_50percent_%d', i);
    dVdt_falling_at_threshold_names{i} =sprintf('dVdt_falling_at_threshold_%d', i);
    
    adaptation_ratio_1_names{i} = sprintf('adaptation_ratio_1_%d', i);
    adaptation_ratio_2_names{i} = sprintf('adaptation_ratio_2_%d', i);
end

AHP_vs_Threshold_variables = AHP_vs_Threshold_names(1:min_spike_number-1);
threshold_vs_threshold_variables = threshold_vs_threshold_names(2:min_spike_number);
AHP_vs_AHP_variables = AHP_vs_AHP_names(2:min_spike_number-1);
AHP_timing_variables = AHP_timing_names(1:min_spike_number-1);
AHP_timing_ratios_versus_spike1_variables = AHP_timing_ratios_versus_spike1_names(2:min_spike_number-1);
AHP_timing_ratios_versus_spike2_variables = AHP_timing_ratios_versus_spike2_names(3:min_spike_number-1);
spike_width_threshold_variables = spike_width_threshold_names(1:min_spike_number);
spike_width_percent20_variables = spike_width_percent20_names(1:min_spike_number);
spike_width_percent50_variables = spike_width_percent50_names(1:min_spike_number);
spike_width_ratios_threshold_variables = spike_width_ratios_threshold_names(2:min_spike_number);
spike_width_ratios_percent20_variables = spike_width_ratios_percent20_names(2:min_spike_number);
spike_width_ratios_percent50_variables = spike_width_ratios_percent50_names(2:min_spike_number);
dVdt_rising_max_variables =  dVdt_rising_max_names(1:min_spike_number);
dVdt_rising_percent20_variables = dVdt_rising_percent20_names(1:min_spike_number);
dVdt_rising_percent50_variables = dVdt_rising_percent50_names(1:min_spike_number);
dVdt_falling_max_variables = dVdt_falling_max_names(1:min_spike_number);
dVdt_falling_percent20_variables = dVdt_falling_percent20_names(1:min_spike_number);
dVdt_falling_percent50_variables = dVdt_falling_percent50_names(1:min_spike_number);
dVdt_falling_at_threshold_variables = dVdt_falling_at_threshold_names(1:min_spike_number);
adaptation_ratio_1_variables = adaptation_ratio_1_names(2:min_spike_number-1);
adaptation_ratio_2_variables = adaptation_ratio_2_names(3:min_spike_number-1);




%% Put together variable groups that want to analyze

Baseline_variables = {'Vm', 'Rin'};

Sag_variables = {'PeakSagLocation_ms', 'sag_amplitude', 'normalized_sag', 'sag_amplitude_fit', 'sag_tau_fit', ...
    'sag_delta_t'};

Reb_variables = {'rebound_amplitude', 'rebound_amplitude_130ms', 'rebound_amplitude_230ms',  'ReboundLocation_ms', 'ReboundLocation_ms_130ms', 'ReboundLocation_ms_230ms', 'reb_delta_t'};

Adaptation_Doublet_variables = {'FICurve_slope', 'FICurve_intercept', 'adaptation_index_2ndto3rd',...
    'adaptation_index_3rdto4th', 'doublet_index'};

if strcmp(var, '20')
    Spike_width_variables = {spike_width_percent20_variables{:}};
    Spike_width_ratios_variables = {spike_width_ratios_percent20_variables{:}};
    dVdt_rising_variables = {dVdt_rising_percent20_variables{:}};
    dVdt_falling_variables = {dVdt_falling_percent20_variables{:}}; 
elseif strcmp(var, 'All')
    Spike_width_variables = {spike_width_threshold_variables{:}, spike_width_percent20_variables{:}, spike_width_percent50_variables{:}};
    Spike_width_ratios_variables = {spike_width_ratios_threshold_variables{:}, spike_width_ratios_percent20_variables{:}, spike_width_ratios_percent50_variables{:}};
    dVdt_rising_variables = {dVdt_rising_max_variables{:},  dVdt_rising_percent20_variables{:}, dVdt_rising_percent50_variables{:}};
    dVdt_falling_variables = {dVdt_falling_max_variables{:}, dVdt_falling_percent20_variables{:}, dVdt_falling_percent50_variables{:}, dVdt_falling_at_threshold_variables{:}}; 
end





all_variables = {Baseline_variables{:}, Sag_variables{:}, Reb_variables{:}, Adaptation_Doublet_variables{:},...
    AHP_vs_Threshold_variables{:}, threshold_vs_threshold_variables{:}, AHP_vs_AHP_variables{:},...
    AHP_timing_variables{:}, AHP_timing_ratios_versus_spike1_variables{:}, AHP_timing_ratios_versus_spike2_variables{:},....
    Spike_width_variables{:}, Spike_width_ratios_variables{:}, dVdt_rising_variables{:},...
    dVdt_falling_variables{:}, adaptation_ratio_1_variables{:}, adaptation_ratio_2_variables{:}};

% if min_spike_number > 3
%     all_variables = {Baseline_variables{:}, Sag_variables{:}, Reb_variables{:}, Adaptation_Doublet_variables{:},...
%         AHP_vs_Threshold_variables{end}, threshold_vs_threshold_variables{end}, AHP_vs_AHP_variables{end},...
%         AHP_timing_variables{end}, AHP_timing_ratios_versus_spike1_variables{end}, AHP_timing_ratios_versus_spike2_variables{end},....
%         Spike_width_variables{2*min_spike_number}, Spike_width_ratios_variables{2*min_spike_number-2}, dVdt_rising_variables{2*min_spike_number},...
%         dVdt_falling_variables{2*min_spike_number}};
% else
%     all_variables = {Baseline_variables{:}, Sag_variables{:}, Reb_variables{:}, Adaptation_Doublet_variables{:},...
%         AHP_vs_Threshold_variables{end}, threshold_vs_threshold_variables{end}, AHP_vs_AHP_variables{end},...
%         AHP_timing_variables{end}, AHP_timing_ratios_versus_spike1_variables{end},....
%         Spike_width_variables{2*min_spike_number}, Spike_width_ratios_variables{2*min_spike_number-2}, dVdt_rising_variables{2*min_spike_number},...
%         dVdt_falling_variables{2*min_spike_number}};
% end
    

  
end

