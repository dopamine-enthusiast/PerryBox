function summary = STDPanalysisGrouped(cells)

% Input structure
% First column being cell names (ie. ps20170325a)
% pre sweeps (37:56)
% post sweeps (66-146)

figures = 1;%

%Import and summarize data
counter = 1;
for i=1:length(cells(:,1))
    try
        results = STDPanalysis(cells{i,1},cells{i,2},cells{i,3},'',figures);
        
        preTime{counter,:} = fliplr(results.pre.timeIndex);
        postTime{counter,:} = results.post.timeIndex;
        summary(i,1) = length(results.pre.timeIndex);
        summary(i,2) = length(results.post.timeIndex);
        
        normPreVm{counter,:} = fliplr(results.pre.Vm./mean(results.pre.Vm));
        normPostVm{counter,:} = results.post.Vm./mean(results.pre.Vm);
        
        normPreRin{counter,:} = fliplr(results.pre.Rin./mean(results.pre.Rin));
        normPostRin{counter,:} = results.post.Rin./mean(results.pre.Rin);
        
        normPreSlope{counter,:} = fliplr(results.pre.slope./mean(results.pre.slope));
        normPostSlope{counter,:} = results.post.slope./mean(results.pre.slope);
        
        summary(i,6) = mean(results.pre.slope);
        summary(i,7) = mean(results.post.slope);
        summary(i,8) = summary(i,7)/summary(i,6);
        
        normPreAmp{counter,:} = fliplr(results.pre.amp./mean(results.pre.amp));
        normPostAmp{counter,:} = results.post.amp./mean(results.pre.amp);
        
        summary(i,3) = mean(results.pre.amp);
        summary(i,4) = mean(results.post.amp);
        summary(i,5) = summary(i,4)/summary(i,3);
        summary(i,9) = max(abs(results.post.Rin./mean(results.pre.Rin)-1));
        counter = counter + 1;
                
    catch ME
        disp(['Could not analyze ' cells{i,1} ': ' ME.message]);
        summary(i,1:9) = NaN;
    end
end

mat2clip(summary);


%% Plot Summary Data

%align the cell tables right (pre) or left (post) and pad with NaNs
nz=max(cellfun(@numel,preTime));
preTime=fliplr(cell2mat(cellfun(@(x) [x,NaN(1,nz-numel(x))],preTime,'uni',false)));
nz=max(cellfun(@numel,postTime));
postTime=cell2mat(cellfun(@(x) [x,NaN(1,nz-numel(x))],postTime,'uni',false));

nz=max(cellfun(@numel,normPreVm));
normPreVm=fliplr(cell2mat(cellfun(@(x) [x,NaN(1,nz-numel(x))],normPreVm,'uni',false)));
nz=max(cellfun(@numel,normPostVm));
normPostVm=cell2mat(cellfun(@(x) [x,NaN(1,nz-numel(x))],normPostVm,'uni',false));

nz=max(cellfun(@numel,normPreRin));
normPreRin=fliplr(cell2mat(cellfun(@(x) [x,NaN(1,nz-numel(x))],normPreRin,'uni',false)));
nz=max(cellfun(@numel,normPostRin));
normPostRin=cell2mat(cellfun(@(x) [x,NaN(1,nz-numel(x))],normPostRin,'uni',false));

nz=max(cellfun(@numel,normPreAmp));
normPreAmp=fliplr(cell2mat(cellfun(@(x) [x,NaN(1,nz-numel(x))],normPreAmp,'uni',false)));
nz=max(cellfun(@numel,normPostAmp));
normPostAmp=cell2mat(cellfun(@(x) [x,NaN(1,nz-numel(x))],normPostAmp,'uni',false));

nz=max(cellfun(@numel,normPreSlope));
normPreSlope=fliplr(cell2mat(cellfun(@(x) [x,NaN(1,nz-numel(x))],normPreSlope,'uni',false)));
nz=max(cellfun(@numel,normPostSlope));
normPostSlope=cell2mat(cellfun(@(x) [x,NaN(1,nz-numel(x))],normPostSlope,'uni',false));

