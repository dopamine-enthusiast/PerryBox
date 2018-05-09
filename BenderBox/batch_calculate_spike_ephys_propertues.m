function batch_calculate_spike_ephys_properties

cells = dir('*.mat');

for i=1:length(cells)
    
   load(cells(i).name);
   [name sweep num_spikes AP_max AP_amplitude AP_width] = calculate_spike_ephys_properties(Cell);
    
    
end