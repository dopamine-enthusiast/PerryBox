function [slope, intercept, adaptation_index_2ndto3rd, adaptation_index_3rdto4th, doublet_index, adaptation_sweep, doublet_sweep, mean_swp_time_adaptation, mean_swp_time_doublet] = SpikeFiringAnalysis(Cell)
%SpikeAnalysis 
%                       REQUIRED FUNCTIONS
%                         - findspikes


   
[pos_current_injection, injection_duration, frequency_Hz_for300ms, numspikes, spike_times, ~] = CurrentInjectionForSpiking( Cell );

%% Calculate FI curve         
[r, slope, intercept] = regression(pos_current_injection, frequency_Hz_for300ms);
[~, p] = corrcoef(pos_current_injection, frequency_Hz_for300ms, 'rows', 'pairwise');
p = p(1, 2);


%% plot FI curve

% figure
% hold on
% x = pos_current_injection;
% plot(x, slope*x + intercept)
% plot(pos_current_injection, frequency_Hz_for300ms, 'or')
% xlabel('Current Injected (pA)')
% ylabel('Frequency (Hz)')


%% Measure indices of adaption

% For current injections of 300 ms, to get at whether there is a double do
% ISI of first two spikes divided by ISI of last two - for 3, 4, or 5
% spikes

% Find the sweep that you will use
injection_duration_300ms = intersect(find(Cell.swp_time<150), find(injection_duration==300));
numspikes_300ms = numspikes(injection_duration_300ms);

if sum(numspikes_300ms == 3) > 0
    doublet_sweep = injection_duration_300ms(find(numspikes_300ms == 3));
elseif sum(numspikes_300ms == 4) > 0
    doublet_sweep = injection_duration_300ms(find(numspikes_300ms == 4));
elseif sum(numspikes_300ms == 5) > 0 
    doublet_sweep = injection_duration_300ms(find(numspikes_300ms == 5));
else
    doublet_sweep = nan;
end



% Find the adaptation sweep to use 

if sum(numspikes_300ms == 4) > 0 
    adaptation_sweep = injection_duration_300ms(find(numspikes_300ms == 4));
elseif sum(numspikes_300ms == 5) > 0
    adaptation_sweep = injection_duration_300ms(find(numspikes_300ms == 5));
elseif sum(numspikes_300ms == 6) > 0
    adaptation_sweep = injection_duration_300ms(find(numspikes_300ms == 6));
elseif sum(numspikes_300ms == 7) > 0 
    adaptation_sweep = injection_duration_300ms(find(numspikes_300ms == 7));
else
    adaptation_sweep = nan;
end

% Calculate the "doublet index" and the "adaptation index"

if ~isnan(doublet_sweep) 
    doublet_times = spike_times(doublet_sweep);
    tmp = nan(1, length(doublet_times));
    for i = 1:length(doublet_times)
        tmp(i) = (doublet_times{i}(2)-doublet_times{i}(1))/(doublet_times{i}(3)-doublet_times{i}(2));
    end
    doublet_index = mean(tmp);
else
    doublet_index = nan;
end

if ~isnan(adaptation_sweep)
    adaptation_times = spike_times(adaptation_sweep);
    tmp = nan(1, length(adaptation_times));
    tmp2 = nan(1, length(adaptation_times));
    
    for i = 1:length(adaptation_times)
        tmp(i) = (adaptation_times{i}(3)-adaptation_times{i}(2))/(adaptation_times{i}(2)-adaptation_times{i}(1));
        tmp2(i) = (adaptation_times{i}(4)-adaptation_times{i}(3))/(adaptation_times{i}(2)-adaptation_times{i}(1));
    end
    
    adaptation_index_2ndto3rd = mean(tmp);
    adaptation_index_3rdto4th = mean(tmp2);
    
else
    adaptation_index_2ndto3rd = nan;
    adaptation_index_3rdto4th = nan;
end




if ~isnan(adaptation_sweep)
    mean_swp_time_adaptation = mean(Cell.swp_time(adaptation_sweep));
else
    mean_swp_time_adaptation = nan;
end


if ~isnan(doublet_sweep)
    mean_swp_time_doublet = mean(Cell.swp_time(doublet_sweep));
else
    mean_swp_time_doublet = nan;
end




end