meanPreAmp = nanmean(normPreAmp);
meanPostAmp = nanmean(normPostAmp);
semPreAmp = nansem(normPreAmp);
semPostAmp = nansem(normPostAmp);

meanPreSlope = nanmean(normPreSlope);
meanPostSlope = nanmean(normPostSlope);
semPreSlope = nansem(normPreSlope);
semPostSlope = nansem(normPostSlope);

meanPreRin = nanmean(normPreRin);
meanPostRin = nanmean(normPostRin);
semPreRin = nansem(normPreRin);
semPostRin = nansem(normPostRin);

meanPreVm = nanmean(normPreVm);
meanPostVm = nanmean(normPostVm);
semPreVm = nansem(normPreVm);
semPostVm = nansem(normPostVm);

preTime = nanmean(preTime);
postTime = nanmean(postTime);

figure()
c = get(gca,'ColorOrder');

subplot(4,1,1)
hold on;
for i=1:length(normPreAmp(:,1))
   plot(preTime,normPreAmp(i,:),'color',[.7 .7 .7]); 
   plot(postTime,normPostAmp(i,:),'color',[.7 .7 .7]); 
end
plot([preTime(1)-1 postTime(end)+1], [1 1], 'k--');
ylim([0.5 2]);
xlim([preTime(1)-1 postTime(end)+1]);
xlim([preTime(1)-1 20]);
errorbar(preTime,meanPreAmp,semPreAmp,'o-','color',c(1,:));
errorbar(postTime,meanPostAmp,semPostAmp,'o-','color',c(2,:));

ylabel('Norm Amplitude')
title('Amplitude')

subplot(4,1,2)
hold on;
for i=1:length(normPreSlope(:,1))
   plot(preTime,normPreSlope(i,:),'color',[.7 .7 .7]); 
   plot(postTime,normPostSlope(i,:),'color',[.7 .7 .7]); 
end
plot([preTime(1)-1 postTime(end)+1], [1 1], 'k--');
ylim([0.5 2]);
xlim([preTime(1)-1 postTime(end)+1]);
xlim([preTime(1)-1 20]);
errorbar(preTime,meanPreSlope,semPreSlope,'o-','color',c(1,:));
errorbar(postTime,meanPostSlope,semPostSlope,'o-','color',c(2,:));

ylabel('Norm Slope')
title('Slope')

subplot(4,1,3)
hold on;
for i=1:length(normPreVm(:,1))
   plot(preTime,normPreVm(i,:),'color',[.7 .7 .7]); 
   plot(postTime,normPostVm(i,:),'color',[.7 .7 .7]); 
end
plot([preTime(1)-1 postTime(end)+1], [1 1], 'k--');
ylim([0.8 1.2]);
xlim([preTime(1)-1 postTime(end)+1]);
xlim([preTime(1)-1 20]);
errorbar(preTime,meanPreVm,semPreVm,'o-','color',c(1,:));
errorbar(postTime,meanPostVm,semPostVm,'o-','color',c(2,:));

ylabel('Norm Vm')
title('Membrane Potential')

subplot(4,1,4)
hold on;
for i=1:length(normPreRin(:,1))
   plot(preTime,normPreRin(i,:),'color',[.7 .7 .7]); 
   plot(postTime,normPostRin(i,:),'color',[.7 .7 .7]); 
end
plot([preTime(1)-1 postTime(end)+1], [1 1], 'k--');
ylim([0.8 1.2]);
xlim([preTime(1)-1 postTime(end)+1]);
xlim([preTime(1)-1 20]);
errorbar(preTime,meanPreRin,semPreRin,'o-','color',c(1,:));
errorbar(postTime,meanPostRin,semPostRin,'o-','color',c(2,:));
xlabel('Time (min)');
ylabel('Norm Rin')
title('Input Resistance')



