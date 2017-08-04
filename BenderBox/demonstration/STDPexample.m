function STDPexample(cellName,pre,post)

figure()
hold on;
v = VideoWriter('Phase Plane Example.avi');
v.FrameRate = 15;
open(v);


exportPath = '/Users/perryspratt/Google Drive/Lab/Data/Ephys/Export';

slope = IBWread([exportPath filesep cellName '_slope.ibw']);
amp = IBWread([exportPath filesep cellName '_amplitude.ibw']);
Vm = IBWread([exportPath filesep cellName '_Vm.ibw']);
Rin = IBWread([exportPath filesep cellName '_Rin.ibw']);
sweeptimes = IBWread([exportPath filesep cellName '_sweeptimes_min.ibw']);
raw = IBWread([exportPath filesep cellName '_rawsweeps.ibw']);

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

%bin pre values
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


 subplot(2,3,[2 3])
title(['Amplitude vs Time'])
    xlabel('Time (min)');
    ylabel('Amplitude (mV)');
    xlim([preIndex(1)-1 postIndex(end)+1]);
    
     subplot(2,3,[5 6])
    title(['Slope vs Time'])
    xlabel('Time (min)');
    ylabel('Slope (mV/ms)');
    xlim([preIndex(1)-1 postIndex(end)+1]);

for i=1:length(pre)
    
  
   
    
    
end