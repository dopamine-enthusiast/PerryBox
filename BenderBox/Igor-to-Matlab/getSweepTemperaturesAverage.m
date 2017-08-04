function sweepTempAverage = getSweepTemperaturesAverage(startSweep,numberSweeps)


try
    ibwRawSweeps = dir('*temperature.ibw');
catch
    error('ibw raw sweep file not found');
end

rawSweepTemperature = IBWread(ibwRawSweeps(1).name);

sweepTempAverage = mean(rawSweepTemperature.y(startSweep:(startSweep+numberSweeps)));
   
