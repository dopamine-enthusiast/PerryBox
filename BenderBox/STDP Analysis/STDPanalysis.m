function results = STDPanalysis(cellName,pre,post,protocol,figures)

exportPath = '/Users/perryspratt/Google Drive/Lab/Data/Ephys/Export'; %path to ibw files

%Load ephys data, throw errors if data cannot be found
try
    slope = IBWread([exportPath filesep cellName '_slope.ibw']);
    amp = IBWread([exportPath filesep cellName '_amplitude.ibw']);
    Vm = IBWread([exportPath filesep cellName '_Vm.ibw']);
    sweeptimes = IBWread([exportPath filesep cellName '_sweeptimes_min.ibw']);
catch
    error(['Slope/amp/Vm .ibw files for ' cellName ' could not be found.'])
end
    
try    
    Rin = IBWread([exportPath filesep cellName '_Rin.ibw']);    
    raw = IBWread([exportPath filesep cellName '_rawsweeps.ibw']);
catch 
    disp(['Rin/raw .ibw files for ' cellName ' could not be found'])
end


%[type Rin_Sweep_Average Vrest] = Import_and_Classify_LinescanViewer(cellName,exportPath, 'no','egta');

% 
pre = pre+1;
post = post+1;

%bin each of the time points in 1 minute bins, subtracted by the time of
%the last sweep of the pre interval
preTime = floor(sweeptimes.y(pre)-sweeptimes.y(pre(end)));
preTime(end) = -1;
%bin each of the time points in 1 minute bins, subtracted by the time of
%the first sweep of the post interval
postTime = ceil(sweeptimes.y(post)-sweeptimes.y(post(1)));
postTime(1) = 1;

%bin pre values
c = 1;
for i=min(preTime):max(preTime)
    %     slope
    preSlopeMean(c) = mean(slope.y(find(preTime==i)-1+pre(1)));
    preSlopeSEM(c) = std(slope.y(find(preTime==i)-1+pre(1)))/sqrt(length(slope.y(find(preTime==i)-1+pre(1))));
    %   Amp
    preAmpMean(c) = mean(amp.y(find(preTime==i)-1+pre(1)));
    preAmpSEM(c) = std(amp.y(find(preTime==i)-1+pre(1)))/sqrt(length(amp.y(find(preTime==i)-1+pre(1))));
    
    %   Vm
    preVmMean(c) = mean(Vm.y(find(preTime==i)-1+pre(1)));
    preVmSEM(c) = std(Vm.y(find(preTime==i)-1+pre(1)))/sqrt(length(Vm.y(find(preTime==i)-1+pre(1))));
    
    %   Rin
    preRinMean(c) = mean(Rin.y(find(preTime==i)-1+pre(1)));
    preRinSEM(c) = std(Rin.y(find(preTime==i)-1+pre(1)))/sqrt(length(Rin.y(find(preTime==i)-1+pre(1))));
    
    
    preIndex(c) = i;
    c=c+1;
end

%bin post values
c = 1;
for i=min(postTime):max(postTime)
    %     slope
    postSlopeMean(c) = mean(slope.y(find(postTime==i)-1+post(1)));
    postSlopeSEM(c) = std(slope.y(find(postTime==i)-1+post(1)))/sqrt(length(slope.y(find(postTime==i)-1+post(1))));
    %     Amp
    postAmpMean(c) = mean(amp.y(find(postTime==i)-1+post(1)));
    postAmpSEM(c) = std(amp.y(find(postTime==i)-1+post(1)))/sqrt(length(amp.y(find(postTime==i)-1+post(1))));
    
    %   Vm
    postVmMean(c) = mean(Vm.y(find(postTime==i)-1+post(1)));
    postVmSEM(c) = std(Vm.y(find(postTime==i)-1+post(1)))/sqrt(length(Vm.y(find(postTime==i)-1+post(1))));
    
    %   Rin
    postRinMean(c) = mean(Rin.y(find(postTime==i)-1+post(1)));
    postRinSEM(c) = std(Rin.y(find(postTime==i)-1+post(1)))/sqrt(length(Rin.y(find(postTime==i)-1+post(1))));
    
    postIndex(c) = i;
    
    c=c+1;
end

if figures == 0
    % do nothing
