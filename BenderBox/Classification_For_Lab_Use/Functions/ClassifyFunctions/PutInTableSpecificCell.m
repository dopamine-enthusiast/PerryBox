function [Full_Cell_Properties_Table] = PutInTableSpecificCell(Cell, spikes)


properties_string_basic = {'genetic_marker', 'mouse_genotype', 'retrograde', 'Ca_buffer'};

[~, Baseline_variables, Sag_variables, Reb_variables, Adaptation_Doublet_variables, AHP_vs_Threshold_variables, threshold_vs_threshold_variables, AHP_vs_AHP_variables, AHP_timing_variables,AHP_timing_ratios_versus_spike1_variables,AHP_timing_ratios_versus_spike2_variables, Spike_width_variables, Spike_width_ratios_variables, dVdt_rising_variables, dVdt_falling_variables, adaptation_ratio_1_variables, adaptation_ratio_2_variables]...
    = GenerateVariableNames(spikes, 'All');


Cell_name = {Cell.name}; % extract name of cell

% Extract info for basic identification; determine what to put in
% table if info is not there
if isfield(Cell, 'genetic_marker')
    genetic_marker = {Cell.genetic_marker};
else
    genetic_marker = {'None'};
end

if isfield(Cell, 'mouse_genotype')
    mouse_genotype = {Cell.mouse_genotype};
else
    mouse_genotype = {'nAN'};
end

if isfield(Cell, 'retrograde')
    retrograde = {Cell.retrograde};
else
    retrograde = {'No'};
end

if isfield(Cell, 'Vm')
    if isempty(Cell.Vm)
        Vm = nan;
    else
        Vm = Cell.Vm;
    end
else
    Vm = nan;
end

if isfield(Cell, 'distance_from_pia')
    if isempty(Cell.distance_from_pia)
        distance_from_pia= nan;
    else
        distance_from_pia = Cell.distance_from_pia;
    end
else
    distance_from_pia = nan;
end

if isfield(Cell.Properties.SagReb.Rebound, 'ReboundLocation_ms_not120sweep')
    ReboundLocation_ms_not120sweep = Cell.Properties.SagReb.Rebound.ReboundLocation_ms_not120sweep;
else
    ReboundLocation_ms_not120sweep = nan;
end

Ca_buffer = {Cell.CaBuffer};

mean_sweep_time = Cell.Properties.(sprintf('APWaveformValues_%dspikes', spikes)).mean_sweep_time;
number_of_spikes = Cell.Properties.(sprintf('APWaveformValues_%dspikes', spikes)).number_of_spikes;

mean_sag_sweep_time = Cell.Properties.SagReb.Sag.mean_sweep_time;
mean_doub_sweep_time = Cell.Properties.FiringProperties.mean_swp_time_doublet;
mean_adapt_sweep_time = Cell.Properties.FiringProperties.mean_swp_time_adaptation;

%% create arrays with all the values for the table

%% Rin/SagReb
Rin = Cell.Properties.Rin.value;
PeakSagLocation_ms = Cell.Properties.SagReb.Sag.PeakSagLocation_ms;
sag_amplitude = Cell.Properties.SagReb.Sag.sag_amplitude;
sag_amplitude_fit = Cell.Properties.SagReb.Sag.sag_amplitude_fit;
normalized_sag = Cell.Properties.SagReb.Sag.normalized_sag;
sag_tau_fit = Cell.Properties.SagReb.Sag.sag_tau_fit;
sag_delta_t = Cell.Properties.SagReb.Sag.sag_delta_t;
rebound_amplitude = Cell.Properties.SagReb.Rebound.rebound_amplitude;
rebound_amplitude_130ms = Cell.Properties.SagReb.Rebound.rebound_amplitude_130ms;
rebound_amplitude_230ms = Cell.Properties.SagReb.Rebound.rebound_amplitude_230ms;

ReboundLocation_ms = Cell.Properties.SagReb.Rebound.ReboundLocation_ms;
ReboundLocation_ms_130ms = Cell.Properties.SagReb.Rebound.ReboundLocation_ms_130ms;
ReboundLocation_ms_230ms = Cell.Properties.SagReb.Rebound.ReboundLocation_ms_230ms;

reb_delta_t = Cell.Properties.SagReb.Rebound.reb_delta_t;


%% Spiking
FICurve_slope = Cell.Properties.FICurve.slope;
FICurve_intercept = Cell.Properties.FICurve.intercept;
adaptation_index_2ndto3rd = Cell.Properties.FiringProperties.adaptation_index_2ndto3rd;
adaptation_index_3rdto4th = Cell.Properties.FiringProperties.adaptation_index_3rdto4th;
doublet_index = Cell.Properties.FiringProperties.doublet_index;

%%


