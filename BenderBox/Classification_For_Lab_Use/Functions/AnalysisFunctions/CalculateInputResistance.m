function [RinValue] = CalculateInputResistance(Cell)
%CalculateInputReistance 
%   Load cell first using CellImport_SelectSagRebRin, put current cell in
%   workspace; This calculates input resistance, which is the output of
%   this function.
%  

if ~isempty(Cell.Properties.Rin.AveragedSweeps) % check there is a sweep
% Find indices of sweeps that were used for the average
Rin_Sweeps_Idx = Cell.Properties.Rin.AveragedSweeps; % extended time window because just care about timing


% Use function "PulseTiming" to find the onset and offset points of this
% sweep
[Rin_Onset, Rin_Offset] = PulseTiming(Cell, -50, Rin_Sweeps_Idx); 

% Calculate baseline and max deflection; use these to calculate the change
% in voltage
baseline = mean(Cell.Properties.Rin.Sweep(Rin_Onset-Cell.Fs*.002:Rin_Onset));
max_deflection = mean(Cell.Properties.Rin.Sweep(Rin_Offset-Cell.Fs*.002:Rin_Offset));
Rin_dV = max_deflection-baseline;


% Compute average input resistance
RinValue = (1000*Rin_dV)/-50;


else
    RinValue = nan;
end



end

