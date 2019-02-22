function plot_phase_plane(sweep,color)


%
% if nargin == 1

%
% elseif nargin == 3
%
%     i_start= floor(t_start.*sweep.fs);
%     i_end = floor(t_end.*sweep.fs);
%     if i_start < 0 || i_start > length(sweep.data)
%         error('t_start outside of sweep limits');
%     elseif i_end < 0 || i_end > length(sweep.data)
%         error('t_stop outside of sweep limits');
%     elseif i_end <= i_start
%         error('t_start must come before t_end');
%     end
%
%     Vm = sweep.data(i_start:i_end)+offset;
%     dVdt = gradient(Vm,1./sweep.fs)./1000;
%
% else
%     error('Incorrect number of arguments');
% end


offset = -12;
Vm = sweep.data+offset;
dVdt = gradient(Vm,1./sweep.fs)./1000;

plot(Vm, dVdt,...
    'color',color);

set(gca,'XMinorTick','off','YMinorTick','off','TickLength',[0.02 0.035])
set(gca,'fontsize',16,...
    'TickDir','out',...
    'FontName','arial',...
    'box','off');