AHP_vs_Threshold = Cell.Properties.(sprintf('APWaveformValues_%dspikes', spikes)).mV_change.AHP_vs_threshold(1:spikes);
threshold_vs_threshold = Cell.Properties.(sprintf('APWaveformValues_%dspikes', spikes)).mV_change.threshold_vs_threshold(1:spikes);
AHP_vs_AHP  = Cell.Properties.(sprintf('APWaveformValues_%dspikes', spikes)).mV_change.AHP_vs_AHP(1:spikes);

AHP_timing = Cell.Properties.(sprintf('APWaveformValues_%dspikes', spikes)).AHP_timing.All_spikes(1:spikes);
AHP_timing_ratios_versus_spike1 = Cell.Properties.(sprintf('APWaveformValues_%dspikes', spikes)).AHP_timing_ratios.versus_spike1(1:spikes);
AHP_timing_ratios_versus_spike2 = Cell.Properties.(sprintf('APWaveformValues_%dspikes', spikes)).AHP_timing_ratios.versus_spike2(1:spikes);

spike_width_threshold = Cell.Properties.(sprintf('APWaveformValues_%dspikes', spikes)).spike_width.Threshold(1:spikes);
spike_width_percent20 = Cell.Properties.(sprintf('APWaveformValues_%dspikes', spikes)).spike_width.percent20(1:spikes);
spike_width_percent50 = Cell.Properties.(sprintf('APWaveformValues_%dspikes', spikes)).spike_width.percent50(1:spikes);


spike_width_ratios_threshold = Cell.Properties.(sprintf('APWaveformValues_%dspikes', spikes)).spike_width_ratios.Threshold(1:spikes);
spike_width_ratios_percent20 = Cell.Properties.(sprintf('APWaveformValues_%dspikes', spikes)).spike_width_ratios.percent20(1:spikes);
spike_width_ratios_percent50 = Cell.Properties.(sprintf('APWaveformValues_%dspikes', spikes)).spike_width_ratios.percent50(1:spikes);


dVdt_rising_max =  Cell.Properties.(sprintf('APWaveformValues_%dspikes', spikes)).dVdt_rising.Max(1:spikes);
dVdt_rising_percent20 = Cell.Properties.(sprintf('APWaveformValues_%dspikes', spikes)).dVdt_rising.percent20(1:spikes);
dVdt_rising_percent50 =  Cell.Properties.(sprintf('APWaveformValues_%dspikes', spikes)).dVdt_rising.percent50(1:spikes);

dVdt_falling_max = Cell.Properties.(sprintf('APWaveformValues_%dspikes', spikes)).dVdt_falling.Max(1:spikes);
dVdt_falling_percent20 = Cell.Properties.(sprintf('APWaveformValues_%dspikes', spikes)).dVdt_falling.percent20(1:spikes);
dVdt_falling_percent50= Cell.Properties.(sprintf('APWaveformValues_%dspikes', spikes)).dVdt_falling.percent50(1:spikes);
dVdt_falling_at_threshold = Cell.Properties.(sprintf('APWaveformValues_%dspikes', spikes)).dVdt_falling.Threshold(1:spikes);

adaptation_ratio_1 =  Cell.Properties.(sprintf('APWaveformValues_%dspikes', spikes)).adaptation_ratio.Adaptation_Ratio_1(1:spikes);
adaptation_ratio_2 =  Cell.Properties.(sprintf('APWaveformValues_%dspikes', spikes)).adaptation_ratio.Adaptation_Ratio_2(1:spikes);






%% Create the tables



sweep_time_table = table(mean_sweep_time, number_of_spikes);
AHP_vs_Threshold_table = array2table(AHP_vs_Threshold(:, 1:spikes-1), 'VariableNames', {AHP_vs_Threshold_variables{:}});
threshold_vs_threshold_table = array2table(threshold_vs_threshold(:, 2:spikes), 'VariableNames', {threshold_vs_threshold_variables{:}});
AHP_vs_AHP_table  = array2table(AHP_vs_AHP(:, 2:spikes-1), 'VariableNames', {AHP_vs_AHP_variables{:}});
AHP_timing_table = array2table(AHP_timing(:, 1:spikes-1), 'VariableNames', {AHP_timing_variables{:}});
AHP_timing_ratios_versus_spike1_table = array2table(AHP_timing_ratios_versus_spike1(:, 2:spikes-1), 'VariableNames', {AHP_timing_ratios_versus_spike1_variables{:}});
AHP_timing_ratios_versus_spike2_table = array2table(AHP_timing_ratios_versus_spike2(:, 3:spikes-1), 'VariableNames', {AHP_timing_ratios_versus_spike2_variables{:}});

