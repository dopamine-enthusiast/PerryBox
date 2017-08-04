function h = plotLineScanSweeps(sweepTimes)



%% Import and Sort Linescans
%Find the directories containing the linescans
root = pwd;
[~, cellName] = fileparts(root);

%directories = uipickfiles(); %Use this if you want to select files
linescanFile = subdir(fullfile(root,'LineScan-*.mat')); %Use if you want to plot all linescans in current directory 

counter = 1; %in case some loops fail
%load linescans
for i=1:length(linescanFile)
    
    %Some of these might not work so put in try catch
    try
        linescans(counter) = load(linescanFile(i).name);
        counter = counter+1;
    catch
        %Do nothing
    end
    cd(root);
    
end

%Sort by date
for i=1:length(linescans)
    dates(i) = datenum(linescans(i).date);
end

[temp order] = sort(dates);
linescans = linescans(order);
cd(root);


%% Import ibw Files
sweeps = load([cellName ' sweeps.mat']);


for i=1:length(sweepTimes(:,1))
    
    for j=1:sweepTimes(i,2)
        sweepStart= sweepTimes(i)*sweeps.DAQ.y(sweepTimes(i)) + sweeps.DAQ.y(sweepTimes(i))*(j-1);
        sweepEnd = sweepStart+sweeps.DAQ.y(sweepTimes(i));
        rawVm(j,:)=sweeps.rawsweeps.y(sweepStart:sweepEnd);
    end
    if sweepTimes(i,2) > 1
        sweepAverage(i,:) = mean(rawVm);
    else
         sweepAverage(i,:) = rawVm(1,:);
    end
    time(i,:) = linspace(0,20000/sweeps.DAQ.y(sweepTimes(i)),length(sweepAverage(i,:)));
    clear('rawVm');
    tempAverage(i) = mean(sweeps.temperature.y(sweepTimes(i,1):(sweepTimes(i,1)+sweepTimes(i,2)-1)));
end

%Set colormap
c = [0 0 0;...
    0    0.4470    0.7410;...
    0.8500    0.3250    0.0980;...
    0.9290    0.6940    0.1250;...
    0.4940    0.1840    0.5560;...
    0.4660    0.6740    0.1880;...
    0.3010    0.7450    0.9330;...
    0.6350    0.0780    0.1840];

hold on;
for i=1:length(sweepAverage(:,1))
    h(i) = plot(time(i,:), sweepAverage(i,:),'color',c(i,:),'linewidth',1);
    legendTitles{i} = ['sweep ' num2str(sweepTimes(i,1)) '-' num2str(sweepTimes(i,1)+sweepTimes(i,2)-1) ' ' num2str(tempAverage(i)) 'deg'];
end


legend(h,legendTitles);
legend('boxoff');

[path name] = fileparts(pwd);
t = title([name,' sweeps']);
set(t,'FontSize',15,'FontWeight','bold');


% fileName = [name,' linescan sweeps.jpg'];
% saveas(fig,fileName);
% crop([pwd '/' fileName]);
