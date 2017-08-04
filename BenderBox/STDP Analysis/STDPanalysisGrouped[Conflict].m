function STDPanalysisGrouped(cells)

% Input structure
% First column being cell names (ie. ps20170325a)
% pre sweeps (37:56)
% post sweeps (66-146)



% import results
for i=1:length(cells(:,1))
    results = STDPanalysis(cells{i,1},cells{i,2},cells{i,3},0);
                   
    preTime{i,:} = results.pre.timeIndex;
    postTime{i,:} = results.post.timeIndex;
    
    preVm{i,:} = results.pre.Vm./mean(results.pre.Vm);
    postVm{i,:} = results.post.Vm./mean(results.pre.Vm);
    
    preRin{i,:} = results.pre.Rin./mean(results.pre.Rin);
    postRin{i,:} = results.post.Rin./mean(results.pre.Rin);
    
    preSlope{i,:} = results.pre.slope./mean(results.pre.slope);
    postSlope{i,:} = results.post.slope./mean(results.pre.slope);
    
    preAmp{i,:} = results.pre.amp./mean(results.pre.amp);
    postAmp{i,:} = results.post.amp./mean(results.pre.amp);
end


for i=1:length(normResults)
    
    


% calculate mean
% Calculate SEM
% Plot everything


end



