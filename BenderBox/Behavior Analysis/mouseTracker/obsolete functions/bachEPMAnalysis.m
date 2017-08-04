function bachEPMAnalysis

directories = uipickfiles('Type',{'*.mat','Behavior Recording File'});

for i=1:length(directories)
    trial = load(directories{i});
    
    if i == 1
        
        [open1 open2...
            closed1 closed2...
            center] = selectEPMarms(trial.background);
    else
        
        [open1 open2...
            closed1 closed2...
            center] = selectEPMarms(trial.background , open1, open2, closed1, closed2, center);
       
    end
    EPMAnalysis(trial,open1,open2,closed1,closed2,center);
    
end




