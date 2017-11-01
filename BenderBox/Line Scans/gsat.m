function gsat()

scans = loadLineScans;

for i=1:length(scans)
    
    for j=1:length(scans(i).red(:,1))
        
        GoverR(j) = mean(scans(i).green(j,:)) ./ mean(scans(i).red(j,:));        
        
    end
    
    disp(nanmean(GoverR));
    
end