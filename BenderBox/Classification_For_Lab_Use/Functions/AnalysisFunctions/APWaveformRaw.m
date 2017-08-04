function [AP_max_points, AP_max_values, AP_onset_time, repol_points, repol_values, thresh_points, thresh_values, spike_amplitudes, spike_width_50percent, spike_width_20percent, dVdt_rising_50percent, dVdt_falling_50percent, dVdt_rising_20percent, dVdt_falling_20percent, spike_width_at_threshold, dVdt_falling_at_threshold, max_rising_dVdt,  max_falling_dVdt, sweeps_to_analyze_300ms_index, number_of_spikes, ms_per_point_for_spiking] = APWaveformRaw(Cell, NumberOfSpikes, IncludeLongerInjections)
% APWaveform 
%   Input:  Cell to analyze, and the number of spikes that you want the
%   train to have (with 300 ms current injection) - in the order of priority 
%   This function calculates all the parameters of the spike waveform. 
%           - Threshold Vm (dVdt>15 mV/s)
%           - Threshold timing for 1st spike 
%           - Peak amp and timing
%           - Peak repolarization (ie. repolarization Vmin)
%           - Spike amplitude (Peak Amp - Peak Thresh)
%           - Spike width and dV/dt @ 20% and 50% of spike height, and at
%           threshold
%          

[pos_current_injection, injection_duration, ~, numspikes, spike_times, ms_per_point_for_spiking ]...
    = CurrentInjectionForSpiking(Cell);

injection_duration_300ms = intersect(find(Cell.swp_time<150), find(injection_duration==300));
numspikes_300ms = numspikes(injection_duration_300ms);

if strcmp(IncludeLongerInjections, 'yes')
    injection_duration_300ms = intersect(find(Cell.swp_time<150), find(injection_duration>=300));
    for i = 1:numel(injection_duration_300ms)
        StepSize = pos_current_injection(injection_duration_300ms(i));
        [PulseOnset ~] = PulseTiming(Cell, StepSize, injection_duration_300ms(i));
        numspikes_300ms(i) = sum(spike_times{injection_duration_300ms(i)}<(PulseOnset + 300/ms_per_point_for_spiking));
    end
end


number_of_spikes = nan; 

i = 1;
while isnan(number_of_spikes) && i <= length(NumberOfSpikes)
    if sum(numspikes_300ms == NumberOfSpikes(i))
        sweeps_to_analyze_300ms_index = injection_duration_300ms(find(numspikes_300ms == NumberOfSpikes(i)));
        number_of_spikes = NumberOfSpikes(i);
    end
    i = i + 1; 
end

if isnan(number_of_spikes)
    sweeps_to_analyze_300ms_index = nan;
end

num_sweeps = sum(~isnan(sweeps_to_analyze_300ms_index), 1); % total number of sweeps for cell
  
properties_string = {'AP_max_points', 'AP_max_values', 'repol_points', 'repol_values',...
    'thresh_points', 'thresh_values', 'spike_amplitudes', 'spike_width_50percent', 'dVdt_rising_50percent',...
    'dVdt_falling_50percent', 'spike_width_20percent', 'dVdt_rising_20percent', ...
    'dVdt_falling_20percent', ...
    'spike_width_at_threshold', 'dVdt_falling_at_threshold',...
    'max_rising_dVdt', 'max_falling_dVdt'};

for ii = 1:length(properties_string)
    evalc([properties_string{ii} ' = cell(1, num_sweeps)']);
end
    
AP_onset_time = nan(num_sweeps, 1);
    

