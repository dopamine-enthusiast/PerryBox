

fig = figure('Color',[1 1 1],'units','normalized','position',[0 0 1 1]);

% h1 = subplot(1,2,1);
% plot(displayWave1.y);
% h2 = subplot(1,2,2);
% plot(displayWave1.y,dVdt.y)
%
v = VideoWriter('Phase Plane Example.avi');
v.FrameRate = 15;
open(v);


subplot(1,2,2);
xlim([-75 60]);
ylim([-100 600]);
xlabel('V_m (mV)')
ylabel('dV/dt (mV/s)')
h11 = animatedline('LineWidth',2','color','k');
h12 = animatedline('LineWidth',2,'color',[0 174/255 239/255]);
h13 = animatedline('LineWidth',2','color','k');
h14 = animatedline('LineWidth',2,'color',[0 166/255 81/255]);
h15 = animatedline('LineWidth',2','color','k');
subplot(1,2,1);
xlim([0 0.1050]);
ylim([-80 60]);
ylabel('V_m (mV)')
xlabel('Time (s)')
h21 = animatedline('LineWidth',2','color','k');
h22 = animatedline('LineWidth',2,'color',[0 174/255 239/255]);
h23 = animatedline('LineWidth',2','color','k');
h24 = animatedline('LineWidth',2,'color',[0 166/255 81/255]);
h25 = animatedline('LineWidth',2','color','k');

time = linspace(0,0.1050,length(displayWave1.y));

k=1;
%first part 4 seconds
step = 200;
while k+step < 2918
    addpoints(h11,displayWave1.y(k:k+step),dVdt.y(k:k+step))
    addpoints(h21,time(k:k+step),displayWave1.y(k:k+step))
    f = getframe(fig);
    writeVideo(v,f)
    k=k+step;
end
addpoints(h11,displayWave1.y(k:2918),dVdt.y(k:2918))
addpoints(h21,time(k:2918),displayWave1.y(k:2918))
f = getframe(fig);
writeVideo(v,f)
k = 2917;

%First AP
step = 1;
while k+step < 2936
    addpoints(h12,displayWave1.y(k:k+step),dVdt.y(k:k+step))
    addpoints(h22,time(k:k+step),displayWave1.y(k:k+step))
    f = getframe(fig);
    writeVideo(v,f)
    k=k+step;
end
addpoints(h12,displayWave1.y(k:2936),dVdt.y(k:2936))
addpoints(h22,time(k:2936),displayWave1.y(k:2936))
f = getframe(fig);
writeVideo(v,f)

step = 4;
while k+step < 3100
    addpoints(h12,displayWave1.y(k:k+step),dVdt.y(k:k+step))
    addpoints(h22,time(k:k+step),displayWave1.y(k:k+step))
    f = getframe(fig);
    writeVideo(v,f)
    k=k+step;
end
addpoints(h12,displayWave1.y(k:3100),dVdt.y(k:3100))
addpoints(h22,time(k:3100),displayWave1.y(k:3100))
f = getframe(fig);
writeVideo(v,f)
k = 3100;


%intermediate
step = 100;
while k+step < 3364
    addpoints(h13,displayWave1.y(k:k+step),dVdt.y(k:k+step))
    addpoints(h23,time(k:k+step),displayWave1.y(k:k+step))
    f = getframe(fig);
    writeVideo(v,f)
    k=k+step;
end
addpoints(h13,displayWave1.y(k:3364),dVdt.y(k:3364))
addpoints(h23,time(k:3364),displayWave1.y(k:3364))
f = getframe(fig);
writeVideo(v,f)
k = 3363;

%Second AP
step = 1;
while k+step < 3387
    addpoints(h14,displayWave1.y(k:k+step),dVdt.y(k:k+step))
    addpoints(h24,time(k:k+step),displayWave1.y(k:k+step))
    k=k+step;
    f = getframe(fig);
    writeVideo(v,f)
end
addpoints(h14,displayWave1.y(k:3387),dVdt.y(k:3387))
addpoints(h24,time(k:3387),displayWave1.y(k:3387))
f = getframe(fig);
writeVideo(v,f)
k = 3387;

step = 4;
while k+step < 3650
    addpoints(h14,displayWave1.y(k:k+step),dVdt.y(k:k+step))
    addpoints(h24,time(k:k+step),displayWave1.y(k:k+step))
    k=k+step;
    f = getframe(fig);
    writeVideo(v,f)
end

addpoints(h14,displayWave1.y(k:3650),dVdt.y(k:3650))
addpoints(h24,time(k:3650),displayWave1.y(k:3650))
f = getframe(fig);
writeVideo(v,f)
k = 3650;

%intermediate
step = 200;
while k+step < length(displayWave1.y)
    addpoints(h15,displayWave1.y(k:k+step),dVdt.y(k:k+step))
    addpoints(h25,time(k:k+step),displayWave1.y(k:k+step))
    f = getframe(fig);
    writeVideo(v,f)
    k=k+step;
end
addpoints(h15,displayWave1.y(k:length(displayWave1.y) ),dVdt.y(k:length(displayWave1.y) ));
addpoints(h25,time(k:length(displayWave1.y) ),displayWave1.y(k:length(displayWave1.y) ));
f = getframe(fig);
writeVideo(v,f)


f = getframe(fig);
writeVideo(v,f)
%     k = k+diff;
% end

close(v)
close(fig);
