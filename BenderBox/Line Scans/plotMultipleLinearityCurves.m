function plotMultipleLinearityCurves

directories = subdir(fullfile(pwd,'*linearity.mat'));

for i=1:length(directories)
    [trash, temp] = fileparts(directories(i).name);
    linearity{i,1} = temp;
    load(directories(i).name);
    linearity{i,2} = lsObj;
end

c = [0    0.4470    0.7410;...
    0.8500    0.3250    0.0980;...
    0.9290    0.6940    0.1250;...
    0.4940    0.1840    0.5560;...
    0.4660    0.6740    0.1880;...
    0.3010    0.7450    0.9330;...
    0.6350    0.0780    0.1840];



figure();
hold on;

for i=1:length(linearity(:,1))
   h =  plot([linearity{i,2}{:,2}],[linearity{i,2}{:,3}],'color',c(i,:))  
end
legend(linearity{:,1});
[trash, temp] = fileparts(pwd);
title(temp);
xlabel('ISI (msec)');
ylabel('observed/expected');

saveas(h,[temp ' linearity.fig']);
close all;

end