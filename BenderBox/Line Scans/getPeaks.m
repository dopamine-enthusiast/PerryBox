function peaks = getPeaks

scans = loadLineScans;

for i=1:length(scans)
    
    peaks{i,1} = scans(i).name;
    
    trace = smooth(scans(i).normalize(nanmean(scans(i).green),0.1,0.2),11);
    peaks{i,2} = scans(i).getPeak(trace,0.2,1);
    
end


end