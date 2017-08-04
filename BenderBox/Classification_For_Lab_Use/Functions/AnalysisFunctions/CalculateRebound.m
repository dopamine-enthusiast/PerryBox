function [ReboundAnalysis] = CalculateRebound( Cell )
%CalculateRebound 
%   This calculates the amplitude of the rebound in the first 100 ms after
%   sag offset (compared to baseline), the timing of the rebound (delay
%   from sag offset) - and the time it takes to repolarize from 20% to 80%
%   of the maximum repolarization. 

plotfigure = 0; % this needs to be set to 0 if you want to have things plotted

% Changing this to be the first of the averaged sweeps instead of just of
% all sag sweeps
% SagSweepsIdx  = intersect(find(Cell.swp_time<300), find(any(Cell.comm==-400))); % indices of sweeps w/-400 pA injection
SagSweepsIdx = Cell.Properties.SagReb.AveragedSweeps;
% Establish timing based on kHz and DAQ of sweeps - Assuming that all are
% the same as first one
points_per_sec = Cell.kHz(SagSweepsIdx(1))*1000;
sec_per_point = 1/points_per_sec;
ms_per_point = sec_per_point*1000;
sweep_time = Cell.time(:,SagSweepsIdx(1));


[Sag_Onset, Sag_Offset] = PulseTiming(Cell, -400, SagSweepsIdx); % Determine sag onset and offset points
PulseDuration = (Sag_Offset-Sag_Onset+1) * ms_per_point;



Exists_100ms = Sag_Offset+100/ms_per_point <= sum(~isnan(sweep_time)); 
Exists_130ms = Sag_Offset+130/ms_per_point <= sum(~isnan(sweep_time));
Exists_230ms = Sag_Offset+230/ms_per_point <= sum(~isnan(sweep_time));


%% Get points for the rebound window

if Exists_100ms
    Rebound_window_100ms = [Sag_Offset:(Sag_Offset+100/ms_per_point)]; % rebound window (from sag offset to 100 ms after)
end


if Exists_130ms
    Rebound_window_130ms = [Sag_Offset:(Sag_Offset+130/ms_per_point)]; % rebound window (from sag offset to 130 ms after)
end

if Exists_230ms
    Rebound_window_230ms = [Sag_Offset:(Sag_Offset+230/ms_per_point)]; % rebound window (from sag offset to 230 ms after)
end

%% Isolate the subset of the rebound trace that is in the rebound window

if Exists_100ms
    subset.mV_rebound_100ms = Cell.Properties.SagReb.Sweep(Rebound_window_100ms);
    subset.time_rebound_100ms = sweep_time(Rebound_window_100ms); % only used to calculate delta_t for rise
end

if Exists_130ms
    subset.mV_rebound_130ms = Cell.Properties.SagReb.Sweep(Rebound_window_130ms);
end

if Exists_230ms
    subset.mV_rebound_230ms = Cell.Properties.SagReb.Sweep(Rebound_window_230ms);
end





%% Calculate timing of rebound


if Exists_100ms
    [maximum_mV, ReboundLocation_point] = max(subset.mV_rebound_100ms);
    ReboundLocation_ms_100ms = (ReboundLocation_point)*ms_per_point; % location of rebound (delay from sag offset)
else
    ReboundLocation_ms_100ms = nan;
end

if Exists_130ms
    [maximum_mV_130ms, ReboundLocation_point_130ms] = max(subset.mV_rebound_130ms);
    ReboundLocation_ms_130ms = (ReboundLocation_point_130ms)*ms_per_point; % location of rebound (delay from sag offset)
else
    ReboundLocation_ms_130ms = nan;
end

if Exists_230ms 
    [maximum_mV_230ms, ReboundLocation_point_230ms] = max(subset.mV_rebound_230ms);
    ReboundLocation_ms_230ms = (ReboundLocation_point_230ms)*ms_per_point; % location of rebound (delay from sag offset)
else
    ReboundLocation_ms_230ms = nan; 
end






%% Calculate amplitude of rebound
baseline = mean(Cell.Properties.SagReb.Sweep(Sag_Onset-Cell.Fs*.01:Sag_Onset));


if Exists_100ms
    amplitude_100ms = maximum_mV-baseline;
else
    amplitude_100ms = nan;
end

if Exists_130ms  
    amplitude_130ms = maximum_mV_130ms-baseline;
else
    amplitude_130ms = nan;
end


if Exists_230ms
    amplitude_230ms = maximum_mV_230ms-baseline;    
else
    amplitude_230ms = nan;
end


%% Calculate time to get from 20% to 80% of voltage change from steady state to maximum repolarization

if Exists_100ms
    
    steady_state = mean(Cell.Properties.SagReb.Sweep(Sag_Offset-Cell.Fs*.01:Sag_Offset));
    amplitude_change = maximum_mV - steady_state; 
    Increase20percent = steady_state + amplitude_change * .20;
    Increase80percent = steady_state + amplitude_change * .80;

    % Find the closest values in the sweep to the voltages of the 20% and 80%
    % increases

    tmp20 = abs(subset.mV_rebound_100ms - Increase20percent);
    tmp80 = abs(subset.mV_rebound_100ms - Increase80percent);
    [~, point_20percent] = min(tmp20);
    [~, point_80percent] = min(tmp80);
    mV_20percent = subset.mV_rebound_100ms(point_20percent);
    mV_80percent = subset.mV_rebound_100ms(point_80percent);

    delta_t = (subset.time_rebound_100ms(point_80percent) - subset.time_rebound_100ms(point_20percent))*1000;
    
    
else
    delta_t = nan;
end

if ~isnan(Cell.Properties.SagReb.AveragedSweeps)
    ReboundAnalysis.mean_sweep_time = mean(Cell.swp_time(Cell.Properties.SagReb.AveragedSweeps));
else
    ReboundAnalysis.mean_sweep_time = nan;
end



% Save the output 

if PulseDuration ~= 120
    ReboundAnalysis.rebound_amplitude = nan;
    ReboundAnalysis.rebound_amplitude_130ms = nan;
    ReboundAnalysis.rebound_amplitude_230ms = nan;
    ReboundAnalysis.ReboundLocation_ms = nan;
    ReboundAnalysis.ReboundLocation_ms_130ms = nan;
    ReboundAnalysis.ReboundLocation_ms_230ms = nan;
    ReboundAnalysis.reb_delta_t = nan; 
    ReboundAnalysis.ReboundLocation_ms_not120sweep = ReboundLocation_ms_100ms;   
else
    ReboundAnalysis.rebound_amplitude = amplitude_100ms;
    ReboundAnalysis.rebound_amplitude_130ms = amplitude_130ms;
    ReboundAnalysis.rebound_amplitude_230ms = amplitude_230ms;
    ReboundAnalysis.ReboundLocation_ms = ReboundLocation_ms_100ms;
    ReboundAnalysis.ReboundLocation_ms_130ms = ReboundLocation_ms_130ms;
    ReboundAnalysis.ReboundLocation_ms_230ms = ReboundLocation_ms_230ms;
    ReboundAnalysis.reb_delta_t = delta_t;
    ReboundAnalysis.ReboundLocation_ms_not120sweep = nan; 
end







%% Plot rebound
if plotfigure == 1
      plot(sweep_time(1:min(Cell.DAQ)), Cell.Properties.SagReb.Sweep(1:min(Cell.DAQ)), 'k')
end



end


