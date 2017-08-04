function [SagAnalysis] = CalculateSag( Cell )
%CalculateSag
%   Output:  Timing of peak sag, raw amplitude, normalized sag,
%   tau and amplitude to exponential fit from peak sag, time to get from
%   20% to 80% of peaks sag (delta_t)
%
% Also overlays plots of the fit for sag.
%           if "plotfigure" = 1


plotfigure = 0;

% indices of sweeps with -400 pA injection
SagSweepsIdx  = Cell.Properties.SagReb.AveragedSweeps;

% Establish timing based on kHz and DAQ of sweeps - Assuming that all are
% the same as first one
points_per_sec = Cell.kHz(SagSweepsIdx(1))*1000;
sec_per_point = 1/points_per_sec;
ms_per_point = sec_per_point*1000;
sweep_time = Cell.time(:,SagSweepsIdx(1)); % establish the timing for the sag/rebound sweeps

% determine sag onset and offset points
[Sag_Onset, Sag_Offset] = PulseTiming(Cell, -400, SagSweepsIdx);
PulseDuration = (Sag_Offset-Sag_Onset+1) * ms_per_point;

if PulseDuration ~= 120
    Sag_Offset = Sag_Onset+ 120/ms_per_point - 1; % this goes to the point one before the end of the current injection, to match the analysis above
end




% Find point of peak sag as well as the value of peak sag
% Also calculate ephys baseline (10 ms before onset) and sag steady state (10 ms before offset)
[PeakSag_mV, PeakSagLocation_point] = min(Cell.Properties.SagReb.Sweep(Sag_Onset:Sag_Offset));
PeakSagLocation_point = PeakSagLocation_point+Sag_Onset;
PeakSagLocation_ms = (PeakSagLocation_point-Sag_Onset) * ms_per_point;

baseline = mean(Cell.Properties.SagReb.Sweep(Sag_Onset-Cell.Fs*.01:Sag_Onset));
steady_state = mean(Cell.Properties.SagReb.Sweep(Sag_Offset-Cell.Fs*.01:Sag_Offset));

%% Comput time to get from 20% to 80% of maximum sag

amplitude_change = abs(baseline-PeakSag_mV);

Decrease20percent = baseline - amplitude_change * .20;
Decrease80percent = baseline - amplitude_change * .80;

subset.mV_sag_onset = Cell.Properties.SagReb.Sweep(Sag_Onset:PeakSagLocation_point);
subset.time_sag_onset = sweep_time(Sag_Onset:PeakSagLocation_point);

% Find the closest values in the sweep to the voltages of the 20% and 80%
% increases

tmp20 = abs(subset.mV_sag_onset - Decrease20percent);
tmp80 = abs(subset.mV_sag_onset - Decrease80percent);
[~, point_20percent] = min(tmp20);
[~, point_80percent] = min(tmp80);
mV_20percent = subset.mV_sag_onset(point_20percent);
mV_80percent = subset.mV_sag_onset(point_80percent);

delta_t = (subset.time_sag_onset(point_80percent) - subset.time_sag_onset(point_20percent))*1000;


%% Compute non-normalized sag ("amplitude") and normalized sag
normalized_sag = (PeakSag_mV - steady_state)/(PeakSag_mV - baseline);
amplitude = PeakSag_mV-steady_state;

%% Fit the sag with an exponential
% Get the amplitude of the fit as well as the tau (from max sag to end
% of pulse)

start_point = PeakSagLocation_point;
end_point = Sag_Offset;

if start_point < end_point % this analysiss only works if you actually have points to fit to
    subset.voltage = Cell.Properties.SagReb.Sweep(start_point:end_point);
    
    % Determine what concavity of fit works best
    subset.voltageOffsetOne = subset.voltage - subset.voltage(end);
    subset.voltageOffsetTwo = subset.voltage - subset.voltage(1);
    
    subset.time = sweep_time(start_point:end_point);
    subset.timeOffset = subset.time-sweep_time(start_point);
    
    xData = subset.timeOffset;
    yData1 = subset.voltageOffsetOne;
    yData2 = subset.voltageOffsetTwo;
    
    f = fittype( 'exp1' );
    [fitresult1, gof1] = fit( xData, yData1, f);
    [fitresult2, gof2] = fit( xData, yData2, f);
    
    if  isfield(Cell, 'genetic_marker') & plotfigure == 1
        if Cell.genetic_marker == 'D1'
            figure(1)
        elseif Cell.genetic_marker == 'D2'
            figure(2)
        elseif Cell.genetic_marker == 'D3'
            figure(3)
        else
            figure
        end
    end
    
    if plotfigure == 1
        figure
        plot(sweep_time(1:min(Cell.DAQ)), Cell.Properties.SagReb.Sweep(1:min(Cell.DAQ)), 'k')
        xlim([.5, 1])
        ylim([-150, -50])
        hold on
    end
    
    
    if gof1.rsquare >= gof2.rsquare
        coeffvals1 = coeffvalues(fitresult1);
        amplitude_fit1 = coeffvals1(1);
        tau_fit1 = -1/coeffvals1(2);
        if plotfigure == 1
            plot(subset.time, amplitude_fit1*exp(-xData/tau_fit1)+subset.voltage(end), 'r', 'LineWidth', 2)
        end
        amplitude_fit = amplitude_fit1;
        tau_fit = tau_fit1;
    elseif gof1.rsquare < gof2.rsquare
        coeffvals2 = coeffvalues(fitresult2);
        amplitude_fit2 = coeffvals2(1);
        tau_fit2 = -1/coeffvals2(2);
        if plotfigure == 1
            plot(subset.time, amplitude_fit2*exp(-xData/tau_fit2)+subset.voltage(1), 'r', 'LineWidth', 2)
        end
        amplitude_fit = amplitude_fit2;
        tau_fit = tau_fit2;
    end
else
    
    amplitude_fit = nan;
    tau_fit = nan;
    
end


% Determine mean time of sag sweep

if ~isnan(Cell.Properties.SagReb.AveragedSweeps)
    SagAnalysis.mean_sweep_time = mean(Cell.swp_time(Cell.Properties.SagReb.AveragedSweeps));
else
    SagAnalysis.mean_sweep_time = nan;
end


% Save
SagAnalysis.PeakSagLocation_ms = PeakSagLocation_ms;
SagAnalysis.sag_amplitude = amplitude;
SagAnalysis.normalized_sag = normalized_sag;
SagAnalysis.sag_amplitude_fit = amplitude_fit;
SagAnalysis.sag_tau_fit = tau_fit;
SagAnalysis.sag_delta_t = delta_t;

end




