function [mean_values] = APWaveformSummaryStats(Cell, NumberOfSpikes, IncludeLongerInjections)
%APWaveformSummaryStats
%   
 
    [AP_max_points, AP_max_values, AP_onset_time, repol_points, repol_values, ...
        thresh_points, thresh_values, spike_amplitudes, ...
        spike_width_50percent, spike_width_20percent, ...
        dVdt_rising_50percent, dVdt_falling_50percent, dVdt_rising_20percent, dVdt_falling_20percent,...
        spike_width_at_threshold, dVdt_falling_at_threshold,...
        max_rising_dVdt,  max_falling_dVdt, ...
        sweeps_to_analyze_300ms_index, number_of_spikes, ms_per_point_for_spiking]...
        = APWaveformRaw(Cell, NumberOfSpikes, IncludeLongerInjections);
    
    number_of_sweeps =  sum(~isnan(sweeps_to_analyze_300ms_index));

       
    %% Pre-allocate
    
    if number_of_sweeps > 0   
        preallocated_all_spikes = nan(number_of_sweeps, number_of_spikes);
    else
        preallocated_all_spikes = nan(1, 10);
    end
    

    
    mV_change_allsweeps = struct('AHP_vs_threshold', preallocated_all_spikes, ...
        'threshold_vs_threshold', preallocated_all_spikes,...
        'AHP_vs_AHP', preallocated_all_spikes);

    AHP_timing_allsweeps = struct('All_spikes', preallocated_all_spikes);

    AHP_timing_ratios_allsweeps = struct('versus_spike1', preallocated_all_spikes,...
        'versus_spike2', preallocated_all_spikes);

    spike_width_allsweeps = struct('Threshold', preallocated_all_spikes,...
        'percent20', preallocated_all_spikes,...
        'percent50', preallocated_all_spikes);

    spike_width_ratios_allsweeps = struct('Threshold', preallocated_all_spikes,...
        'percent20', preallocated_all_spikes,...
        'percent50', preallocated_all_spikes);


    dVdt_allsweeps_rising = struct('Max', preallocated_all_spikes,...
        'percent20', preallocated_all_spikes,...
        'percent50', preallocated_all_spikes);
    dVdt_allsweeps_falling = struct('Max', preallocated_all_spikes,...
        'Threshold', preallocated_all_spikes,...
        'percent20', preallocated_all_spikes,...
        'percent50', preallocated_all_spikes);

    adaptation_ratio_all_sweeps = struct('Adaptation_Ratio_1', preallocated_all_spikes,...
        'Adaptation_Ratio_2', preallocated_all_spikes);

        %%        

        
     if number_of_sweeps > 0 
        for i = 1:number_of_sweeps
           for ii = 1:number_of_spikes 
               mV_change_allsweeps.AHP_vs_threshold(i, ii) = repol_values{i}(ii)-thresh_values{i}(1);
               mV_change_allsweeps.threshold_vs_threshold(i, ii) = thresh_values{i}(ii) - thresh_values{i}(1);
               mV_change_allsweeps.AHP_vs_AHP(i, ii) = repol_values{i}(ii) - repol_values{i}(1);

               AHP_timing_allsweeps.All_spikes(i, ii) = (repol_points{i}(ii)-AP_max_points{i}(ii))*ms_per_point_for_spiking;

               AHP_timing_ratios_allsweeps.versus_spike1(i, ii) = ...
                   ((repol_points{i}(ii)-AP_max_points{i}(ii))*ms_per_point_for_spiking)/...
                    ((repol_points{i}(1)-AP_max_points{i}(1))*ms_per_point_for_spiking);
               AHP_timing_ratios_allsweeps.versus_spike2(i, ii) = ...
                   ((repol_points{i}(ii)-AP_max_points{i}(ii))*ms_per_point_for_spiking)/...
                   ((repol_points{i}(2)-AP_max_points{i}(2))*ms_per_point_for_spiking);

               spike_width_allsweeps.percent20(i, ii) = spike_width_20percent{i}(ii);
               spike_width_allsweeps.percent50(i, ii) = spike_width_50percent{i}(ii);
               spike_width_allsweeps.Threshold(i, ii) = spike_width_at_threshold{i}(ii);

               spike_width_ratios_allsweeps.percent20(i, ii) = spike_width_20percent{i}(ii)/spike_width_20percent{i}(1);
               spike_width_ratios_allsweeps.percent50(i, ii) = spike_width_50percent{i}(ii)/spike_width_50percent{i}(1);
               spike_width_ratios_allsweeps.Threshold(i, ii) =  spike_width_at_threshold{i}(ii)/spike_width_at_threshold{i}(1);

               dVdt_allsweeps_rising.Max(i, ii) = max_rising_dVdt{i}(ii);
               dVdt_allsweeps_rising.percent20(i, ii) = dVdt_rising_20percent{i}(ii);
               dVdt_allsweeps_rising.percent50(i, ii) = dVdt_rising_50percent{i}(ii);

               dVdt_allsweeps_falling.Max(i, ii) = max_falling_dVdt{i}(ii);
               dVdt_allsweeps_falling.percent20(i, ii) = dVdt_falling_20percent{i}(ii);
               dVdt_allsweeps_falling.percent50(i, ii) = dVdt_falling_50percent{i}(ii);
               dVdt_allsweeps_falling.Threshold(i, ii) = dVdt_falling_at_threshold{i}(ii); 
               
               if ii<number_of_spikes
                    adaptation_ratio_all_sweeps.Adaptation_Ratio_1(i, ii) = (AP_max_points{i}(ii+1)-AP_max_points{i}(ii))/(AP_max_points{i}(2)-AP_max_points{i}(1));
                    adaptation_ratio_all_sweeps.Adaptation_Ratio_2(i, ii) = (AP_max_points{i}(ii+1)-AP_max_points{i}(ii))/(AP_max_points{i}(3)-AP_max_points{i}(2));
               end
               
           end
        end
     end
     


    % *** The order of all_values and mean_values must line up in order for the
    % function below to work ***
    all_values_structure_names =  {'mV_change_allsweeps', 'AHP_timing_allsweeps', 'AHP_timing_ratios_allsweeps', ...
        'spike_width_allsweeps', 'spike_width_ratios_allsweeps', 'dVdt_allsweeps_rising', 'dVdt_allsweeps_falling', 'adaptation_ratio_all_sweeps'};

    mean_values_structure_names = {'mV_change', 'AHP_timing', 'AHP_timing_ratios', 'spike_width', 'spike_width_ratios', 'dVdt_rising', 'dVdt_falling', 'adaptation_ratio'};



    for i = 1:length(all_values_structure_names)

        all_values = eval(all_values_structure_names{i});
        fields_to_evaluate = fieldnames(all_values);   

        for ii = 1:length(fields_to_evaluate)
            if number_of_sweeps > 1
                mean_values.(mean_values_structure_names{i}).(fields_to_evaluate{ii}) ...
                    = mean(all_values.(fields_to_evaluate{ii}));
            else
                mean_values.(mean_values_structure_names{i}).(fields_to_evaluate{ii}) ...
                    = all_values.(fields_to_evaluate{ii});
                
            end
            
        end
        
    end
    
    mean_values.analyzed_sweeps = sweeps_to_analyze_300ms_index;
    mean_values.number_of_spikes = number_of_spikes;
    if ~isnan(sweeps_to_analyze_300ms_index) 
        mean_values.mean_sweep_time = mean(Cell.swp_time(mean_values.analyzed_sweeps));
    else
        mean_values.mean_sweep_time = nan;
    end
end


    