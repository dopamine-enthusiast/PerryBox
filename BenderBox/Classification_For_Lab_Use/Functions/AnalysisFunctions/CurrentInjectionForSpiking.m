function [ pos_current_injection, injection_duration, frequency_Hz_for300ms, numspikes, spike_times, ms_per_point_for_spiking ] = CurrentInjectionForSpiking( Cell )
%CurrentInjectionforSpiking 
%  

num_sweeps = size(Cell.data, 2); % total number of sweeps for cell

[numspikes, spike_times]=findspikes(Cell.data); % number of spikes in each sweep plus spike times (times just based on arbitrary threshold)

first_sweep = find(~cellfun('isempty', spike_times),1);
points_per_sec = Cell.kHz(first_sweep)*1000;
sec_per_point = 1/points_per_sec;
% establish ms_per_point based on sampling frequency of first sweep with spikes
ms_per_point_for_spiking = sec_per_point*1000; 

% why did I do the below line? it doesn't accomplish anything, I don't
% think. (before I had pos_current_injection = max(current_injection)
% current_injection = intersect(Cell.comm, Cell.comm, 'rows'); % Find all amounts of current injected per sweep


pos_current_injection = max(Cell.comm); % Find amount of positive current injected (assumes only one pos)
injection_duration = nan(1, num_sweeps); % Array for current injection pulse duration (ms) per sweep


for i = 1:num_sweeps
   if pos_current_injection(i) ~= 0
       injection_duration(i) = sum(Cell.comm(:,i) == pos_current_injection(i)) * ms_per_point_for_spiking;
   else
       injection_duration(i) = 0;
   end
end

frequency_Hz_for300ms = nan(1, num_sweeps); % Array for frequency (Hz) of spiking per sweep

for i = 1:num_sweeps
    if injection_duration(i) == 300 % Only looking at current durations = 300 ms for now,because all old data just has 300 ms 
        frequency_Hz_for300ms(i) = (numspikes(i)/injection_duration(i))*1000;
        if frequency_Hz_for300ms(i) == 0
            frequency_Hz_for300ms(i) = nan; % so that the 0s don't go into the FI curve
        end
    end
end


end

