function STDPexample(cellName,pre,post,pairing)

fig = figure('Color',[1 1 1],'units','normalized','position',[0 0 1 1]);
hold on;
v = VideoWriter('STDP Example','MPEG-4');
v.FrameRate = 30;
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
    preSlopeMean(c) = mean(slope.y(find(preTime==i)-1+pre(1)))./mean(slope.y(pre));
    preSlopeSEM(c) = std(slope.y(find(preTime==i)-1+pre(1))./mean(slope.y(pre)))/sqrt(length(slope.y(find(preTime==i)-1+pre(1))));
    %   Amp
    preAmpMean(c) = mean(amp.y(find(preTime==i)-1+pre(1)))./mean(amp.y(pre));
    preAmpSEM(c) = std(amp.y(find(preTime==i)-1+pre(1))./mean(amp.y(pre)))/sqrt(length(amp.y(find(preTime==i)-1+pre(1))));
    
    preIndex(c) = i;
    c=c+1;
end


c = 1;
for i=min(postTime):max(postTime)
    %     slope
    postSlopeMean(c) = mean(slope.y(find(postTime==i)-1+post(1)))./mean(slope.y(pre));
    postSlopeSEM(c) = std(slope.y(find(postTime==i)-1+post(1))./mean(slope.y(pre)))/sqrt(length(slope.y(find(postTime==i)-1+post(1))));
    %     Amp
    postAmpMean(c) = mean(amp.y(find(postTime==i)-1+post(1)))./mean(amp.y(pre));
    postAmpSEM(c) = std(amp.y(find(postTime==i)-1+post(1))./mean(amp.y(pre)))/sqrt(length(amp.y(find(postTime==i)-1+post(1))));
   
    postIndex(c) = i;
    
    c=c+1;
end



subplot(2,4,[3 4]);
subplot(2,4,[7 8]);
subplot(2,4,[1 2 5 6])

subplot(2,4,[3 4])
hold on;
box off;
set(gca,'fontsize',20)
title(['Amplitude'])
xlabel('Time (min)');
ylabel('Post/Pre');
xlim([preIndex(1)-1 postIndex(end)+1]);
ylim([.5 2]);
plot([preIndex(1)-1 postIndex(end)+1],[1 1],'k--');


subplot(2,4,[7 8])
hold on;
box off;
set(gca,'fontsize',20)
title(['Slope'])
xlabel('Time (min)');
ylabel('Post/Pre');
xlim([preIndex(1)-1 postIndex(end)+1]);
ylim([.5 2]);
plot([preIndex(1)-1 postIndex(end)+1],[1 1],'k--');

subplot(2,4,[1 2 5 6])

zoomedInY =[-2 10];
zoomedInX =[-0.02 .1];

zoomedOutY =[-5 100];
zoomedOutX =[-0.05 .95];

set(gca,'fontsize',20)
xlim(zoomedInX);
ylim(zoomedInY);
ylabel('Vm (mV)');
xlabel('time (s)');

stimTime = 0.05;
time = linspace(0-stimTime,1-stimTime,length(raw.y(:,1)));
f = getframe(fig);
writeVideo(v,f);
for i=1:length(pre)
    
    subplot(2,4,[3 4])
    ylim([.5 2]);
    hold on;
    scatter(sweeptimes.y(pre(i))-sweeptimes.y(pre(end))-0.5,amp.y(pre(i))./mean(amp.y(pre)),[],[0.7 0.7 0.7],'filled');
        
    subplot(2,4,[7 8])
    ylim([.5 2]);
    hold on;
    scatter(sweeptimes.y(pre(i))-sweeptimes.y(pre(end))-0.5,slope.y(pre(i))./mean(slope.y(pre)),[],[0.7 0.7 0.7],'filled');
    
    subplot(2,4,[1 2 5 6])
    hold on;
    plot(time,smooth(raw.y(:,pre(i)),5),'color',[0 0 0],'linewidth',2);
    f = getframe(fig);
    writeVideo(v,f);
    writeVideo(v,f);
    plot(time,smooth(raw.y(:,pre(i)),5),'color',[.8 .8 1],'linewidth',2);
        
