function sweepAverage = getSweepAverage(startSweep,numberSweeps)


try
    ibwRawSweeps = dir('*_rawsweeps.ibw');
catch
    error('ibw raw sweep file not found');
end

rawSweeps = IBWread(ibwRawSweeps(1).name);

sweepAverage = mean(rawSweeps.y(:,startSweep:(startSweep+numberSweeps)),2);
   