else
    figure('units','normalized','outerposition',[0 0 1 1])
    %Plot everything
    % amp
    subplot(3,4,[3 4])
    set(gca,'fontsize',18)
    hold on;
    plot([preIndex(1)-1 postIndex(end)+1],[mean(preAmpMean) mean(preAmpMean)],'k--');
    scatter(sweeptimes.y(pre)-sweeptimes.y(pre(end))-0.5,amp.y(pre),[],[0.7 0.7 0.7],'filled');
    scatter(sweeptimes.y(post)-sweeptimes.y(post(1))+0.5,amp.y(post),[],[0.7 0.7 0.7],'filled');
    errorbar(preIndex,preAmpMean,preAmpSEM,'-o');
    errorbar(postIndex,postAmpMean,postAmpSEM,'-o');
    
    
    title(['Amplitude vs Time'])
    
    ylabel('Amplitude (mV)');
    xlim([preIndex(1)-1 postIndex(end)+1]);
    
     %slope subplot
     subplot(3,4,[7 8])
     set(gca,'fontsize',18)
    hold on;
    scatter(sweeptimes.y(pre)-sweeptimes.y(pre(end))-0.5,slope.y(pre),[],[0.7 0.7 0.7],'filled');
    scatter(sweeptimes.y(post)-sweeptimes.y(post(1))+0.5,slope.y(post),[],[0.7 0.7 0.7],'filled');
    errorbar(preIndex,preSlopeMean,preSlopeSEM,'-o');
    errorbar(postIndex,postSlopeMean,postSlopeSEM,'-o');
    plot([preIndex(1) postIndex(end)],[mean(preSlopeMean) mean(preSlopeMean)],'k--');
    
    title(['Slope vs Time'])
    
    ylabel('Slope (mV/ms)');
    xlim([preIndex(1)-1 postIndex(end)+1]);
    
    
    % Vm subplot
    subplot(3,4,[9 10])
    set(gca,'fontsize',18)
    hold on;
    scatter(sweeptimes.y(pre)-sweeptimes.y(pre(end))-0.5,Vm.y(pre),[],[0.7 0.7 0.7],'filled');
    scatter(sweeptimes.y(post)-sweeptimes.y(post(1))+0.5,Vm.y(post),[],[0.7 0.7 0.7],'filled');
    errorbar(preIndex,preVmMean,preVmSEM,'-o');
    errorbar(postIndex,postVmMean,postVmSEM,'-o');
    plot([preIndex(1) postIndex(end)],[mean(preVmMean) mean(preVmMean)],'k--');
    
    title(['Membrane Potential vs Time'])
    xlabel('Time (min)');
    ylabel('Vm (mV)');
    xlim([preIndex(1)-1 postIndex(end)+1]);
    
    % Rin subplot
     subplot(3,4,[11 12])
     set(gca,'fontsize',18)
    hold on;
    scatter(sweeptimes.y(pre)-sweeptimes.y(pre(end))-0.5,Rin.y(pre),[],[0.7 0.7 0.7],'filled');
    scatter(sweeptimes.y(post)-sweeptimes.y(post(1))+0.5,Rin.y(post),[],[0.7 0.7 0.7],'filled');
    errorbar(preIndex,preRinMean,preRinSEM,'-o');
    errorbar(postIndex,postRinMean,postRinSEM,'-o');
    plot([preIndex(1) postIndex(end)],[mean(preRinMean) mean(preRinMean)],'k--');
    plot([preIndex(1) postIndex(end)],[mean(preRinMean)*.8 mean(preRinMean)*.8],'k--','linewidth',0.5);
    plot([preIndex(1) postIndex(end)],[mean(preRinMean)*1.2 mean(preRinMean)*1.2],'k--','linewidth',0.5);
    
    title(['Input Resistance vs Time'])
    xlabel('Time (min)');
    ylabel('Rin (Mohm)');
    xlim([preIndex(1)-1 postIndex(end)+1]);
    
    
     subplot(3,4,[1 2 5 6])
%     figure;
    try
        baselineStart = floor(0.025*200000);
        baselineEnd = floor(0.05*200000);

        hold on;
        stimTime = 0.05;
        time = linspace(0-stimTime,1-stimTime,length(raw.y(:,1)));
%         plot(time,raw.y(:,post),'color',[1 0.87 0.87],'linewidth',.5);
%         plot(time,raw.y(:,pre),'color',[.87 .87 1],'linewidth',.5);
        shadedErrorBar(time,mean(raw.y(:,post),2),nansem(raw.y(:,post),2),{'color',[0.8500 0.3250 0.0980],'linewidth',1.5});
        shadedErrorBar(time,mean(raw.y(:,pre),2),nansem(raw.y(:,pre),2),{'color',[0 0.4470 0.7410],'linewidth',1.5});    
    catch 
    end
    
    title([cellName ' (' protocol ')']);
    xlim([-0.025 .1]);
    ylim([-4 12]);
    ylabel('Vm (mV)');
    xlabel('Time (s)');
    
    set(gca,'fontsize',18)
    
    path = '/Users/perryspratt/Google Drive/Lab/Data/Analysis/STDP/Summary Images/';
%     set(gcf,'renderer','Painters')
    print([path cellName '_STDP'],'-dpng');
    
end



% Return Results
results.pre.slope = preSlopeMean;
results.pre.amp = preAmpMean;
results.pre.Vm = preVmMean;
results.pre.Rin = preRinMean;
results.pre.timeIndex = preIndex;

results.post.slope = postSlopeMean;
results.post.amp = postAmpMean;
results.post.Vm = postVmMean;
results.post.Rin = postRinMean;
results.post.timeIndex = postIndex;
