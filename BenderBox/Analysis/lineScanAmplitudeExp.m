function data = lineScanAmplitudeExp(scans)

baselineStartTime = 0.1;
baselineEndTime = 0.2;
decayStart = 0.24;
decayEnd = .7;

% Select line scans if not passed to function
if nargin < 1
    
    loadDirs = uipickfiles;
    counter = 1;
    for i=1:length(loadDirs)
        
        if isdir(loadDirs{i}) == 1
            try
                scans(counter) = lineScan(loadDirs{i});
                counter = counter+1;
            catch
                disp(['Failed to import ' loadDirs{i}]);
            end
        else
            try
                load(loadDirs{i});
                scans(counter) = obj;
                counter = counter+1;
            catch
                disp(['Failed to import ' loadDirs{i}]);
            end
        end
    end
end


%% Sort Line Scans by time
for i=1:length(scans) 
    date(i) = datenum(scans(i).date);
end
[temp order] = sort(date);
scans = scans(order);

%pull out peaks, and taus
for i=1:length(scans)  
    %Get the green values
    sumGreen = sum(scans(i).green,3);
    for j=1:length(sumGreen(:,1))
        normGreen(j,:) = normalize(obj,sumGreen(j,:),baselineStartTime,baselineEndTime);
    end
    [gPeak,gTau] = decayFit(scans(i),mean(normGreen),decayStart,decayEnd);
    
    sumGOR = sum(scans(i).green,3)./ sum(scans(i).red,3);
    for j=1:length(sumGOR(:,1))
        normGOR(j,:) = sumGOR(j,:)-getBaseline(obj,sumGOR(j,:),baselineStartTime,baselineEndTime);
    end
    [gorPeak,gorTau] = decayFit(scans(i),mean(normGOR),decayStart,decayEnd);
    
    %Basic linescan details
    data{i,1} = scans(i).name;
    data{i,2} = scans(i).date;
    data{i,3} = datenum(scans(i).date) - datenum(scans(1).date)
    data{i,4} = scans(i).name;
    
    %Raw Values
    data{i,9} = gPeak;
    data{i,10} = gTau;
    data{i,11} = gorPeak; 
    data{i,12} = gorTau;
    
    %
    data{i,5} = gPeak/data{1,7};
    data{i,6} = gTau/data{1,8};
    data{i,7} = gorPeak/data{1,9};
    data{i,8} = gorTau/data{1,10};
end





















        
        