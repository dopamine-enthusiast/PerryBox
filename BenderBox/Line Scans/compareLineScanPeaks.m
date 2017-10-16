function scans = compareLineScanPeaks(scans)

if nargin == 0;
    scans = loadLineScans;
end


for i=1:length(scans)
    
    if ~isfield(scans(i).expParams,'spikeTimes')
        scans(i).expParams.spikeTimes = [.2 .22 .24];
    end
    
    time(i) = datenum(scans(i).date);
    
    trace = scans(i).normGoR;
    startIndex =  ceil(scans(i).expParams.spikeTimes(end)/scans(i).imagingParams.scanlinePeriod);
    endIndex =  ceil(scans(i).time(end)/scans(i).imagingParams.scanlinePeriod);
        
    scans(i).expParams.peak = scans(i).decayFit(trace,startIndex,length(trace));
    peaks(i) = scans(i).expParams.peak;
end

%Sort by time
[sorted order] = sort(time);
scans = scans(order);
time = time(order);
peaks = peaks(order);

time = time - time(1);
peaks = peaks./peaks(1)

for i=1:length(scans)
    scans(i).expParams.relativeTime = datevec(time(i));    
end

figure;
plot(time,peaks,'-ok');
ylim([0 1.2]);
datetick('x','MM');