end
plot(time,mean(raw.y(:,pre),2),'color',[0 0.4470 0.7410],'linewidth',3) 

subplot(2,4,[3 4])
hold on;
errorbar(preIndex,preAmpMean,preAmpSEM,'-o');

subplot(2,4,[7 8])
hold on;
errorbar(preIndex,preSlopeMean,preSlopeSEM,'-o');

f = getframe(fig);
for i = 1:90    
    writeVideo(v,f)
end

zoomSpeed = 15;
dY(1,:) = linspace(zoomedInY(1),zoomedOutY(1),zoomSpeed);
dY(2,:) = linspace(zoomedInY(2),zoomedOutY(2),zoomSpeed);
dX(1,:) = linspace(zoomedInX(1),zoomedOutX(1),zoomSpeed);
dX(2,:) = linspace(zoomedInX(2),zoomedOutX(2),zoomSpeed);
for i = 1:zoomSpeed  
    subplot(2,4,[1 2 5 6])
    hold on;
    xlim([dX(1,i) dX(2,i)]);
    ylim([dY(1,i) dY(2,i)]);
    f = getframe(fig);
    writeVideo(v,f);
end

f = getframe(fig);
for i = 1:30    
    writeVideo(v,f)
end

subplot(2,4,[1 2 5 6])
   hold on;
   
   h(1) = plot(time,raw.y(:,pairing(1)),'color',[0 0 0],'linewidth',2); 
   f = getframe(fig);
   for i =1:90
         writeVideo(v,f);
   end
   set(h(1),'Visible','off');
   f = getframe(fig);
   writeVideo(v,f);
   writeVideo(v,f);
for i=2:length(pairing)
   subplot(2,4,[1 2 5 6])
   hold on;
   
   h(i) = plot(time,raw.y(:,pairing(i)),'color',[0 0 0],'linewidth',2); 
   f = getframe(fig);
   writeVideo(v,f);
   writeVideo(v,f);
   writeVideo(v,f);
   set(h(i),'Visible','off');
   f = getframe(fig);
   writeVideo(v,f);
   writeVideo(v,f);
end

f = getframe(fig);
for i = 1:15    
    writeVideo(v,f)
end



for i = fliplr(1:zoomSpeed)
    subplot(2,4,[1 2 5 6])
    hold on;
    xlim([dX(1,i) dX(2,i)]);
    ylim([dY(1,i) dY(2,i)]);
    f = getframe(fig);
    writeVideo(v,f);
end



for i=1:length(post)
    
    subplot(2,4,[3 4])
    hold on;
    scatter(sweeptimes.y(post(i))-sweeptimes.y(post(1))+0.5,amp.y(post(i))./mean(amp.y(pre)),[],[0.7 0.7 0.7],'filled');
        
    subplot(2,4,[7 8])
    hold on;
    scatter(sweeptimes.y(post(i))-sweeptimes.y(post(1))+0.5,slope.y(post(i))./mean(slope.y(pre)),[],[0.7 0.7 0.7],'filled');
    
    subplot(2,4,[1 2 5 6])
    hold on;
    plot(time,smooth(raw.y(:,post(i)),5),'color',[0 0 0],'linewidth',2);
    f = getframe(fig);
    writeVideo(v,f)
    plot(time,smooth(raw.y(:,post(i)),5),'color',[1 0.8 0.8],'linewidth',2);
    plot(time,mean(raw.y(:,pre),2),'color',[0 0.4470 0.7410],'linewidth',3) 
        
end
plot(time,mean(raw.y(:,post),2),'color',[0.8500 0.3250 0.0980],'linewidth',3) 
subplot(2,4,[3 4])
hold on;
errorbar(postIndex,postAmpMean,postAmpSEM,'-o');

subplot(2,4,[7 8])
hold on;
errorbar(postIndex,postSlopeMean,postSlopeSEM,'-o');


for i = 1:45
    f = getframe(fig);
    writeVideo(v,f)
end

close(v);
close(fig);