if num_sweeps > 0 
    PulseOnset = find(Cell.comm(:, sweeps_to_analyze_300ms_index)>0, 1, 'first')-1;
    
   
    for i = 1:length(sweeps_to_analyze_300ms_index) % Looping through each sweep (all having same # of spikes)
        j = sweeps_to_analyze_300ms_index(i); % j is the sweep number that you are analyzing for this iteration
        current_sweep = Cell.data(:, j); 
        [~, PulseOffset] = PulseTiming(Cell,  max(Cell.comm(:,j))  , j);

        start_spike_point = nan(numspikes(j), 1); % this will be overwritten each time because don't need
        
        % AP max
        AP_max_points{i} = nan(numspikes(j), 1);
        AP_max_values{i} = nan(numspikes(j), 1);
        
        % Repolarization - all but last spike
        repol_points{i} = nan(numspikes(j), 1);
        repol_values{i} = nan(numspikes(j), 1); 

        % Threshold
        thresh_points{i} = nan(numspikes(j), 1); 
        thresh_values{i} = nan(numspikes(j), 1);
        
        % Spike amplitudes
        spike_amplitudes{i} = nan(numspikes(j), 1);
        
        % Spike width and dVdt at 20% and 50% points
        spike_width_50percent{i} = nan(numspikes(j), 1); 
        dVdt_rising_50percent{i} = nan(numspikes(j), 1);
        dVdt_falling_50percent{i} = nan(numspikes(j), 1);
        
        spike_width_20percent{i} = nan(numspikes(j), 1);
        dVdt_rising_20percent{i} = nan(numspikes(j), 1);
        dVdt_falling_20percent{i} = nan(numspikes(j), 1);
        
        spike_width_at_threshold{i} =  nan(numspikes(j), 1);
        dVdt_falling_at_threshold{i} =  nan(numspikes(j), 1);
        
        % dVdt
        max_rising_dVdt{i} = nan(numspikes(j), 1);
        max_falling_dVdt{i} = nan(numspikes(j), 1);


        % Calculate first derivative to use for threshold
        dVdt = gradient(current_sweep)./ms_per_point_for_spiking;

%         figure
%         plot(Cell.time(:, j),current_sweep)
%         hold on
%         title(Cell.name)

        for ii = 1:numspikes(j) % looping through each spike 
            
            if ii == 1 
                % if analyzing first spike, set start as 10 ms before spike
                % detection threshold (which as set at -10 mV)
                start_spike_point(ii) = spike_times{j}(ii)-10/ms_per_point_for_spiking;     
            else
                start_spike_point(ii) = repol_points{i}(ii-1);
            end
            
            
            % AP peak (values and points)
            
            if ii ~= numspikes(j)
                [AP_max_values{i}(ii), AP_max_points{i}(ii)] = max(current_sweep(start_spike_point(ii):spike_times{j}(ii+1)));
            else
                [AP_max_values{i}(ii), AP_max_points{i}(ii)] = max(current_sweep(start_spike_point(ii):(PulseOffset+10/ms_per_point_for_spiking))); % added 10 ms to catch spikes that occur slightly after pulse offset
            end
            
            AP_max_points{i}(ii) = AP_max_points{i}(ii) + start_spike_point(ii)-1; % adjust for the offset

            % repolarization
            if ii ~= numspikes(j) 
                [repol_values{i}(ii), repol_points{i}(ii)] = min(current_sweep(AP_max_points{i}(ii):spike_times{j}(ii+1)));
                repol_points{i}(ii) = repol_points{i}(ii) + AP_max_points{i}(ii)-1; % adjust for the offset
            end

            % threshold
            end_point_for_threshold = AP_max_points{i}(ii) - 0.2/ms_per_point_for_spiking; % only go to .2 ms from peak, avoid spurious results
            thresh_points{i}(ii) = find(dVdt(start_spike_point(ii):end_point_for_threshold)>15, 1); 
            thresh_points{i}(ii) = thresh_points{i}(ii) + start_spike_point(ii)-2; % adjust for the offset, and also subtract 1 extra so that its the last point <15 ms
            thresh_values{i}(ii) = current_sweep(thresh_points{i}(ii));

            % spike amplitudes
            spike_amplitudes{i}(ii) = AP_max_values{i}(ii)-thresh_values{i}(ii); %#ok<*AGROW>

            

            % find spike width at both 50% and 20% of spike amplitude, as
            % well as at threshold
            
            mV_50percent = thresh_values{i}(ii) + spike_amplitudes{i}(ii)*0.5;
            mV_20percent = thresh_values{i}(ii) + spike_amplitudes{i}(ii)*0.2;
            mV_at_threshold = thresh_values{i}(ii);     
            
            
            tmp_AP_window_before_peak = current_sweep(start_spike_point(ii):AP_max_points{i}(ii));
            
            if ii ~= numspikes(j) 
                tmp_AP_window_after_peak = current_sweep(AP_max_points{i}(ii):repol_points{i}(ii));
            else
                tmp_AP_window_after_peak = current_sweep(AP_max_points{i}(ii):AP_max_points{i}(ii)+10/ms_per_point_for_spiking);
            end

            tmp_mV_50percent_before = abs(tmp_AP_window_before_peak-mV_50percent);
            tmp_mV_50percent_after  = abs(tmp_AP_window_after_peak-mV_50percent);
            tmp_mV_20percent_before = abs(tmp_AP_window_before_peak-mV_20percent);
            tmp_mV_20percent_after  = abs(tmp_AP_window_after_peak-mV_20percent);
            tmp_mV_threshold_before = abs(tmp_AP_window_before_peak - mV_at_threshold);
            tmp_mV_threshold_after = abs(tmp_AP_window_after_peak - mV_at_threshold);

            [~, tmp_50percent_before_point] = min(tmp_mV_50percent_before);
            [~, tmp_50percent_after_point] = min(tmp_mV_50percent_after);
            [~, tmp_20percent_before_point] = min(tmp_mV_20percent_before);
            [~, tmp_20percent_after_point] = min(tmp_mV_20percent_after);
            [~, tmp_threshold_before_point] = min(tmp_mV_threshold_before);
            [~, tmp_threshold_after_point] = min(tmp_mV_threshold_after);

            tmp_50percent_before_point = start_spike_point(ii)+tmp_50percent_before_point-1;
            tmp_50percent_after_point = AP_max_points{i}(ii)+tmp_50percent_after_point-1;
            tmp_20percent_before_point = start_spike_point(ii)+tmp_20percent_before_point-1;
            tmp_20percent_after_point = AP_max_points{i}(ii)+tmp_20percent_after_point-1;
            tmp_threshold_before_point= start_spike_point(ii)+tmp_threshold_before_point-1;
            tmp_threshold_after_point = AP_max_points{i}(ii)+tmp_threshold_after_point-1;

            spike_width_50percent{i}(ii) = (tmp_50percent_after_point-tmp_50percent_before_point)*ms_per_point_for_spiking;
            spike_width_20percent{i}(ii) = (tmp_20percent_after_point-tmp_20percent_before_point)*ms_per_point_for_spiking;
            spike_width_at_threshold{i}(ii) = (tmp_threshold_after_point-tmp_threshold_before_point)*ms_per_point_for_spiking;
            % well as dVdt rising and falling at 20% and 50% spike
            % amplitude
            
            dVdt_rising_20percent{i}(ii) = dVdt(tmp_20percent_before_point);
            dVdt_falling_20percent{i}(ii) = dVdt(tmp_20percent_after_point);
            
            dVdt_rising_50percent{i}(ii) = dVdt(tmp_50percent_before_point);
            dVdt_falling_50percent{i}(ii) = dVdt(tmp_50percent_after_point);
            
            dVdt_falling_at_threshold{i}(ii) = dVdt(tmp_threshold_after_point); 
            
            % max rising and falling dVdt 
            max_rising_dVdt{i}(ii) = max(dVdt(start_spike_point(ii):AP_max_points{i}(ii)));
            
            if ii ~= numspikes(j)
                max_falling_dVdt{i}(ii) = min(dVdt(AP_max_points{i}(ii):repol_points{i}(ii)));
            else
                max_falling_dVdt{i}(ii) = min(dVdt(AP_max_points{i}(ii):(PulseOffset+10/ms_per_point_for_spiking)));
            end
            
            
            
%             plot(Cell.time(AP_max_points{i}(ii)), current_sweep(AP_max_points{i}(ii)), 'o')
%                 
%             if ii ~= numspikes(j)
%                 plot(Cell.time(repol_points{i}(ii)), current_sweep(repol_points{i}(ii)), 'or')
%             end
%                 
%             plot(Cell.time(thresh_points{i}(ii)), current_sweep(thresh_points{i}(ii)), 'ok');
        end
    end
        first_AP_point = cellfun(@(c) c(1), thresh_points);
        AP_onset_time = first_AP_point*ms_per_point_for_spiking - PulseOnset*ms_per_point_for_spiking;
end  
end