spike_width_threshold_table = array2table(spike_width_threshold(:, 1:spikes), 'VariableNames', {Spike_width_variables{1:spikes}});
spike_width_percent20_table = array2table(spike_width_percent20(:, 1:spikes), 'VariableNames',  {Spike_width_variables{spikes+1:spikes*2}});
spike_width_percent50_table = array2table(spike_width_percent50(:, 1:spikes), 'VariableNames',  {Spike_width_variables{spikes*2+1:spikes*3}});
spike_width_table = [spike_width_threshold_table, spike_width_percent20_table, spike_width_percent50_table];

spike_width_ratios_threshold_table = array2table(spike_width_ratios_threshold(:, 2:spikes), 'VariableNames', {Spike_width_ratios_variables{1:spikes-1}});
spike_width_ratios_percent20_table = array2table(spike_width_ratios_percent20(:, 2:spikes), 'VariableNames',  {Spike_width_ratios_variables{spikes:spikes*2-2}});
spike_width_ratios_percent50_table = array2table(spike_width_ratios_percent50(:, 2:spikes), 'VariableNames',  {Spike_width_ratios_variables{spikes*2-1:spikes*3-3}});
spike_width_ratios_table = [spike_width_ratios_threshold_table, spike_width_ratios_percent20_table, spike_width_ratios_percent50_table];

dVdt_rising_max_table = array2table(dVdt_rising_max(:, 1:spikes), 'VariableNames', {dVdt_rising_variables{1:spikes}});
dVdt_rising_percent20_table = array2table(dVdt_rising_percent20(:, 1:spikes), 'VariableNames', {dVdt_rising_variables{spikes+1:spikes*2}});
dVdt_rising_percent50_table = array2table(dVdt_rising_percent50(:, 1:spikes), 'VariableNames', {dVdt_rising_variables{spikes*2+1:spikes*3}});
dVdt_rising_table = [dVdt_rising_max_table, dVdt_rising_percent20_table, dVdt_rising_percent50_table];

dVdt_falling_max_table = array2table(dVdt_falling_max(:, 1:spikes), 'VariableNames', {dVdt_falling_variables{1:spikes}});
dVdt_falling_percent20_table = array2table(dVdt_falling_percent20(:, 1:spikes), 'VariableNames', {dVdt_falling_variables{spikes+1:spikes*2}});
dVdt_falling_percent50_table = array2table(dVdt_falling_percent50(:, 1:spikes), 'VariableNames', {dVdt_falling_variables{spikes*2+1:spikes*3}});
dVdt_falling_at_threshold_table = array2table(dVdt_falling_at_threshold(:, 1:spikes), 'VariableNames', {dVdt_falling_variables{spikes*3+1:spikes*4}});


dVdt_falling_table = [dVdt_falling_max_table, dVdt_falling_percent20_table, dVdt_falling_percent50_table, dVdt_falling_at_threshold_table];

adaptation_ratio_1_table = array2table(adaptation_ratio_1(:, 2:spikes-1), 'VariableNames', {adaptation_ratio_1_variables{:}});
adaptation_ratio_2_table = array2table(adaptation_ratio_2(:, 3:spikes-1), 'VariableNames', {adaptation_ratio_2_variables{:}});
adaptation_ratio_table = [adaptation_ratio_1_table, adaptation_ratio_2_table];

%
Cell_properties_table_spikes = [sweep_time_table, AHP_vs_Threshold_table, threshold_vs_threshold_table, AHP_vs_AHP_table,...
    AHP_timing_table, AHP_timing_ratios_versus_spike1_table, AHP_timing_ratios_versus_spike2_table, spike_width_table,...
    spike_width_ratios_table, dVdt_rising_table,dVdt_falling_table, adaptation_ratio_table];



Cell_properties_table_1 = table(genetic_marker, mouse_genotype, retrograde, Ca_buffer,...
    Vm, Rin, distance_from_pia, ...
    PeakSagLocation_ms, sag_amplitude, normalized_sag, sag_amplitude_fit, sag_tau_fit, sag_delta_t, ...
    rebound_amplitude, rebound_amplitude_130ms,rebound_amplitude_230ms,...
    ReboundLocation_ms, ReboundLocation_ms_130ms, ReboundLocation_ms_230ms, reb_delta_t, ReboundLocation_ms_not120sweep,...
    FICurve_slope, FICurve_intercept, adaptation_index_2ndto3rd, adaptation_index_3rdto4th, doublet_index,...
    mean_sag_sweep_time, mean_adapt_sweep_time, mean_doub_sweep_time,...
    'VariableNames', {properties_string_basic{:}, Baseline_variables{:}, 'distance_from_pia', Sag_variables{:}, Reb_variables{:}, 'ReboundLocation_ms_not120sweep',...
    Adaptation_Doublet_variables{:}, 'mean_sag_sweep_time', 'mean_adapt_sweep_time', 'mean_doub_sweep_time'},...
    'RowNames', Cell_name);


Full_Cell_Properties_Table = [Cell_properties_table_1, Cell_properties_table_spikes];



%
end




