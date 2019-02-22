function plot_sweep(sweep,color)

offset = -12;
fs = sweep.fs;
Vm = sweep.data+offset;
time = (1:1:length(Vm))./sweep.fs;

plot(time,Vm,...
    'color', color);
ylim([-150 50]);
ylabel('Vm');
xlabel('Time (sec)');
title(['Temp: ' num2str(sweep.temp) ' Time: ' num2str(sweep.time)]);
set(gca,'XMinorTick','off','YMinorTick','off','TickLength',[0.02 0.035])
set(gca,'fontsize',16,...
    'TickDir','out',...
    'FontName','arial',...
    'box','off');

